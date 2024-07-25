#!/usr/bin/env bash

set -euo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR="$(cd ${SCRIPTDIR}/../..; pwd )"
[[ -n "${DEBUG:-}" ]] && set -x

# Delete the Ingress/SVC before removing the addons
TMPFILE=$(mktemp)
terraform -chdir=$SCRIPTDIR output -raw configure_kubectl > "$TMPFILE"
# check if TMPFILE contains the string "No outputs found"
if [[ ! $(cat $TMPFILE) == *"No outputs found"* ]]; then
  echo "No outputs found, skipping kubectl delete"
  source "$TMPFILE"
  kubectl delete svc -n argocd argo-cd-argocd-server
fi


terraform -chdir=$SCRIPTDIR destroy -target="module.gitops_bridge_bootstrap" -auto-approve
terraform -chdir=$SCRIPTDIR destroy -target="module.eks_blueprints_addons" -auto-approve
terraform -chdir=$SCRIPTDIR destroy -target="module.eks" -auto-approve
terraform -chdir=$SCRIPTDIR destroy -target="module.vpc" -auto-approve
terraform -chdir=$SCRIPTDIR destroy -auto-approve
