#!/usr/bin/env bash

set -eo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR=$SCRIPTDIR
DEBUG="${DEBUG:-}"
[[ -n "${DEBUG}" ]] && set -x
set -u

# Deploy the infrastructure
echo "Deploy Git and IAM Roles"
DEBUG=$DEBUG TF_VAR_gitea_external_url=$GITEA_EXTERNAL_URL TF_VAR_gitea_password=$GITEA_PASSWORD ${ROOTDIR}/terraform/common/deploy.sh

echo "Configure Git"
GIT_PASS=$GITEA_PASSWORD GITOPS_DIR=/home/ec2-user/environment/gitops-repos ${ROOTDIR}/setup-git.sh
echo "Deploy Hub Cluster"
DEBUG=$DEBUG ${ROOTDIR}/terraform/hub/deploy.sh
echo "Deploy Spoke Staging"
DEBUG=$DEBUG ${ROOTDIR}/terraform/spokes/deploy.sh staging
echo "Deploy Spoke Prod"
DEBUG=$DEBUG ${ROOTDIR}/terraform/spokes/deploy.sh prod
echo "Configure Kubectl"
source ${ROOTDIR}/setup-kubectx.sh