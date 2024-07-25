#!/usr/bin/env bash

set -euo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR="$(cd ${SCRIPTDIR}/../..; pwd )"
[[ -n "${DEBUG:-}" ]] && set -x

if [[ $# -eq 0 ]] ; then
    echo "No arguments supplied"
    echo "Usage: deploy.sh <environment>"
    echo "Example: deploy.sh dev"
    exit 1
fi
env=$1

echo "Deploying $env with "workspaces/${env}.tfvars" ..."

terraform -chdir=$SCRIPTDIR init --upgrade
terraform -chdir=$SCRIPTDIR workspace new $env || true
terraform -chdir=$SCRIPTDIR workspace select $env
terraform -chdir=$SCRIPTDIR apply -var-file="workspaces/${env}.tfvars" -auto-approve
