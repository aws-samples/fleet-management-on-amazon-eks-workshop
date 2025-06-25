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
# Clean up in proper order: workloads first, then controllers
if kubectl get ns argocd &>/dev/null; then
  # 1. Delete workload applications first (but keep cluster-addons for last)
  WORKLOAD_APPS=(fleet-members fleet-spoke-argocd fleet-members-init fleet-control-plane)
  
  for app in "${WORKLOAD_APPS[@]}"; do
    echo "Deleting workload application: $app"
    kubectl patch applicationsets.argoproj.io -n argocd $app --type='merge' -p='{"metadata":{"finalizers":null}}' 2>/dev/null || true
    timeout 30s kubectl delete applicationsets.argoproj.io -n argocd $app --ignore-not-found=true --wait=false
  done
  
  # 2. Wait a bit for workloads to terminate
  echo "Waiting for workloads to terminate..."
  sleep 10
  
  # 3. Delete LoadBalancer services before removing the controller
  echo "Cleaning up LoadBalancer services..."
  kubectl get services --all-namespaces --field-selector spec.type=LoadBalancer -o json 2>/dev/null | \
  jq -r '.items[]? | "\(.metadata.name) \(.metadata.namespace)"' | \
  while read -r name namespace; do
    if [ -n "$name" ] && [ -n "$namespace" ]; then
      echo "Deleting LoadBalancer: $name in $namespace"
      kubectl patch service "$name" -n "$namespace" --type='merge' -p='{"metadata":{"finalizers":null}}' 2>/dev/null || true
      timeout 30s kubectl delete service "$name" -n "$namespace" --ignore-not-found=true --wait=false || true
    fi
  done
  
  # 4. Scale down Karpenter nodes
  scale_down_karpenter_nodes
  
  # 5. Finally delete cluster-addons (controllers like load-balancer-controller)
  echo "Deleting cluster-addons (controllers)..."
  kubectl patch applicationsets.argoproj.io -n argocd cluster-addons --type='merge' -p='{"metadata":{"finalizers":null}}' 2>/dev/null || true
  timeout 30s kubectl delete applicationsets.argoproj.io -n argocd cluster-addons --ignore-not-found=true --wait=false
fi



# Terraform destroy in proper order
TARGETS=("module.gitops_bridge_bootstrap" "module.eks_blueprints_addons" "module.eks")

for target in "${TARGETS[@]}"; do
  echo "Destroying $target..."
  terraform -chdir=$SCRIPTDIR destroy -target="$target" -auto-approve
done

# Force delete VPC if requested
[[ "${FORCE_DELETE_VPC:-false}" == "true" ]] && force_delete_vpc "fleet-hub-cluster"

terraform -chdir=$SCRIPTDIR destroy -target="module.vpc" -auto-approve
terraform -chdir=$SCRIPTDIR destroy -auto-approve
