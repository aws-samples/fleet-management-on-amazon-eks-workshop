#!/bin/bash

# Array of dataset IDs to delete
datasets=(
    "eks-fleet-argo-projects-data"
    "eks-fleet-clusters-data"
    "eks-fleet-clusters-details"
    "eks-fleet-clusters-summary-data"
    "eks-fleet-clusters-upgrade-insights"
    "eks-fleet-kubernetes-release-calendar"
    "eks-fleet-support-data"
)

# Loop through each dataset and delete it
for dataset in "${datasets[@]}"; do
    echo "Deleting dataset: $dataset"
    aws quicksight delete-data-set \
        --aws-account-id $AWS_ACCOUNT_ID \
        --data-set-id "$dataset"

    # Check the exit status
    if [ $? -eq 0 ]; then
        echo "Successfully deleted dataset: $dataset"
    else
        echo "Failed to delete dataset: $dataset"
    fi
    
    # Add a small delay between deletions
    sleep 2
done
