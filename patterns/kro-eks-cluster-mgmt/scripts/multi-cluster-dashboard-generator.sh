#!/bin/bash

#############################################################################
# Multi-Cluster Dashboard Generator
#############################################################################
#
# DESCRIPTION:
#   This script generates an HTML dashboard that displays Argo Rollouts demo
#   applications from multiple EKS clusters in different regions. The dashboard
#   uses iframes to show all environments side by side for easy comparison.
#
#   The script performs the following operations:
#   1. Connects to each EKS cluster defined in the values.yaml file
#   2. Retrieves the ALB ingress URL for the rollouts-demo application
#   3. Generates an HTML dashboard with iframes for each environment
#   4. Saves the dashboard to an HTML file for viewing in a browser
#
# USAGE:
#   ./multi-cluster-dashboard-generator.sh [--manual]
#
#   Options:
#     --manual    Skip EKS cluster existence check and assume kubectl is already
#                 configured to connect to the clusters
#
# PREREQUISITES:
#   - AWS CLI configured with appropriate credentials
#   - kubectl installed and configured
#   - jq installed for JSON processing
#   - Access to the EKS clusters (run eks-cluster-access-setup.sh first)
#
# OUTPUT:
#   - HTML dashboard file at /home/ec2-user/environment/dashboard.html
#
#############################################################################

# Source the colors script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/colors.sh"

# Set AWS_PAGER to empty to disable paging
export AWS_PAGER=""

# Parse command line arguments
MANUAL_MODE=false
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --manual) MANUAL_MODE=true; shift ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
done

if [ "$MANUAL_MODE" = true ]; then
    print_info "Running in manual mode. Skipping EKS cluster existence checks."
fi

# Path to output HTML file
OUTPUT_HTML="$WORKSPACE_PATH/dashboard.html"

# Temporary file to store cluster information
TEMP_FILE="/tmp/cluster_info.json"

# Initialize the JSON array
echo "[]" > "$TEMP_FILE"

# Ensure the directory exists
mkdir -p "$(dirname "$OUTPUT_HTML")"

# Function to check if a cluster exists
check_cluster_exists() {
    local cluster_name="$1"
    local region="$2"
    
    # Skip check if in manual mode
    if [ "$MANUAL_MODE" = true ]; then
        print_info "Manual mode: Assuming cluster $cluster_name exists."
        return 0
    fi
    
    print_info "Checking if cluster $cluster_name exists in region $region..."
    if aws eks describe-cluster --name "$cluster_name" --region "$region" &> /dev/null; then
        print_success "Cluster $cluster_name exists in region $region."
        return 0
    else
        print_error "Cluster $cluster_name does not exist in region $region."
        return 1
    fi
}

