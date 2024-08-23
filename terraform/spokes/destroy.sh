#!/usr/bin/env bash

set -uo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR="$(cd ${SCRIPTDIR}/../..; pwd )"
[[ -n "${DEBUG:-}" ]] && set -x

source "${ROOTDIR}/terraform/common.sh"

if [[ $# -eq 0 ]] ; then
    echo "No arguments supplied"
    echo "Usage: destroy.sh <environment>"
    echo "Example: destroy.sh dev"
    exit 1
fi
env=$1
echo "Destroying $env ..."

terraform -chdir=$SCRIPTDIR workspace select -or-create $env
terraform -chdir=$SCRIPTDIR init --upgrade
# Delete the Ingress/SVC before removing the addons
TMPFILE=$(mktemp)
terraform -chdir=$SCRIPTDIR output -raw configure_kubectl > "$TMPFILE"
# check if TMPFILE contains the string "No outputs found"
if [[ ! $(cat $TMPFILE) == *"No outputs found"* ]]; then
  source "$TMPFILE"
  scale_down_karpenter_nodes
  kubectl delete svc -n kube-fleet -l app.kubernetes.io/component=server
  # metric server leaves this behind
  kubectl delete apiservices.apiregistration.k8s.io v1beta1.metrics.k8s.io
fi

terraform -chdir=$SCRIPTDIR destroy -target="module.gitops_bridge_bootstrap_hub" -auto-approve -var-file="workspaces/${env}.tfvars"
terraform -chdir=$SCRIPTDIR destroy -target="module.eks_blueprints_addons" -auto-approve -var-file="workspaces/${env}.tfvars"
terraform -chdir=$SCRIPTDIR destroy -target="module.eks" -auto-approve -var-file="workspaces/${env}.tfvars"

echo "remove VPC endpoints"
VPCID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=fleet-spoke-${env}" --query "Vpcs[*].VpcId" --output text)
if [ -n "$VPCID" ]; then
    echo "VPC ID: $VPCID"

    echo "Cleaning VPC endpoints if exists..."
    vpc_endpoint_names=("com.amazonaws.eu-west-1.guardduty-data" "com.amazonaws.eu-west-1.ssm" "com.amazonaws.eu-west-1.ec2messages" "com.amazonaws.eu-west-1.ssmmessages" "com.amazonaws.eu-west-1.s3")
    for endpoint_name in "${vpc_endpoint_names[@]}"; do
        endpoint_exists=$(aws ec2 describe-vpc-endpoints --filters "Name=service-name,Values=$endpoint_name" "Name=vpc-id,Values=$VPCID" --query "VpcEndpoints[*].VpcEndpointId" --output text 2>/dev/null)

        if [ -n "$endpoint_exists" ]; then
            echo "Deleting VPC endpoint $endpoint_exists..."
            aws ec2 delete-vpc-endpoints --vpc-endpoint-ids "$endpoint_exists"
        fi
    done
else
    echo "VPC with tag Name=fleet-spoke-${env} not found"
fi 


terraform -chdir=$SCRIPTDIR destroy -target="module.vpc" -auto-approve -var-file="workspaces/${env}.tfvars"
terraform -chdir=$SCRIPTDIR destroy -auto-approve -var-file="workspaces/${env}.tfvars"
