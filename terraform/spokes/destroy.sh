#!/usr/bin/env bash

set -euo pipefail

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

    for endpoint in $(aws ec2 describe-vpc-endpoints --filters "Name=vpc-id,Values=$VPCID" --query "VpcEndpoints[*].VpcEndpointId" --output text); do
        aws ec2 delete-vpc-endpoints --vpc-endpoint-ids $endpoint || true
    done

    echo "remove Dangling security groups"
    security_group_ids=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPCID" --query "SecurityGroups[?not_null(GroupName)&&GroupName!='default'].GroupId" --output json)

    if [ -n "$security_group_ids" ]; then
        echo "security_group_ids=$security_group_ids"

        for group_id in $(echo "$security_group_ids" | jq -r '.[]'); do
            echo "Deleting security group $group_id"
            aws ec2 delete-security-group --group-id "$group_id" || true
        done
    else
        echo "No security groups found in VPC $VPCID"
    fi
else
    echo "VPC with tag Name=fleet-spoke-${env} not found"
fi


terraform -chdir=$SCRIPTDIR destroy -target="module.vpc" -auto-approve -var-file="workspaces/${env}.tfvars"
terraform -chdir=$SCRIPTDIR destroy -auto-approve -var-file="workspaces/${env}.tfvars"
