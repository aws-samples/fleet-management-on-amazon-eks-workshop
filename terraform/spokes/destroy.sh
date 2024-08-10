#!/usr/bin/env bash

set -uo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR="$(cd ${SCRIPTDIR}/../..; pwd )"
[[ -n "${DEBUG:-}" ]] && set -x

if [[ $# -eq 0 ]] ; then
    echo "No arguments supplied"
    echo "Usage: destroy.sh <environment>"
    echo "Example: destroy.sh dev"
    exit 1
fi
env=$1
echo "Destroying $env ..."

terraform -chdir=$SCRIPTDIR workspace select -or-create $env 
# Delete the Ingress/SVC before removing the addons
TMPFILE=$(mktemp)
terraform -chdir=$SCRIPTDIR output -raw configure_kubectl > "$TMPFILE"
# check if TMPFILE contains the string "No outputs found"
if [[ ! $(cat $TMPFILE) == *"No outputs found"* ]]; then
  echo "No outputs found, skipping kubectl delete"
  source "$TMPFILE"
  kubectl delete svc --all -n ui || true
  kubectl delete -A tables.dynamodb.services.k8s.aws --all || true
fi

terraform -chdir=$SCRIPTDIR destroy -target="module.gitops_bridge_bootstrap_hub" -auto-approve -var-file="workspaces/${env}.tfvars"
terraform -chdir=$SCRIPTDIR destroy -target="module.eks_blueprints_addons" -auto-approve -var-file="workspaces/${env}.tfvars"
terraform -chdir=$SCRIPTDIR destroy -target="module.eks" -auto-approve -var-file="workspaces/${env}.tfvars"

echo "remove VPC endpoints"
VPCID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=fleet-spoke-${env}" --query "Vpcs[*].VpcId" --output text)

if [ -n "$VPCID" ]; then
    echo "VPC ID: $VPCID"

    aws-delete-vpc -vpc-id=$VPCID

else
    echo "VPC with tag Name=fleet-spoke-${env} not found"
fi


terraform -chdir=$SCRIPTDIR destroy -target="module.vpc" -auto-approve -var-file="workspaces/${env}.tfvars"
terraform -chdir=$SCRIPTDIR destroy -auto-approve -var-file="workspaces/${env}.tfvars"
