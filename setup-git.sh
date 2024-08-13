#!/usr/bin/env bash

set -euo pipefail
set -x
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR=$SCRIPTDIR
[[ -n "${DEBUG:-}" ]] && set -x

GITOPS_DIR=${GITOPS_DIR:-$SCRIPTDIR/gitops-repos}

cd $ROOTDIR
# Reset directory
rm -rf ${GITOPS_DIR}
mkdir -p ${GITOPS_DIR}

gitops_workload_url="$(terraform -chdir=${ROOTDIR}/terraform/codecommit output -raw gitops_workload_url)"
gitops_platform_url="$(terraform -chdir=${ROOTDIR}/terraform/codecommit output -raw gitops_platform_url)"
gitops_addons_url="$(terraform -chdir=${ROOTDIR}/terraform/codecommit output -raw gitops_addons_url)"


SSH_PRIVATE_KEY_FILE="$HOME/.ssh/gitops_ssh.pem"
SSH_CONFIG_FILE="$HOME/.ssh/config"
SSH_CONFIG_START_BLOCK="### START BLOCK AWS Workshop ###"
SSH_CONFIG_END_BLOCK="### END BLOCK AWS Workshop ###"

SECRET_ID=$(aws ssm get-parameter --name "/fleet-hub/ssh-secrets-fleet-workshop" --query "Parameter.Value" --output text)
aws secretsmanager get-secret-value --secret-id $SECRET_ID --query SecretString --output text | jq -r .private_key > $SSH_PRIVATE_KEY_FILE

BLOCK=$(aws secretsmanager get-secret-value --secret-id $SECRET_ID --query SecretString --output text | jq -r .ssh_config)

if [ ! -f "$SSH_CONFIG_FILE" ]; then
    echo "Creating $SSH_CONFIG_FILE"
    mkdir -p "$HOME/.ssh"
    touch "$SSH_CONFIG_FILE"
fi

if ! grep -q "$SSH_CONFIG_START_BLOCK" "$SSH_CONFIG_FILE"; then
  echo -e "$SSH_CONFIG_START_BLOCK" >> "$SSH_CONFIG_FILE"
  echo -e "$BLOCK" >> "$SSH_CONFIG_FILE"
  echo -e "$SSH_CONFIG_END_BLOCK" >> "$SSH_CONFIG_FILE"    
fi

chmod 600 $SSH_CONFIG_FILE
chmod 600 $SSH_PRIVATE_KEY_FILE

cat ~/.ssh/config || true
cat ~/.ssh/gitops_ssh.pem || true
ssh-keyscan git-codecommit.$AWS_REGION.amazonaws.com >> ~/.ssh/known_hosts

git clone ${gitops_workload_url} ${GITOPS_DIR}/apps
mkdir -p ${GITOPS_DIR}/apps/backend
touch ${GITOPS_DIR}/apps/backend/.keep
mkdir -p ${GITOPS_DIR}/apps/frontend
touch ${GITOPS_DIR}/apps/frontend/.keep
git -C ${GITOPS_DIR}/apps add . || true
git -C ${GITOPS_DIR}/apps commit -m "initial commit" || true
git -C ${GITOPS_DIR}/apps push  || true

# populate platform repository
git clone ${gitops_platform_url} ${GITOPS_DIR}/platform
mkdir -p ${GITOPS_DIR}/platform/charts && cp -r gitops/platform/charts/*  ${GITOPS_DIR}/platform/charts/
mkdir -p ${GITOPS_DIR}/platform/bootstrap && cp -r gitops/platform/bootstrap/*  ${GITOPS_DIR}/platform/bootstrap/
git -C ${GITOPS_DIR}/platform add . || true
git -C ${GITOPS_DIR}/platform commit -m "initial commit" || true
git -C ${GITOPS_DIR}/platform push || true

git clone ${gitops_addons_url} ${GITOPS_DIR}/addons
cp -r ${ROOTDIR}/gitops/addons/* ${GITOPS_DIR}/addons/
git -C ${GITOPS_DIR}/addons add . || true
git -C ${GITOPS_DIR}/addons commit -m "initial commit" || true
git -C ${GITOPS_DIR}/addons push  || true
