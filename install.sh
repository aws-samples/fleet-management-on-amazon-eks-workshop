#!/usr/bin/env bash

set -euo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR=$SCRIPTDIR
[[ -n "${DEBUG:-}" ]] && set -x

# For AWS EC2 override with
# export TF_VAR_ssh_key_basepath="/home/ec2-user/.ssh"

# Deploy the infrastructure
${ROOTDIR}/terraform/codecommit/deploy.sh
source ${ROOTDIR}/setup-git.sh
${ROOTDIR}/terraform/hub/deploy.sh
${ROOTDIR}/terraform/spokes/deploy.sh staging
${ROOTDIR}/terraform/spokes/deploy.sh prod
source ${ROOTDIR}/setup-kubectx.sh