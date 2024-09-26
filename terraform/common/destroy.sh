#!/usr/bin/env bash

set -uo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR="$(cd ${SCRIPTDIR}/..; pwd )"
[[ -n "${DEBUG:-}" ]] && set -x

echo "Destroying AWS git and iam resources"
terraform -chdir=$SCRIPTDIR init --upgrade
terraform -chdir=$SCRIPTDIR destroy -auto-approve
destroy_output=$(terraform -chdir=$SCRIPTDIR  destroy -auto-approve 2>&1)

# Delete parameter created in the bootstrap
aws ssm delete-parameter --name GiteaExternalUrl || true
