#!/bin/bash

# Array of data source IDs to delete
datasources=(
    "eks-fleet-kubernetes-release-calendar"
    "eks-fleet-argo-projects-data"
    "eks-fleet-clusters-details"
    "eks-fleet-support-data"
    "eks-fleet-clusters-summary-data"
    "eks-fleet-clusters-upgrade-insights"
    "eks-fleet-clusters-data"
)

# Loop through each data source and delete it
for datasource in "${datasources[@]}"; do
    echo "Deleting data source: $datasource"
    aws quicksight delete-data-source \
        --aws-account-id $AWS_ACCOUNT_ID \
        --data-source-id "$datasource"

    # Check the exit status
    if [ $? -eq 0 ]; then
        echo "Successfully deleted $datasource"
    else
        echo "Failed to delete $datasource"
    fi
    
    # Add a small delay between deletions
    sleep 2
done
