
#!/usr/bin/env bash

# Get cluster names from environment variables or use defaults
HUB_CLUSTER_NAME=${HUB_CLUSTER_NAME:-fleet-hub-cluster}
SPOKE_CLUSTER_PREFIX=${SPOKE_CLUSTER_NAME_PREFIX:-fleet-spoke}
SPOKE_STAGING_CLUSTER="${SPOKE_CLUSTER_PREFIX}-staging"
SPOKE_PROD_CLUSTER="${SPOKE_CLUSTER_PREFIX}-prod"

# kube context ALIASES are what the workshop pages type (kubectl --context fleet-staging-cluster).
# They stay fixed whatever the EKS cluster names are, so the content never changes with a prefix.
export HUB_CONTEXT=${HUB_CONTEXT:-fleet-hub-cluster}
export STAGING_CONTEXT=${STAGING_CONTEXT:-fleet-staging-cluster}
export PROD_CONTEXT=${PROD_CONTEXT:-fleet-prod-cluster}

echo "Using the following cluster names:"
echo "- Hub cluster: $HUB_CLUSTER_NAME"
echo "- Spoke staging cluster: $SPOKE_STAGING_CLUSTER"
echo "- Spoke prod cluster: $SPOKE_PROD_CLUSTER"

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
update_kubeconfig_if_needed_with_role "$SPOKE_STAGING_CLUSTER" "${STAGING_CONTEXT}-backend" "${STAGING_CONTEXT}-backend" "$BACKEND_TEAM_ROLE_ARN"
update_kubeconfig_if_needed_with_role "$SPOKE_PROD_CLUSTER" "${PROD_CONTEXT}-backend" "${PROD_CONTEXT}-backend" "$BACKEND_TEAM_ROLE_ARN"

export FRONTEND_TEAM_ROLE_ARN=$(aws ssm --region $AWS_REGION get-parameter --name eks-fleet-workshop-gitops-frontend-team-view-role --with-decryption --query "Parameter.Value" --output text)
update_kubeconfig_if_needed_with_role "$SPOKE_STAGING_CLUSTER" "${STAGING_CONTEXT}-frontend" "${STAGING_CONTEXT}-frontend" "$FRONTEND_TEAM_ROLE_ARN"
update_kubeconfig_if_needed_with_role "$SPOKE_PROD_CLUSTER" "${PROD_CONTEXT}-frontend" "${PROD_CONTEXT}-frontend" "$FRONTEND_TEAM_ROLE_ARN"

# Setup kubectx for EKS clusters as Admin
update_kubeconfig_if_needed "$SPOKE_PROD_CLUSTER" "$PROD_CONTEXT"
update_kubeconfig_if_needed "$SPOKE_STAGING_CLUSTER" "$STAGING_CONTEXT"
update_kubeconfig_if_needed "$HUB_CLUSTER_NAME" "$HUB_CONTEXT"