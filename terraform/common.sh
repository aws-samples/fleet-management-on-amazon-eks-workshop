#!/usr/bin/env bash

set -uo pipefail

[[ -n "${DEBUG:-}" ]] && set -x


scale_down_karpenter_nodes() {

  # Delete the nodeclaims
  echo "Deleting Karpeneter NodePools"
  kubectl delete nodepools.karpenter.sh --all
  # do a final check to make sure the nodes are gone, loop sleep 60 in between checks
  nodes=$(kubectl get nodes -l karpenter.sh/registered=true -o jsonpath='{.items[*].metadata.name}')
  while [[ ! -z $nodes ]]; do
    kubectl delete nodepools.karpenter.sh --all
    echo "Waiting for nodes to be deleted: $nodes"
    sleep 60
    nodes=$(kubectl get nodes -l karpenter.sh/registered=true -o jsonpath='{.items[*].metadata.name}')
  done



}


# This is required for certain resources that are not managed by Terraform
force_delete_vpc() {
  VPC_NAME=$1
  VPCID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=${VPC_NAME}" --query "Vpcs[*].VpcId" --output text)
  if [ -n "$VPCID" ]; then
      echo "VPC ID: $VPCID"
      echo "Cleaning VPC endpoints if exists..."

      # Use AWS_REGION if set, otherwise default to the region from AWS CLI configuration
      REGION=${AWS_REGION:-$(aws configure get region)}

      vpc_endpoint_names=(
          "com.amazonaws.$REGION.guardduty-data"
          "com.amazonaws.$REGION.ssm"
          "com.amazonaws.$REGION.ec2messages"
          "com.amazonaws.$REGION.ssmmessages"
          "com.amazonaws.$REGION.s3"
      )

      for endpoint_name in "${vpc_endpoint_names[@]}"; do
          endpoint_exists=$(aws ec2 describe-vpc-endpoints --filters "Name=service-name,Values=$endpoint_name" "Name=vpc-id,Values=$VPCID" --query "VpcEndpoints[*].VpcEndpointId" --output text 2>/dev/null)
          if [ -n "$endpoint_exists" ]; then
              echo "Deleting VPC endpoint $endpoint_exists..."
              aws ec2 delete-vpc-endpoints --vpc-endpoint-ids "$endpoint_exists"
          fi
      done

      # check if aws-delete-vpc is available if not install it with go install github.com/megaproaktiv/aws-delete-vpc
      if ! command -v aws-delete-vpc &> /dev/null; then
          echo "aws-delete-vpc could not be found, installing it..."
          go install github.com/isovalent/aws-delete-vpc@latest
      fi
      echo "Cleaning VPC $VPCID"
      aws-delete-vpc -vpc-id=$VPCID
  fi
}