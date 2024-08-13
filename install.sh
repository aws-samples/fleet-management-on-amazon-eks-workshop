#!/usr/bin/env bash

set -euo pipefail
set -x
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR=$SCRIPTDIR
[[ -n "${DEBUG:-}" ]] && set -x

id
pwd

# Deploy the infrastructure
echo "Deploy Git"
mkdir -p ~/.ssh
${ROOTDIR}/terraform/codecommit/deploy.sh
echo "Configure Git"
source ${ROOTDIR}/setup-git.sh
echo "Deploy Hub Cluster"
${ROOTDIR}/terraform/hub/deploy.sh
echo "Deploy Spoke Staging"
${ROOTDIR}/terraform/spokes/deploy.sh staging
echo "Deploy Spoke Prod"
${ROOTDIR}/terraform/spokes/deploy.sh prod
echo "Configure Kubectl"
source ${ROOTDIR}/setup-kubectx.sh