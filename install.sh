#!/usr/bin/env bash

set -eo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR=$SCRIPTDIR
DEBUG="${DEBUG:-}"
[[ -n "${DEBUG}" ]] && set -x
set -u

# Deploy the infrastructure
echo "Deploy Git and IAM Roles"
DEBUG=$DEBUG ${ROOTDIR}/terraform/common/deploy.sh
echo "Configure Git"
source ${ROOTDIR}/setup-git.sh
echo "Deploy Hub Cluster"
DEBUG=$DEBUG ${ROOTDIR}/terraform/hub/deploy.sh
echo "Deploy Spoke Staging"
DEBUG=$DEBUG ${ROOTDIR}/terraform/spokes/deploy.sh staging
echo "Deploy Spoke Prod"
DEBUG=$DEBUG ${ROOTDIR}/terraform/spokes/deploy.sh prod
echo "Configure Kubectl"
source ${ROOTDIR}/setup-kubectx.sh