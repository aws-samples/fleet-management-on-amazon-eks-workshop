#!/usr/bin/env bash

set -uo pipefail
set -o errexit

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR=$SCRIPTDIR
[[ -n "${DEBUG:-}" ]] && set -x

go install github.com/isovalent/aws-delete-vpc@latest

${ROOTDIR}/terraform/spokes/destroy.sh prod
${ROOTDIR}/terraform/spokes/destroy.sh staging
${ROOTDIR}/terraform/hub/destroy.sh
${ROOTDIR}/terraform/codecommit/destroy.sh



# Variables
SSH_PRIVATE_KEY_FILE="$HOME/.ssh/gitops_ssh.pem"
SSH_CONFIG_FILE="$HOME/.ssh/config"
SSH_CONFIG_START_BLOCK="### START BLOCK AWS Workshop ###"
SSH_CONFIG_END_BLOCK="### END BLOCK AWS Workshop ###"

# Function to remove files and blocks
remove_files_and_blocks() {
    # Remove SSH private key file
    if [ -f "$SSH_PRIVATE_KEY_FILE" ]; then
        rm -f "$SSH_PRIVATE_KEY_FILE"
        echo "Removed $SSH_PRIVATE_KEY_FILE"
    else
        echo "$SSH_PRIVATE_KEY_FILE does not exist"
    fi

    # Remove AWS Workshop block from SSH config file
    if [ -f "$SSH_CONFIG_FILE" ]; then
        if grep -q "$SSH_CONFIG_START_BLOCK" "$SSH_CONFIG_FILE"; then
            sed -i "/$SSH_CONFIG_START_BLOCK/,/$SSH_CONFIG_END_BLOCK/d" "$SSH_CONFIG_FILE"
            echo "Removed AWS Workshop block from $SSH_CONFIG_FILE"
        else
            echo "AWS Workshop block not found in $SSH_CONFIG_FILE"
        fi
    else
        echo "$SSH_CONFIG_FILE does not exist"
    fi
}

# Call the function
remove_files_and_blocks