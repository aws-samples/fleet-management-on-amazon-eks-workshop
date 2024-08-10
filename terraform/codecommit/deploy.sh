#!/usr/bin/env bash

set -euo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR="$(cd ${SCRIPTDIR}/../..; pwd )"
[[ -n "${DEBUG:-}" ]] && set -x


# Initialize Terraform
terraform -chdir=$SCRIPTDIR init --upgrade

echo "Applying git resources"

terraform -chdir=$SCRIPTDIR apply -auto-approve


if [[ ${PIPESTATUS[0]} -eq 0 ]]; then
  # wait for ssh access allowed
  sleep 10
  echo "SUCCESS: Terraform apply of all modules completed successfully"
else
  echo "FAILED: Terraform apply of all modules failed"
  exit 1
fi

