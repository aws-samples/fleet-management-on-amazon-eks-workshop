
#!/usr/bin/env bash

# Function to check if a cluster context exists
cluster_context_exists() {
    local cluster_name=$1
    kubectl config get-contexts -o name | grep -q "^${cluster_name}$"
}

# Function to update kubeconfig if context doesn't exist
update_kubeconfig_if_needed() {
    local cluster_name=$1
    local alias_name=$2

    if ! cluster_context_exists "$alias_name"; then
        echo "Updating kubeconfig for $cluster_name"
        aws eks --region $AWS_REGION update-kubeconfig --name "$cluster_name" --alias "$alias_name"
    fi
}

update_kubeconfig_if_needed_with_role() {
    local cluster_name=$1
    local alias_name=$2
    local user_alias=$3
    local role_arn=$4

    if ! cluster_context_exists "$alias_name"; then
        echo "Updating kubeconfig for $alias_name"
        aws eks --region $AWS_REGION update-kubeconfig --name "$cluster_name" --alias "$alias_name" --user-alias "$user_alias" --role-arn "$role_arn"
    fi
}

# Update kubeconfig for each cluster

# Setup kubectx for EKS clusters as Team
export BACKEND_TEAM_ROLE_ARN=$(aws ssm --region $AWS_REGION get-parameter --name eks-fleet-workshop-gitops-backend-team-view-role --with-decryption --query "Parameter.Value" --output text)
# Update kubeconfig for backend team
update_kubeconfig_if_needed_with_role "fleet-spoke-staging" "fleet-staging-cluster-backend" "fleet-staging-cluster-backend" "$BACKEND_TEAM_ROLE_ARN"
update_kubeconfig_if_needed_with_role "fleet-spoke-prod" "fleet-prod-cluster-backend" "fleet-prod-cluster-backend" "$BACKEND_TEAM_ROLE_ARN"

export FRONTEND_TEAM_ROLE_ARN=$(aws ssm --region $AWS_REGION get-parameter --name eks-fleet-workshop-gitops-frontend-team-view-role --with-decryption --query "Parameter.Value" --output text)
update_kubeconfig_if_needed_with_role "fleet-spoke-staging" "fleet-staging-cluster-frontend" "fleet-staging-cluster-frontend" "$FRONTEND_TEAM_ROLE_ARN"
update_kubeconfig_if_needed_with_role "fleet-spoke-prod" "fleet-prod-cluster-frontend" "fleet-prod-cluster-frontend" "$FRONTEND_TEAM_ROLE_ARN"

# Setup kubectx for EKS clusters as Admin
update_kubeconfig_if_needed "fleet-spoke-prod" "fleet-prod-cluster"
update_kubeconfig_if_needed "fleet-spoke-staging" "fleet-staging-cluster"
update_kubeconfig_if_needed "fleet-hub-cluster" "fleet-hub-cluster"