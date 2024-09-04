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
  kubectl delete --cascade='foreground' applicationsets.argoproj.io -n argocd cluster-addons
  kubectl delete --cascade='foreground' applicationsets.argoproj.io -n argocd fleet-control-plane
  kubectl delete --cascade='foreground' applicationsets.argoproj.io -n argocd fleet-members-init
  kubectl delete --cascade='foreground' applicationsets.argoproj.io -n argocd fleet-members
  kubectl delete --cascade='foreground' applicationsets.argoproj.io -n argocd fleet-spoke-argocd
  scale_down_karpenter_nodes
  # delete all load balancers
  kubectl get services --all-namespaces -o custom-columns="NAME:.metadata.name,NAMESPACE:.metadata.namespace,TYPE:.spec.type" | \
  grep LoadBalancer | \
  while read -r name namespace type; do
    echo "Deleting service $name in namespace $namespace of type $type"
    kubectl delete --cascade='foreground' service "$name" -n "$namespace"
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
