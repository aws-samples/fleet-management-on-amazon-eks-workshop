#!/usr/bin/env bash

set -euo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR="$(cd ${SCRIPTDIR}/../..; pwd )"
[[ -n "${DEBUG:-}" ]] && set -x

if [[ $# -eq 0 ]] ; then
    echo "No arguments supplied"
    echo "Usage: destroy.sh <environment>"
    echo "Example: destroy.sh dev"
    exit 1
fi
env=$1
echo "Destroying $env ..."

terraform -chdir=$SCRIPTDIR workspace select $env
# Delete the Ingress/SVC before removing the addons
TMPFILE=$(mktemp)
terraform -chdir=$SCRIPTDIR output -raw configure_kubectl > "$TMPFILE"
# check if TMPFILE contains the string "No outputs found"
if [[ ! $(cat $TMPFILE) == *"No outputs found"* ]]; then
  echo "No outputs found, skipping kubectl delete"
  source "$TMPFILE"
  kubectl delete svc --all -n ui
  kubectl delete -A tables.dynamodb.services.k8s.aws --all
fi

terraform -chdir=$SCRIPTDIR destroy -target="module.gitops_bridge_bootstrap_hub" -auto-approve -var-file="workspaces/${env}.tfvars"
terraform -chdir=$SCRIPTDIR destroy -target="module.eks_blueprints_addons" -auto-approve -var-file="workspaces/${env}.tfvars"
terraform -chdir=$SCRIPTDIR destroy -target="module.eks" -auto-approve -var-file="workspaces/${env}.tfvars"
terraform -chdir=$SCRIPTDIR destroy -target="module.vpc" -auto-approve -var-file="workspaces/${env}.tfvars"
terraform -chdir=$SCRIPTDIR destroy -auto-approve -var-file="workspaces/${env}.tfvars"
