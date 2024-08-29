#!/usr/bin/env bash

set -euo pipefail
set -x

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR=$SCRIPTDIR
[[ -n "${DEBUG:-}" ]] && set -x

GITOPS_DIR=${GITOPS_DIR:-$SCRIPTDIR/environment/gitops-repos}

PROJECT_CONTECXT_PREFIX=${PROJECT_CONTECXT_PREFIX:-eks-fleet-workshop-gitops}
SSH_SECRET_ID="${PROJECT_CONTECXT_PREFIX}-ssh-key"
SSH_PRIVATE_KEY_FILE="$HOME/.ssh/gitops_ssh.pem"
SSH_CONFIG_FILE="$HOME/.ssh/config"
SSH_CONFIG_START_BLOCK="### START BLOCK AWS Workshop ###"
SSH_CONFIG_END_BLOCK="### END BLOCK AWS Workshop ###"
SSH_CONFIG_HOST="git-codecommit.*.amazonaws.com"

aws secretsmanager get-secret-value --secret-id $SSH_SECRET_ID --query SecretString --output text | jq -r .private_key > $SSH_PRIVATE_KEY_FILE

if [ ! -f "$SSH_CONFIG_FILE" ]; then
    echo "Creating $SSH_CONFIG_FILE"
    mkdir -p "$HOME/.ssh"
    touch "$SSH_CONFIG_FILE"
fi

if ! grep -q "$SSH_CONFIG_START_BLOCK" "$SSH_CONFIG_FILE"; then
  echo -e "$SSH_CONFIG_START_BLOCK" >> "$SSH_CONFIG_FILE"
cat >> $SSH_CONFIG_FILE << EOT
# AWS Workshop https://github.com/aws-samples/fleet-management-on-amazon-eks-workshop.git
Host $SSH_CONFIG_HOST
  IdentityFile $SSH_PRIVATE_KEY_FILE
EOT
  echo -e "$SSH_CONFIG_END_BLOCK" >> "$SSH_CONFIG_FILE"
fi

chmod 600 $SSH_CONFIG_FILE
chmod 600 $SSH_PRIVATE_KEY_FILE

# cat ~/.ssh/config || true
# cat ~/.ssh/gitops_ssh.pem || true
ssh-keyscan git-codecommit.$AWS_REGION.amazonaws.com >> ~/.ssh/known_hosts



# Clone and initialize the gitops repositories
gitops_workload_url="$(aws secretsmanager get-secret-value --secret-id ${PROJECT_CONTECXT_PREFIX}-workloads --query SecretString --output text | jq -r .url)"
gitops_platform_url="$(aws secretsmanager get-secret-value --secret-id ${PROJECT_CONTECXT_PREFIX}-platform --query SecretString --output text | jq -r .url)"
gitops_addons_url="$(aws secretsmanager   get-secret-value --secret-id ${PROJECT_CONTECXT_PREFIX}-addons --query SecretString --output text | jq -r .url)"
gitops_fleet_url="$(aws secretsmanager   get-secret-value  --secret-id ${PROJECT_CONTECXT_PREFIX}-fleet --query SecretString --output text | jq -r .url)"

# Reset directory
rm -rf ${GITOPS_DIR}
mkdir -p ${GITOPS_DIR}

git clone ${gitops_workload_url} ${GITOPS_DIR}/apps
mkdir -p ${GITOPS_DIR}/apps/backend
touch ${GITOPS_DIR}/apps/backend/.keep
mkdir -p ${GITOPS_DIR}/apps/frontend
touch ${GITOPS_DIR}/apps/frontend/.keep

# Deploy the app for this workshop
# TODO: review with the team
cp -r ${ROOTDIR}/gitops/apps/* ${GITOPS_DIR}/apps/

git -C ${GITOPS_DIR}/apps add . || true
git -C ${GITOPS_DIR}/apps commit -m "initial commit" || true
git -C ${GITOPS_DIR}/apps push  || true

# populate platform repository
git clone ${gitops_platform_url} ${GITOPS_DIR}/platform
mkdir -p ${GITOPS_DIR}/platform/charts
cp -r ${ROOTDIR}/gitops/platform/charts/*  ${GITOPS_DIR}/platform/charts/
mkdir -p ${GITOPS_DIR}/platform/bootstrap
cp -r ${ROOTDIR}/gitops/platform/bootstrap/*  ${GITOPS_DIR}/platform/bootstrap/

# Deploy the namespaces for this workshop
# TODO: review with the team
mkdir -p ${GITOPS_DIR}/platform/teams
cp -r ${ROOTDIR}/gitops/platform/teams/*  ${GITOPS_DIR}/platform/teams/

git -C ${GITOPS_DIR}/platform add . || true
git -C ${GITOPS_DIR}/platform commit -m "initial commit" || true
git -C ${GITOPS_DIR}/platform push || true

git clone ${gitops_addons_url} ${GITOPS_DIR}/addons
cp -r ${ROOTDIR}/gitops/addons/* ${GITOPS_DIR}/addons/
git -C ${GITOPS_DIR}/addons add . || true
git -C ${GITOPS_DIR}/addons commit -m "initial commit" || true
git -C ${GITOPS_DIR}/addons push  || true

git clone ${gitops_fleet_url} ${GITOPS_DIR}/fleet
cp -r ${ROOTDIR}/gitops/fleet/* ${GITOPS_DIR}/fleet/
git -C ${GITOPS_DIR}/fleet add . || true
git -C ${GITOPS_DIR}/fleet commit -m "initial commit" || true
git -C ${GITOPS_DIR}/fleet push || true
