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
DEBUG=$DEBUG ${ROOTDIR}/terraform/codecommit/deploy.sh
echo "Configure Git"
source ${ROOTDIR}/setup-git.sh

# echo "youyou - check identity"
# aws sts get-caller-identity
# #arn:aws:sts::912939173604:assumed-role/workshop-team-stack-IDEFleet7IdeRoleC9AC90CF-xixImgYBYbAX/i-0d148cf3c85d58216
# # Get the IAM role of the instance
# INSTANCE_ROLE=$(aws sts get-caller-identity | jq ".Arn" -r | cut -d'/' -f1,2)
# # Check if the IAM role matches the expected pattern
# if [[ $INSTANCE_ROLE =~ ^arn:aws:iam::[0-9]+:role/workshop-team-stack-IDEFleet.* ]]; then
#     echo "IAM role matches the expected pattern: $INSTANCE_ROLE"

#     # List of EKS clusters to check
#     clusters=("fleet-hub-cluster" "fleet-spoke-prod" "fleet-spoke-staging")

#     # Check if EKS clusters exist and add the IAM role to the cluster access list
#     for cluster in "${clusters[@]}"; do
#         if aws eks describe-cluster --name "$cluster" --query "cluster.status" --output text 2>/dev/null; then
#             echo "EKS cluster '$cluster' exists. Adding IAM role to the access list..."
#             aws eks associate-iam-role-to-cluster --cluster-name "$cluster" --role-arn "$INSTANCE_ROLE" --role-name AmazonEKSClusterAdminPolicy
#         else
#             echo "EKS cluster '$cluster' does not exist."
#         fi
#     done
# else
#     echo "IAM role does not match the expected pattern: $INSTANCE_ROLE"
# fi

echo "Deploy Hub Cluster"
DEBUG=$DEBUG ${ROOTDIR}/terraform/hub/deploy.sh
echo "Deploy Spoke Staging"
DEBUG=$DEBUG ${ROOTDIR}/terraform/spokes/deploy.sh staging
echo "Deploy Spoke Prod"
DEBUG=$DEBUG ${ROOTDIR}/terraform/spokes/deploy.sh prod
echo "Configure Kubectl"
source ${ROOTDIR}/setup-kubectx.sh