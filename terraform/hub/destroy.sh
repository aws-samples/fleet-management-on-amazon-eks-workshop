#!/usr/bin/env bash

set -uo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR="$(cd ${SCRIPTDIR}/../..; pwd )"
[[ -n "${DEBUG:-}" ]] && set -x

source "${ROOTDIR}/terraform/common.sh"

terraform -chdir=$SCRIPTDIR init --upgrade

# Delete the Ingress/SVC before removing the addons
TMPFILE=$(mktemp)
terraform -chdir=$SCRIPTDIR output -raw configure_kubectl > "$TMPFILE"
# check if TMPFILE contains the string "No outputs found"
if [[ ! $(cat $TMPFILE) == *"No outputs found"* ]]; then
  source "$TMPFILE"
  # Configure EKS access after sourcing kubectl configuration
  configure_eks_access
fi
if kubectl get nodes; then
  # Check if ArgoCD CLI is available
  if command -v argocd &> /dev/null; then
    echo "Using ArgoCD CLI for application cleanup..."
    ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>/dev/null | base64 -d || echo "")
    
    if [ -n "$ARGOCD_PASSWORD" ]; then
      argocd login localhost:8080 --username admin --password $ARGOCD_PASSWORD --insecure
      
      for app in fleet-members fleet-spoke-argocd fleet-members-init fleet-control-plane cluster-addons; do
        timeout 60s argocd app delete $app --cascade --yes 2>/dev/null || \
        timeout 30s kubectl delete applicationsets.argoproj.io -n argocd $app --ignore-not-found=true
      done
    fi
  else
    for app in fleet-members fleet-spoke-argocd fleet-members-init fleet-control-plane cluster-addons; do
      timeout 30s kubectl delete applicationsets.argoproj.io -n argocd $app --ignore-not-found=true
    done
  fi
  
  scale_down_karpenter_nodes
  
  # Delete load balancers with timeout
  kubectl get services --all-namespaces -o json | \
  jq -r '.items[] | select(.spec.type=="LoadBalancer") | "\(.metadata.name) \(.metadata.namespace)"' | \
  while read -r name namespace; do
    echo "Deleting service $name in namespace $namespace"
    timeout 30s kubectl delete service "$name" -n "$namespace" --ignore-not-found=true || true
  done
fi



terraform -chdir=$SCRIPTDIR destroy -target="module.gitops_bridge_bootstrap" -auto-approve
terraform -chdir=$SCRIPTDIR destroy -target="module.eks_blueprints_addons" -auto-approve
terraform -chdir=$SCRIPTDIR destroy -target="module.eks" -auto-approve
# check if env var FORCE_DELETE_VPC is set to "true" then call force_delete_vpc namevpc
if [[ "${FORCE_DELETE_VPC:-false}" == "true" ]]; then
  force_delete_vpc "fleet-hub-cluster"
fi
terraform -chdir=$SCRIPTDIR destroy -target="module.vpc" -auto-approve
terraform -chdir=$SCRIPTDIR destroy -auto-approve
