#!/usr/bin/env bash

set -euo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR="$(cd ${SCRIPTDIR}/../..; pwd )"
[[ -n "${DEBUG:-}" ]] && set -x

# Initialize Terraform
terraform -chdir=$SCRIPTDIR init --upgrade

echo "Deploy Hub cluster"
terraform -chdir=$SCRIPTDIR apply -target="module.eks" -auto-approve
terraform -chdir=$SCRIPTDIR apply -target="module.eks_blueprints_addons" -auto-approve
terraform -chdir=$SCRIPTDIR apply -target="module.gitops_bridge_bootstrap" -auto-approve
terraform -chdir=$SCRIPTDIR apply -auto-approve
