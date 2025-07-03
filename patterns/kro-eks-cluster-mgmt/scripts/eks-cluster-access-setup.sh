#!/bin/bash

#############################################################################
# EKS Cluster Access Setup Script
#############################################################################
#
# DESCRIPTION:
#   This script automates the process of setting up access to all EKS clusters
#   defined in the values.yaml file. It performs the following operations:
#
#   1. Parses the values.yaml file to identify all EKS clusters
#   2. Verifies each cluster exists in the specified region
#   3. Adds the current user (ide-user) to each cluster's access entries
#   4. Associates the admin policy with the user for each cluster
#   5. Updates the kubeconfig file to enable kubectl access
#   6. Verifies connectivity to each cluster
#
# USAGE:
#   ./eks-cluster-access-setup.sh
#
# NOTES:
#   - This script is idempotent and can be run multiple times without errors
#   - It will skip clusters that don't exist or can't be accessed
#   - The script assumes the AWS CLI is configured with appropriate credentials
#
#############################################################################

# Source the colors script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/colors.sh"

# Set AWS_PAGER to empty to disable paging
export AWS_PAGER=""

# Path to values.yaml file
VALUES_FILE="/home/ec2-user/environment/eks-cluster-mgmt/fleet/kro-values/tenants/tenant1/kro-clusters/values.yaml"

# Debug: Check if values.yaml exists and show its content
print_info "Checking if values.yaml exists at: $VALUES_FILE"
if [ -f "$VALUES_FILE" ]; then
    print_success "Values file found"
    print_info "First 20 lines of values.yaml:"
    head -n 20 "$VALUES_FILE"
else
    print_error "Values file NOT found at: $VALUES_FILE"
    print_info "Searching for values.yaml files:"
    find /home/ec2-user/environment -name "values.yaml" | grep -i cluster
fi

# Function to check if a cluster exists
check_cluster_exists() {
    local cluster_name="$1"
    local region="$2"
    
    print_info "Checking if cluster $cluster_name exists in region $region..."
    if aws eks describe-cluster --name "$cluster_name" --region "$region" &> /dev/null; then
        print_success "Cluster $cluster_name exists in region $region."
        return 0
    else
        print_error "Cluster $cluster_name does not exist in region $region."
        return 1
    fi
}

# Function to add ide-user to cluster access entries
add_ide_user_to_cluster() {
    local cluster_name="$1"
    local account_id="$2"
    local region="$3"
    
    print_step "Adding ide-user to access entries for $cluster_name in $region..."
    
    # Debug: Show current AWS identity
    print_info "Current AWS identity:"
    aws sts get-caller-identity
    
    # Use the proper IAM role ARN format instead of the STS assumed role
    local role_arn="arn:aws:iam::${account_id}:role/ide-user"
    print_info "Using role ARN: $role_arn"
    
    # Check if access entry already exists
    print_info "Checking if access entry already exists..."
    if aws eks describe-access-entry --cluster-name "$cluster_name" --principal-arn "$role_arn" --region "$region" &> /dev/null; then
        print_warning "Access entry for ide-user already exists in $cluster_name"
        
        # Check if admin policy is associated
        print_info "Checking if admin policy is associated..."
        if ! aws eks list-associated-access-policies --cluster-name "$cluster_name" --principal-arn "$role_arn" --region "$region" | grep -q "AmazonEKSClusterAdminPolicy"; then
            print_info "Associating admin policy with ide-user..."
            aws eks associate-access-policy \
                --cluster-name "$cluster_name" \
                --principal-arn "$role_arn" \
                --policy-arn "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy" \
                --access-scope type=cluster \
                --region "$region"
            print_info "Admin policy association result: $?"
        else
            print_warning "Admin policy already associated with ide-user for $cluster_name"
        fi
    else
        # Create access entry
        print_info "Creating access entry for ide-user..."
        aws eks create-access-entry \
            --cluster-name "$cluster_name" \
            --principal-arn "$role_arn" \
            --region "$region"
        print_info "Access entry creation result: $?"
        
        # Associate admin policy
        print_info "Associating admin policy with ide-user..."
        aws eks associate-access-policy \
            --cluster-name "$cluster_name" \
            --principal-arn "$role_arn" \
            --policy-arn "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy" \
            --access-scope type=cluster \
            --region "$region"
        print_info "Admin policy association result: $?"
    fi
}

