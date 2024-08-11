#!/usr/bin/env bash

set -uo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR="$(cd ${SCRIPTDIR}/../..; pwd )"
[[ -n "${DEBUG:-}" ]] && set -x

# Delete the Ingress/SVC before removing the addons
TMPFILE=$(mktemp)
terraform -chdir=$SCRIPTDIR output -raw configure_kubectl > "$TMPFILE"
# check if TMPFILE contains the string "No outputs found"
if [[ ! $(cat $TMPFILE) == *"No outputs found"* ]]; then
  echo "No outputs found, skipping kubectl delete"
  source "$TMPFILE"
  kubectl delete svc -n argocd argo-cd-argocd-server || true
fi


terraform -chdir=$SCRIPTDIR destroy -target="module.gitops_bridge_bootstrap" -auto-approve
terraform -chdir=$SCRIPTDIR destroy -target="module.eks_blueprints_addons" -auto-approve
terraform -chdir=$SCRIPTDIR destroy -target="module.eks" -auto-approve

echo "remove VPC endpoints"
VPCID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=fleet-hub-cluster" --query "Vpcs[*].VpcId" --output text)

echo "Checking if VPC endpoints exist..."
vpc_endpoint_names=("com.amazonaws.eu-west-1.guardduty-data" "com.amazonaws.eu-west-1.ssm" "com.amazonaws.eu-west-1.ec2messages" "com.amazonaws.eu-west-1.ssmmessages" "com.amazonaws.eu-west-1.s3")
for endpoint_name in "${vpc_endpoint_names[@]}"; do
    endpoint_exists=$(aws ec2 describe-vpc-endpoints --filters "Name=service-name,Values=$endpoint_name" "Name=vpc-id,Values=$vpc_id" --query "VpcEndpoints[*].VpcEndpointId" --output text 2>/dev/null)

    if [ -n "$endpoint_exists" ]; then
        echo "Deleting VPC endpoint $vpc_endpoint_id..."
        aws ec2 delete-vpc-endpoints --vpc-endpoint-ids "$vpc_endpoint_id"
    fi
done

if [ -n "$VPCID" ]; then
    echo "VPC ID: $VPCID"
    aws-delete-vpc -vpc-id=$VPCID
else
    echo "VPC with tag Name=fleet-hub-cluster not found"
fi    

terraform -chdir=$SCRIPTDIR destroy -target="module.vpc" -auto-approve
terraform -chdir=$SCRIPTDIR destroy -auto-approve
