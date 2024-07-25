#!/usr/bin/env bash

set -euo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR="$(cd ${SCRIPTDIR}/../..; pwd )"
[[ -n "${DEBUG:-}" ]] && set -x


# Initialize Terraform
terraform -chdir=$SCRIPTDIR init --upgrade

echo "Applying git resources"

# run different commands if on Cloud9 instance
if [[ $SCRIPTDIR == *"/home/ec2-user"* ]]; then
  apply_output=$(TF_VAR_ssh_key_basepath="/home/ec2-user/.ssh" terraform -chdir=$SCRIPTDIR apply -auto-approve 2>&1 | tee /dev/tty)
else
  apply_output=$(terraform -chdir=$SCRIPTDIR apply -auto-approve 2>&1 | tee /dev/tty)
fi

if [[ ${PIPESTATUS[0]} -eq 0 && $apply_output == *"Apply complete"* ]]; then
  # wait for ssh access allowed
  sleep 10
  echo "SUCCESS: Terraform apply of all modules completed successfully"
else
  echo "FAILED: Terraform apply of all modules failed"
  exit 1
fi

