#!/usr/bin/env bash

set -uo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR="$(cd ${SCRIPTDIR}/../..; pwd )"
[[ -n "${DEBUG:-}" ]] && set -x

source "${ROOTDIR}/terraform/common.sh"

terraform -chdir=$SCRIPTDIR init --upgrade

# Configure kubectl if cluster exists
if terraform -chdir=$SCRIPTDIR output -raw configure_kubectl 2>/dev/null | grep -v "No outputs found" > /dev/null; then
  eval "$(terraform -chdir=$SCRIPTDIR output -raw configure_kubectl)"
  configure_eks_access
fi

# Enhanced cleanup function for ArgoCD resources
cleanup_argocd_resources() {
  echo "Starting enhanced ArgoCD cleanup..."
  
  if ! kubectl get ns argocd &>/dev/null; then
    echo "ArgoCD namespace not found, skipping cleanup"
    return 0
  fi

  # 1. Delete workload applications first (but keep cluster-addons for last)
  WORKLOAD_APPS=(fleet-members fleet-spoke-argocd fleet-members-init fleet-control-plane)
  
  for app in "${WORKLOAD_APPS[@]}"; do
    echo "Deleting workload application: $app"
    # Remove finalizers first
    kubectl patch applicationsets.argoproj.io -n argocd $app --type='merge' -p='{"metadata":{"finalizers":null}}' 2>/dev/null || true
    # Force delete with longer timeout
    timeout 60s kubectl delete applicationsets.argoproj.io -n argocd $app --ignore-not-found=true --wait=false --force --grace-period=0 2>/dev/null || true
  done
  
  # 2. Clean up any remaining ArgoCD applications
  echo "Cleaning up remaining ArgoCD applications..."
  kubectl get applications.argoproj.io -n argocd -o name 2>/dev/null | while read -r app; do
    echo "Removing finalizers from $app"
    kubectl patch "$app" -n argocd --type='merge' -p='{"metadata":{"finalizers":null}}' 2>/dev/null || true
    kubectl delete "$app" -n argocd --ignore-not-found=true --wait=false --force --grace-period=0 2>/dev/null || true
  done
  
  # 3. Clean up any remaining ApplicationSets
  echo "Cleaning up remaining ApplicationSets..."
  kubectl get applicationsets.argoproj.io -n argocd -o name 2>/dev/null | while read -r appset; do
    echo "Removing finalizers from $appset"
    kubectl patch "$appset" -n argocd --type='merge' -p='{"metadata":{"finalizers":null}}' 2>/dev/null || true
    kubectl delete "$appset" -n argocd --ignore-not-found=true --wait=false --force --grace-period=0 2>/dev/null || true
  done
  
  # 4. Wait for workloads to terminate
  echo "Waiting for workloads to terminate..."
  sleep 15
  
  # 5. Delete LoadBalancer services before removing the controller
  echo "Cleaning up LoadBalancer services..."
  kubectl get services --all-namespaces --field-selector spec.type=LoadBalancer -o json 2>/dev/null | \
  jq -r '.items[]? | "\(.metadata.name) \(.metadata.namespace)"' | \
  while read -r name namespace; do
    if [ -n "$name" ] && [ -n "$namespace" ]; then
      echo "Deleting LoadBalancer: $name in $namespace"
      kubectl patch service "$name" -n "$namespace" --type='merge' -p='{"metadata":{"finalizers":null}}' 2>/dev/null || true
      timeout 60s kubectl delete service "$name" -n "$namespace" --ignore-not-found=true --wait=false --force --grace-period=0 || true
    fi
  done
  
  # 6. Scale down Karpenter nodes
  scale_down_karpenter_nodes
  
  # 7. Delete cluster-addons (controllers like load-balancer-controller)
  echo "Deleting cluster-addons (controllers)..."
  kubectl patch applicationsets.argoproj.io -n argocd cluster-addons --type='merge' -p='{"metadata":{"finalizers":null}}' 2>/dev/null || true
  timeout 60s kubectl delete applicationsets.argoproj.io -n argocd cluster-addons --ignore-not-found=true --wait=false --force --grace-period=0 2>/dev/null || true
  
  # 8. Force cleanup of ArgoCD namespace if it's stuck
  echo "Checking ArgoCD namespace status..."
  if kubectl get ns argocd -o jsonpath='{.status.phase}' 2>/dev/null | grep -q "Terminating"; then
    echo "ArgoCD namespace is stuck in Terminating state, attempting force cleanup..."
    
    # Remove finalizers from the namespace
    kubectl patch namespace argocd --type='merge' -p='{"metadata":{"finalizers":null}}' 2>/dev/null || true
    
    # Try to delete any remaining resources in the namespace
    kubectl delete all --all -n argocd --force --grace-period=0 2>/dev/null || true
    kubectl delete pvc --all -n argocd --force --grace-period=0 2>/dev/null || true
    kubectl delete secrets --all -n argocd --force --grace-period=0 2>/dev/null || true
    kubectl delete configmaps --all -n argocd --force --grace-period=0 2>/dev/null || true
    
    # Final attempt to delete the namespace
    kubectl delete namespace argocd --force --grace-period=0 2>/dev/null || true
  fi
  
  echo "ArgoCD cleanup completed"
}

# Clean up in proper order: workloads first, then controllers
if kubectl get ns argocd &>/dev/null; then
  cleanup_argocd_resources
fi

# Terraform destroy in proper order with better error handling
TARGETS=("module.gitops_bridge_bootstrap" "module.eks_blueprints_addons" "module.eks")

for target in "${TARGETS[@]}"; do
  echo "Destroying $target..."
  # Add retries for terraform destroy
  for attempt in 1 2 3; do
    echo "Attempt $attempt to destroy $target"
    if terraform -chdir=$SCRIPTDIR destroy -target="$target" -auto-approve; then
      echo "Successfully destroyed $target"
      break
    else
      echo "Failed to destroy $target on attempt $attempt"
      if [ $attempt -eq 3 ]; then
        echo "All attempts failed for $target, continuing with next target..."
      else
        echo "Waiting 30 seconds before retry..."
        sleep 30
      fi
    fi
  done
done

# Force delete VPC if requested
[[ "${FORCE_DELETE_VPC:-false}" == "true" ]] && force_delete_vpc "fleet-hub-cluster"

# Destroy VPC with retries
echo "Destroying VPC..."
for attempt in 1 2 3; do
  echo "Attempt $attempt to destroy VPC"
  if terraform -chdir=$SCRIPTDIR destroy -target="module.vpc" -auto-approve; then
    echo "Successfully destroyed VPC"
    break
  else
    echo "Failed to destroy VPC on attempt $attempt"
    if [ $attempt -eq 3 ]; then
      echo "All attempts failed for VPC, continuing with final destroy..."
    else
      echo "Waiting 30 seconds before retry..."
      sleep 30
    fi
  fi
done

# Final destroy with retries
echo "Running final terraform destroy..."
for attempt in 1 2 3; do
  echo "Attempt $attempt for final destroy"
  if terraform -chdir=$SCRIPTDIR destroy -auto-approve; then
    echo "Successfully completed final destroy"
    break
  else
    echo "Failed final destroy on attempt $attempt"
    if [ $attempt -eq 3 ]; then
      echo "All attempts failed for final destroy. Manual cleanup may be required."
      exit 1
    else
      echo "Waiting 30 seconds before retry..."
      sleep 30
    fi
  fi
done

echo "Destroy script completed successfully"
