#!/usr/bin/env bash

set -uo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR="$(cd ${SCRIPTDIR}/..; pwd )"
[[ -n "${DEBUG:-}" ]] && set -x

echo "Destroying QuickSight Fleet dashboard resources"
terraform -chdir=$SCRIPTDIR init --upgrade
terraform -chdir=$SCRIPTDIR destroy -auto-approve
destroy_output=$(terraform -chdir=$SCRIPTDIR  destroy -auto-approve 2>&1)