# Function to get the Argo demo app URL for a cluster
get_argo_demo_url() {
    local cluster_name="$1"
    local region="$2"
    local environment="$3"
    
    print_info "Getting Argo demo app URL for $cluster_name in $region..."
    
    # Check if kubectl is already working for this cluster
    if ! kubectl --context="$cluster_name" get nodes &> /dev/null; then
        print_info "kubectl not working for $cluster_name, updating kubeconfig..."
        # Update kubeconfig for this cluster
        aws eks update-kubeconfig --name "$cluster_name" --region "$region" --alias "$cluster_name" > /dev/null
    else
        print_info "kubectl already working for $cluster_name, skipping kubeconfig update"
    fi
    
    # Check if we can connect to the cluster
    if ! kubectl --context="$cluster_name" get nodes &> /dev/null; then
        print_error "Failed to connect to $cluster_name. Skipping URL retrieval."
        return 1
    fi
    
    # Get the ALB ingress URL for the rollouts-demo
    local ingress_url
    ingress_url=$(kubectl --context="$cluster_name" get ingress -n rollouts-demo rollouts-demo -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
    
    if [[ -z "$ingress_url" ]]; then
        print_warning "No ingress URL found for rollouts-demo in $cluster_name. Checking ALB ingress..."
        ingress_url=$(kubectl --context="$cluster_name" get ingress.networking.k8s.io -n rollouts-demo rollouts-demo -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
    fi
    
    if [[ -z "$ingress_url" ]]; then
        print_error "No ingress URL found for rollouts-demo in $cluster_name."
        return 1
    fi
    
    print_success "Found Argo demo app URL for $cluster_name: http://$ingress_url"
    
    # Add the cluster information to the JSON file
    local temp_json
    temp_json=$(cat "$TEMP_FILE")
    local new_entry="{\"name\":\"$cluster_name\",\"environment\":\"$environment\",\"region\":\"$region\",\"url\":\"http://$ingress_url\"}"
    local updated_json
    updated_json=$(echo "$temp_json" | jq ". + [$new_entry]")
    echo "$updated_json" > "$TEMP_FILE"
    
    return 0
}

# Function to manually add known clusters
add_known_clusters() {
    print_header "Adding known clusters to the dashboard"
    
    # cluster-test in eu-central-1
    if check_cluster_exists "cluster-test" "eu-central-1"; then
        get_argo_demo_url "cluster-test" "eu-central-1" "test"
    fi
    
    # cluster-pre-prod in us-west-2
    if check_cluster_exists "cluster-pre-prod" "us-west-2"; then
        get_argo_demo_url "cluster-pre-prod" "us-west-2" "pre-prod"
    fi
    
    # cluster-prod-us in us-west-2
    if check_cluster_exists "cluster-prod-us" "us-west-2"; then
        get_argo_demo_url "cluster-prod-us" "us-west-2" "prod-US"
    fi
    
    # cluster-prod-eu in eu-west-1
    if check_cluster_exists "cluster-prod-eu" "eu-west-1"; then
        get_argo_demo_url "cluster-prod-eu" "eu-west-1" "prod-EU"
    fi
}

# Function to generate the HTML dashboard
generate_dashboard() {
    print_header "Generating HTML dashboard"
    
    # Read the cluster information from the JSON file
    local clusters
    clusters=$(cat "$TEMP_FILE")
    
    # Start the HTML content
    cat > "$OUTPUT_HTML" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Multi-Region Dashboard</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        html, body {
            height: 100%;
            width: 100%;
            overflow: hidden;
            margin: 0;
            padding: 0;
        }
        
        body {
            font-family: Arial, sans-serif;
            background-color: #f5f5f5;
        }
        
        .container {
            display: flex;
            flex-direction: row;
            width: 100%;
            height: 100vh;
            overflow-x: auto;
        }
        
        .frame-container {
            background-color: white;
            flex: 1;
            min-width: 25%;
            height: 100%;
            display: flex;
            flex-direction: column;
            border-right: 1px solid #ddd;
        }
        
        .frame-title {
            background-color: #232f3e;
            color: white;
            padding: 10px;
            font-size: 14px;
            font-weight: bold;
            text-align: center;
        }
        
        iframe {
            flex: 1;
            width: 100%;
            height: 100%;
            border: none;
            display: block;
        }
        
        /* Responsive adjustments */
        @media (max-width: 1200px) {
            .container {
                flex-wrap: wrap;
                height: 100vh;
                overflow-y: auto;
            }
            
            .frame-container {
                min-width: 50%;
                height: 50vh;
            }
        }
        
        @media (max-width: 768px) {
            .frame-container {
                min-width: 100%;
                height: 50vh;
            }
        }
    </style>
</head>
<body>
    <div class="container">
EOF
    
    # Add each cluster to the HTML
    echo "$clusters" | jq -c '.[]' | while read -r cluster; do
        local name
        local environment
        local url
        name=$(echo "$cluster" | jq -r '.name')
        environment=$(echo "$cluster" | jq -r '.environment')
        url=$(echo "$cluster" | jq -r '.url')
        
        cat >> "$OUTPUT_HTML" << EOF
        <div class="frame-container">
            <div class="frame-title">$environment</div>
            <iframe src="$url" title="$environment"></iframe>
        </div>
EOF
    done
    
    # Close the HTML
    cat >> "$OUTPUT_HTML" << EOF
    </div>
</body>
</html>
EOF
    
    print_success "HTML dashboard generated: $OUTPUT_HTML"
}

# Main script execution
print_header "Starting multi-cluster dashboard generation"

# Add known clusters
add_known_clusters

# Generate the HTML dashboard
generate_dashboard

print_header "Default to hub cluster"
kubectx hub-cluster

print_success "Dashboard generation completed."
print_info "Dashboard available at: ${BOLD}$OUTPUT_HTML${NC}"
print_info "Open this file in a web browser to view all environments side by side."

