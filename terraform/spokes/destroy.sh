#!/usr/bin/env bash

set -uo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR="$(cd ${SCRIPTDIR}/../..; pwd )"
[[ -n "${DEBUG:-}" ]] && set -x

source "${ROOTDIR}/terraform/common.sh"

# Function to check if ArgoCD applications are stuck due to Git connectivity issues or Unknown status
check_argocd_git_connectivity() {
  local stuck_apps=()
  
  # Check each application for Git connectivity errors or Unknown status
  while IFS= read -r app_name; do
    if [[ -n "$app_name" ]]; then
      local error_msg=$(kubectl get application "$app_name" -n argocd -o jsonpath='{.status.conditions[?(@.type=="ComparisonError")].message}' 2>/dev/null || echo "")
      local sync_status=$(kubectl get application "$app_name" -n argocd -o jsonpath='{.status.sync.status}' 2>/dev/null || echo "")
      
      if [[ "$error_msg" == *"context deadline exceeded"* ]] || [[ "$error_msg" == *"timeout"* ]] || [[ "$error_msg" == *"connection refused"* ]] || [[ "$sync_status" == "Unknown" ]]; then
        stuck_apps+=("$app_name")
        echo "Found stuck application: $app_name (Status: $sync_status)"
        if [[ -n "$error_msg" ]]; then
          echo "Error: $error_msg"
        fi
      fi
    fi
  done < <(kubectl get applications.argoproj.io -n argocd -o jsonpath='{.items[*].metadata.name}' 2>/dev/null | tr ' ' '\n')
  
  if [[ ${#stuck_apps[@]} -gt 0 ]]; then
    echo "Found ${#stuck_apps[@]} applications stuck due to Git connectivity issues or Unknown status"
    return 0  # Found stuck apps
  else
    return 1  # No stuck apps found
  fi
}

# Function to check if any applications have Unknown status
check_unknown_status_apps() {
  local unknown_apps=()
  
  while IFS= read -r line; do
    if [[ -n "$line" ]]; then
      local app_name=$(echo "$line" | awk '{print $1}')
      local sync_status=$(echo "$line" | awk '{print $2}')
      
      if [[ "$sync_status" == "Unknown" ]]; then
        unknown_apps+=("$app_name")
      fi
    fi
  done < <(kubectl get applications.argoproj.io -n argocd --no-headers 2>/dev/null)
  
  if [[ ${#unknown_apps[@]} -gt 0 ]]; then
    echo "Found ${#unknown_apps[@]} applications with Unknown status: ${unknown_apps[*]}"
    return 0  # Found unknown apps
  else
    return 1  # No unknown apps found
  fi
}

if [[ $# -eq 0 ]] ; then
    echo "No arguments supplied"
    echo "Usage: destroy.sh <environment>"
    echo "Example: destroy.sh dev"
    exit 1
fi
env=$1
echo "Destroying $env ..."

terraform -chdir=$SCRIPTDIR init --upgrade
terraform -chdir=$SCRIPTDIR workspace select -or-create $env
# Delete the Ingress/SVC before removing the addons
TMPFILE=$(mktemp)
terraform -chdir=$SCRIPTDIR output -raw configure_kubectl > "$TMPFILE"
# check if TMPFILE contains the string "No outputs found"
if [[ ! $(cat $TMPFILE) == *"No outputs found"* ]]; then
  source "$TMPFILE"
fi
if kubectl get nodes; then
  echo "Cluster is accessible. Proceeding with ArgoCD cleanup..."
  
  # wait until all the argocd applications are gone from the namespace argocd
  # To know if all argocd apps are gone we need to parse the output of kubectl get applications.argocd -n argocd and check if it contains "No resources found"
  if kubectl get crd applications.argoproj.io; then
    echo "ArgoCD CRDs found. Checking for Applications and ApplicationSets..."

    # Set a timeout to prevent infinite waiting (30 minutes max)
    TIMEOUT=1800  # 30 minutes in seconds
    ELAPSED=0
    SLEEP_INTERVAL=60
    GIT_CHECK_INTERVAL=180  # Check for Git connectivity issues every 3 minutes
    UNKNOWN_CHECK_INTERVAL=120  # Check for Unknown status every 2 minutes

    while [[ $(kubectl get applications.argoproj.io -n argocd 2>&1) != *"No resources found"* ]] && [[ $ELAPSED -lt $TIMEOUT ]]; do
      echo "Waiting for all argocd applications to be deleted by hub cluster destroy.sh: https://github.com/aws-samples/fleet-management-on-amazon-eks-workshop/blob/riv24/terraform/hub/destroy.sh"
      echo "Elapsed time: ${ELAPSED}s / ${TIMEOUT}s"
      
      # Show current Applications status
      echo "Current Applications:"
      kubectl get applications.argoproj.io -n argocd --no-headers 2>/dev/null | awk '{print "  - " $1 " (Status: " $2 ", Health: " $3 ")"}' || echo "  No applications found or error accessing them"
      
      # After first minute, check if all applications are in Unknown status - if so, force cleanup immediately
      if [[ $ELAPSED -ge 60 ]]; then
        all_unknown=true
        while IFS= read -r line; do
          if [[ -n "$line" ]]; then
            sync_status=$(echo "$line" | awk '{print $2}')
            if [[ "$sync_status" != "Unknown" ]]; then
              all_unknown=false
              break
            fi
          fi
        done < <(kubectl get applications.argoproj.io -n argocd --no-headers 2>/dev/null)
        
        if [[ "$all_unknown" == "true" ]]; then
          echo "All applications are in Unknown status. Initiating immediate force cleanup..."
          break
        fi
      fi
      
      # Check for Unknown status applications every 2 minutes (after first check)
      if [[ $((ELAPSED % UNKNOWN_CHECK_INTERVAL)) -eq 0 ]] && [[ $ELAPSED -gt 0 ]]; then
        echo "Checking for Applications with Unknown status..."
        if check_unknown_status_apps; then
          echo "Detected Applications with Unknown status. Initiating force cleanup..."
          break
        fi
      fi
      
      # Check for Git connectivity issues every 3 minutes
      if [[ $((ELAPSED % GIT_CHECK_INTERVAL)) -eq 0 ]] && [[ $ELAPSED -gt 0 ]]; then
        echo "Checking for Git connectivity issues..."
        if check_argocd_git_connectivity; then
          echo "Detected Git connectivity issues. Initiating force cleanup..."
          break
        fi
      fi
      
      sleep $SLEEP_INTERVAL
      ELAPSED=$((ELAPSED + SLEEP_INTERVAL))
    done

    # If timeout reached, Unknown status detected, or Git connectivity issues detected, force cleanup of stuck ArgoCD resources
    if [[ $ELAPSED -ge $TIMEOUT ]] || check_argocd_git_connectivity || check_unknown_status_apps; then
      if [[ $ELAPSED -ge $TIMEOUT ]]; then
        echo "Timeout reached. Force cleaning up stuck ArgoCD applications and applicationsets..."
      elif check_unknown_status_apps; then
        echo "Applications with Unknown status detected. Force cleaning up stuck ArgoCD applications and applicationsets..."
      else
        echo "Git connectivity issues detected. Force cleaning up stuck ArgoCD applications and applicationsets..."
      fi
      
      # Remove finalizers from Applications to force deletion
      echo "Removing finalizers from Applications..."
      kubectl get applications.argoproj.io -n argocd -o name 2>/dev/null | while read app; do
        if [[ -n "$app" ]]; then
          echo "Removing finalizers from $app"
          kubectl patch "$app" -n argocd --type='merge' -p='{"metadata":{"finalizers":null}}' || true
        fi
      done
      
      # Remove finalizers from ApplicationSets to force deletion
      echo "Removing finalizers from ApplicationSets..."
      kubectl get applicationsets.argoproj.io -n argocd -o name 2>/dev/null | while read appset; do
        if [[ -n "$appset" ]]; then
          echo "Removing finalizers from $appset"
          kubectl patch "$appset" -n argocd --type='merge' -p='{"metadata":{"finalizers":null}}' || true
        fi
      done
      
      # Wait a bit for the deletions to process
      echo "Waiting for forced deletions to complete..."
      sleep 30
      
      # Final check and force delete any remaining resources
      if kubectl get applications.argoproj.io -n argocd 2>/dev/null | grep -v "No resources found" >/dev/null 2>&1; then
        echo "Force deleting remaining Applications..."
        kubectl delete applications.argoproj.io --all -n argocd --force --grace-period=0 || true
      fi
      
      if kubectl get applicationsets.argoproj.io -n argocd 2>/dev/null | grep -v "No resources found" >/dev/null 2>&1; then
        echo "Force deleting remaining ApplicationSets..."
        kubectl delete applicationsets.argoproj.io --all -n argocd --force --grace-period=0 || true
      fi
      
      echo "Force cleanup completed."
    else
      echo "All ArgoCD applications have been successfully deleted."
    fi

  else
    echo "ArgoCD CRDs not found. Skipping ArgoCD cleanup."
  fi

  scale_down_karpenter_nodes
  # delete all load balancers
  kubectl get services --all-namespaces -o custom-columns="NAME:.metadata.name,NAMESPACE:.metadata.namespace,TYPE:.spec.type" | \
  grep LoadBalancer | \
  while read -r name namespace type; do
    echo "Deleting service $name in namespace $namespace of type $type"
    kubectl delete --cascade='foreground' service "$name" -n "$namespace"
  done
fi

terraform -chdir=$SCRIPTDIR destroy -target="module.gitops_bridge_bootstrap_hub" -auto-approve -var-file="workspaces/${env}.tfvars"
terraform -chdir=$SCRIPTDIR destroy -target="module.eks_blueprints_addons" -auto-approve -var-file="workspaces/${env}.tfvars"
terraform -chdir=$SCRIPTDIR destroy -target="module.eks" -auto-approve -var-file="workspaces/${env}.tfvars"
# check if env var FORCE_DELETE_VPC is set to "true" then call force_delete_vpc namevpc
if [[ "${FORCE_DELETE_VPC:-false}" == "true" ]]; then
  force_delete_vpc "fleet-spoke-${env}"
fi
terraform -chdir=$SCRIPTDIR destroy -target="module.vpc" -auto-approve -var-file="workspaces/${env}.tfvars"
terraform -chdir=$SCRIPTDIR destroy -auto-approve -var-file="workspaces/${env}.tfvars"
