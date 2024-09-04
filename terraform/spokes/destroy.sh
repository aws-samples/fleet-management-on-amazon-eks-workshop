#!/usr/bin/env bash

set -uo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR="$(cd ${SCRIPTDIR}/../..; pwd )"
[[ -n "${DEBUG:-}" ]] && set -x

source "${ROOTDIR}/terraform/common.sh"

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
  # wait until all the argocd applications are gone from the namespace argocd
  # To know if all argocd apps are gone we need to parse the output of kubectl get applications.argocd -n argocd and check if it contains "No resources found"
  while [[ $(kubectl get applications.argoproj.io -n argocd 2>&1) != *"No resources found"* ]]; do
    echo "Waiting for all argocd applications to be deleted by hub cluster destroy.sh: https://github.com/aws-samples/fleet-management-on-amazon-eks-workshop/blob/riv24/terraform/hub/destroy.sh"
    sleep 60
  done

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