# Function to update kubeconfig for a cluster
update_kubeconfig() {
    local cluster_name="$1"
    local region="$2"
    
    print_step "Updating kubeconfig for $cluster_name..."
    aws eks update-kubeconfig --name "$cluster_name" --region "$region" --alias "$cluster_name"
    print_info "Update kubeconfig result: $?"
    
    # Debug: Show current kubeconfig contexts
    print_info "Available kubectl contexts:"
    kubectl config get-contexts
    
    # Verify connection
    print_info "Verifying connection to $cluster_name..."
    if kubectl --context="$cluster_name" get nodes &> /dev/null; then
        print_success "Successfully connected to $cluster_name"
        return 0
    else
        print_error "Failed to connect to $cluster_name"
        print_info "Detailed error output:"
        kubectl --context="$cluster_name" get nodes --v=8
        return 1
    fi
}

# Function to connect to a cluster and get information
connect_to_cluster() {
    local cluster_name="$1"
    local account_id="$2"
    local region="$3"
    
    echo -e "\n${BOLD}${GREEN}=========================================================${NC}"
    echo -e "${BOLD}${GREEN}Connecting to cluster: $cluster_name${NC}"
    echo -e "${BOLD}${GREEN}AWS Account ID: $account_id${NC}"
    echo -e "${BOLD}${GREEN}Region: $region${NC}"
    echo -e "${BOLD}${GREEN}=========================================================${NC}"
    
    # Check if cluster exists
    if ! check_cluster_exists "$cluster_name" "$region"; then
        print_error "Skipping $cluster_name as it does not exist."
        return 1
    fi
    
    # Add ide-user to cluster access entries
    add_ide_user_to_cluster "$cluster_name" "$account_id" "$region"
    
    # Update kubeconfig and verify connection
    if ! update_kubeconfig "$cluster_name" "$region"; then
        print_error "Could not establish connection to $cluster_name. Skipping further operations."
        return 1
    fi
    
    # Get cluster nodes
    print_step "Nodes in $cluster_name:"
    kubectl --context="$cluster_name" get nodes
    
    # Get services in all namespaces
    print_step "Services in $cluster_name:"
    kubectl --context="$cluster_name" get svc -A
    
    print_success "Successfully connected to $cluster_name"
    return 0
}

# Function to parse values.yaml and extract cluster information
parse_values_yaml() {
    # Check if values.yaml exists
    if [ ! -f "$VALUES_FILE" ]; then
        print_error "Values file not found: $VALUES_FILE"
        return
    fi
    
    print_header "Parsing values.yaml to extract cluster information"
    
    # Debug: Count active (non-commented) clusters in the file
    local cluster_count=$(grep -c "^[[:space:]]*cluster-" "$VALUES_FILE" | grep -v "^[[:space:]]*#")
    print_info "Found $cluster_count cluster entries in values.yaml"
    
    # Use a more targeted approach to extract cluster information
    local clusters_found=0
    
    # Get all active cluster names from the file (excluding commented lines)
    # The pattern matches lines that start with whitespace followed by "cluster-" but not lines with "#" before "cluster-"
    local cluster_names=$(grep "^[[:space:]]*cluster-[a-zA-Z0-9_-]*:" "$VALUES_FILE" | grep -v "^[[:space:]]*#" | sed 's/[[:space:]]*\(cluster-[a-zA-Z0-9_-]*\):.*/\1/')
    
    # Process each cluster
    for cluster_name in $cluster_names; do
        print_info "Processing cluster: $cluster_name"
        
        # Extract account ID for this cluster (only from non-commented lines)
        local account_id=$(grep -A 30 "$cluster_name:" "$VALUES_FILE" | grep "accountId:" | grep -v "^[[:space:]]*#" | head -1 | sed 's/.*accountId:[[:space:]]*"\([^"]*\)".*/\1/')
        
        # Extract region for this cluster (only from non-commented lines)
        local region=$(grep -A 30 "$cluster_name:" "$VALUES_FILE" | grep "region:" | grep -v "^[[:space:]]*#" | head -1 | sed 's/.*region:[[:space:]]*"\([^"]*\)".*/\1/')
        
        if [[ -n "$account_id" && -n "$region" ]]; then
            print_info "Found account ID for $cluster_name: $account_id"
            print_info "Found region for $cluster_name: $region"
            
            # Connect to the cluster
            connect_to_cluster "$cluster_name" "$account_id" "$region"
            clusters_found=$((clusters_found + 1))
        else
            print_warning "Could not find account ID or region for $cluster_name"
        fi
    done
    
    print_info "Total clusters processed from values.yaml: $clusters_found"
}

# Main script execution
print_header "Starting EKS cluster access setup"
print_warning "This script will connect to all clusters defined in values.yaml"
print_warning "It is idempotent and can be run multiple times without errors"

# Parse values.yaml and connect to clusters
parse_values_yaml

print_header "Default to hub cluster"
kubectx hub-cluster

print_success "EKS cluster access setup completed."
