#!/usr/bin/env bash

set -uo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR="$(cd ${SCRIPTDIR}/../..; pwd )"
[[ -n "${DEBUG:-}" ]] && set -x

source "${ROOTDIR}/terraform/common.sh"


# Delete the Ingress/SVC before removing the addons
TMPFILE=$(mktemp)
terraform -chdir=$SCRIPTDIR output -raw configure_kubectl > "$TMPFILE"
# check if TMPFILE contains the string "No outputs found"
if [[ ! $(cat $TMPFILE) == *"No outputs found"* ]]; then
  source "$TMPFILE"
  scale_down_karpenter_nodes
  kubectl delete svc -n argocd -l app.kubernetes.io/component=server
  # metric server leaves this behind
  kubectl delete apiservices.apiregistration.k8s.io v1beta1.metrics.k8s.io
fi


terraform -chdir=$SCRIPTDIR destroy -target="module.gitops_bridge_bootstrap" -auto-approve
terraform -chdir=$SCRIPTDIR destroy -target="module.eks_blueprints_addons" -auto-approve
terraform -chdir=$SCRIPTDIR destroy -target="module.eks" -auto-approve

echo "remove VPC endpoints"
VPCID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=fleet-hub-cluster" --query "Vpcs[*].VpcId" --output text)

if [ -n "$VPCID" ]; then
    echo "VPC ID: $VPCID"
    for endpoint in $(aws ec2 describe-vpc-endpoints --filters "Name=vpc-id,Values=$VPCID" --query "VpcEndpoints[*].VpcEndpointId" --output text); do
      aws ec2 delete-vpc-endpoints --vpc-endpoint-ids $endpoint || true
    done

    echo "remove Dandling security groups"
    # Get the list of security group IDs associated with the VPC
    security_group_ids=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPCID" --query "SecurityGroups[?not_null(GroupName)&&GroupName!='default'].GroupId" --output json)

    # Check if any security groups were found
    if [ -z "$security_group_ids" ]; then
      echo "No security groups found in VPC $VPCID"
    else
      echo "security_group_ids=$security_group_ids"

      # Loop through the security group IDs and delete each security group
      for group_id in $(echo "$security_group_ids" | jq -r '.[]'); do
        echo "Deleting security group $group_id"
        aws ec2 delete-security-group --group-id "$group_id" || true
      done
    fi
else
    echo "VPC with tag Name=fleet-hub-cluster not found"
fi

terraform -chdir=$SCRIPTDIR destroy -target="module.vpc" -auto-approve
terraform -chdir=$SCRIPTDIR destroy -auto-approve
