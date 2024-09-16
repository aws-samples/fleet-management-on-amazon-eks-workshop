#!/usr/bin/env bash

set -euo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR="$(cd ${SCRIPTDIR}/../..; pwd )"
[[ -n "${DEBUG:-}" ]] && set -x

# Initialize Terraform
terraform -chdir=$SCRIPTDIR init --upgrade

echo "Deploy Hub cluster"
#terraform -chdir=$SCRIPTDIR apply -auto-approve
