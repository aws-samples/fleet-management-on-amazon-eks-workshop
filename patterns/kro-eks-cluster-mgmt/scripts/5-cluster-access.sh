#!/bin/bash

#############################################################################
# Configure EKS Cluster Access
#############################################################################
#
# DESCRIPTION:
#   This script configures access to the EKS clusters created in the previous
#   steps. It:
#   1. Creates access entries for the ide-user role in each EKS cluster
#   2. Associates the AmazonEKSClusterAdminPolicy with the ide-user role
#   3. Updates the kubeconfig file to enable kubectl access
#
# USAGE:
#   ./5-cluster-access.sh
#   or from any directory:
#   /path/to/5-cluster-access.sh
#
# PREREQUISITES:
#   - The Argo Rollouts demo application must be deployed (run 4-deploy-argo-rollouts-demo.sh first)
#   - AWS CLI must be configured with appropriate credentials
#
# SEQUENCE:
#   This is the final script (5) in the setup sequence.
#   Run after 4-deploy-argo-rollouts-demo.sh
#
# NEXT STEPS:
#   After running this script, you can use the following scripts to:
#   - eks-cluster-access-setup.sh: Configure access to all EKS clusters
#   - multi-cluster-dashboard-generator.sh: Generate a dashboard for all clusters
#
#############################################################################

# Source the colors script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/colors.sh"

print_header "Configuring EKS Cluster Access"

print_step "Running cluster access setup script..."
# Run the eks-cluster-access-setup.sh script to configure access to all clusters
"$SCRIPT_DIR/eks-cluster-access-setup.sh"

print_info "Waiting for cluster access setup to complete..."
sleep 10  # Give some time for kubeconfig to update

print_step "Generating multi-cluster dashboard..."
# Generate a dashboard for all clusters
"$SCRIPT_DIR/multi-cluster-dashboard-generator.sh"

# The dashboard is generated in the original location
DASHBOARD_PATH="/home/ec2-user/environment/eks-cluster-mgmt/scripts/dashboard.html"

print_success "EKS cluster access configuration completed."
print_info "You can now access all clusters using kubectl."
print_info "The multi-cluster dashboard is available at: ${BOLD}$DASHBOARD_PATH${NC}"
