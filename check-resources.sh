#!/bin/bash

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# List of clusters to check
clusters=("fleet-hub-cluster" "fleet-spoke-prod" "fleet-spoke-staging")

# Check if EKS clusters exist
echo "Checking if EKS clusters exist..."
all_clusters=$(aws eks list-clusters --output text --query 'clusters[*]')

for cluster in "${clusters[@]}"; do
    if echo "$all_clusters" | grep -q "$cluster"; then
        echo -e "${GREEN}EKS cluster '$cluster' exists.${NC}"
    else
        echo -e "${RED}EKS cluster '$cluster' does not exist.${NC}"
    fi
done

echo ""

# Check if CodeCommit repositories exist
echo "Checking if CodeCommit repositories exist..."
repo_names=("fleet-gitops-apps" "fleet-gitops-platform" "fleet-gitops-addons")

for repo_name in "${repo_names[@]}"; do
    repo_exists=$(aws codecommit get-repository --repository-name "$repo_name" 2>/dev/null)

    if [ -z "$repo_exists" ]; then
        echo -e "${RED}CodeCommit repository '$repo_name' does not exist.${NC}"
    else
        echo -e "${GREEN}CodeCommit repository '$repo_name' exists.${NC}"
    fi
done

echo ""

# Check if IAM roles exist
echo "Checking if IAM roles exist..."
role_names=("fleet-hub-cluster-eso" "fleet-spoke-prod-argocd-spoke" "fleet-spoke-staging-argocd-spoke")

for role_name in "${role_names[@]}"; do
    role_exists=$(aws iam get-role --role-name "$role_name" 2>/dev/null)

    if [ -z "$role_exists" ]; then
        echo -e "${RED}IAM role '$role_name' does not exist.${NC}"
    else
        echo -e "${GREEN}IAM role '$role_name' exists.${NC}"
    fi
done

echo ""

# Check if KMS key aliases exist
echo "Checking if KMS key aliases exist..."
alias_names=("alias/eks/fleet-spoke-prod" "alias/eks/fleet-spoke-staging" "alias/eks/fleet-hub-cluster")

for alias_name in "${alias_names[@]}"; do
    alias_exists=$(aws kms list-aliases --query "Aliases[?AliasName=='$alias_name']" --output text 2>/dev/null)

    if [ -z "$alias_exists" ]; then
        echo -e "${RED}KMS key alias '$alias_name' does not exist.${NC}"
    else
        echo -e "${GREEN}KMS key alias '$alias_name' exists.${NC}"
    fi
done

echo ""

# Check if Secrets Manager secrets exist
echo "Checking if Secrets Manager secrets exist..."
secret_names=("hub-cluster/spoke-prod" "hub-cluster/spoke-staging")

for secret_name in "${secret_names[@]}"; do
    secret_exists=$(aws secretsmanager describe-secret --secret-id "$secret_name" 2>/dev/null)

    if [ -z "$secret_exists" ]; then
        echo -e "${RED}Secrets Manager secret '$secret_name' does not exist.${NC}"
    else
        echo -e "${GREEN}Secrets Manager secret '$secret_name' exists.${NC}"
    fi
done

echo ""

# Check if CloudWatch log groups exist
echo "Checking if CloudWatch log groups exist..."
log_group_names=("/aws/eks/fleet-spoke-cluster-prod" "/aws/eks/fleet-spoke-cluster-staging" "/aws/eks/fleet-hub-cluster")

for log_group_name in "${log_group_names[@]}"; do
    log_group_exists=$(aws logs describe-log-groups --log-group-name-prefix "$log_group_name" --query "logGroups[?logGroupName=='$log_group_name']" --output text 2>/dev/null)

    if [ -z "$log_group_exists" ]; then
        echo -e "${RED}CloudWatch log group '$log_group_name' does not exist.${NC}"
    else
        echo -e "${GREEN}CloudWatch log group '$log_group_name' exists.${NC}"
    fi
done

echo ""

# Check if VPC endpoints exist
echo "Checking if VPC endpoints exist..."
vpc_endpoint_names=("com.amazonaws.eu-west-1.guardduty-data" "com.amazonaws.eu-west-1.ssm" "com.amazonaws.eu-west-1.ec2messages" "com.amazonaws.eu-west-1.ssmmessages" "com.amazonaws.eu-west-1.s3")
vpc_names=("fleet-spoke-prod" "fleet-spoke-staging" "fleet-hub-cluster")

for vpc_name in "${vpc_names[@]}"; do
    vpc_id=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=$vpc_name" --query "Vpcs[*].VpcId" --output text)
    vpc_endpoint_ids=()
    for endpoint_name in "${vpc_endpoint_names[@]}"; do
        endpoint_exists=$(aws ec2 describe-vpc-endpoints --filters "Name=service-name,Values=$endpoint_name" "Name=vpc-id,Values=$vpc_id" --query "VpcEndpoints[*].VpcEndpointId" --output text 2>/dev/null)

        if [ -z "$endpoint_exists" ]; then
            echo -e "${RED}VPC endpoint '$endpoint_name' does not exist in VPC '$vpc_name'.${NC}"
        else
            echo -e "${GREEN}VPC endpoint '$endpoint_name' exists in VPC '$vpc_name'.${NC}"
            vpc_endpoint_ids+=("$endpoint_exists")
        fi
    done
done
