#!/usr/bin/env bash

set -uo pipefail

[[ -n "${DEBUG:-}" ]] && set -x


scale_down_karpenter_nodes() {
  # This function will scale down all deployments and statefulsets running on the nodes with the label karpenter.sh/registered=true
  echo "Scaling down deployments and statefulsets on nodes with karpenter.sh/registered=true label"

  # Get all nodes with the label karpenter.sh/registered=true
  nodes=$(kubectl get nodes -l karpenter.sh/registered=true -o jsonpath='{.items[*].metadata.name}')

  # Iterate over each node
  for node in $nodes; do
    # Get all pods running on the current node
    pods=$(kubectl get pods --all-namespaces --field-selector spec.nodeName=$node -o jsonpath='{range .items[*]}{.metadata.namespace}{" "}{.metadata.name}{"\n"}{end}')

    # Iterate over each pod
    while IFS= read -r pod; do
      namespace=$(echo $pod | awk '{print $1}')
      # skip if namespace is argocd, usefull for the gitops bridge debugging
      if [[ $namespace == "argocd" ]]; then
        echo "Skipping pod $pod in namespace $namespace"
        continue
      fi
      pod_name=$(echo $pod | awk '{print $2}')


      # Get the owner references of the pod
      owner_refs=$(kubectl get pod $pod_name -n $namespace -o jsonpath='{.metadata.ownerReferences[*]}')

      # Check if the owner is a ReplicaSet (which is part of a deployment) or a StatefulSet and scale down
      if echo $owner_refs | grep -q "ReplicaSet"; then
      replicaset_name=$(kubectl get pod $pod_name -n $namespace -o jsonpath='{.metadata.ownerReferences[?(@.kind=="ReplicaSet")].name}')
      deployment_name=$(kubectl get replicaset $replicaset_name -n $namespace -o jsonpath='{.metadata.ownerReferences[?(@.kind=="Deployment")].name}')
      if [[ $(kubectl get deployment $deployment_name -n $namespace -o jsonpath='{.spec.replicas}') -gt 0 ]]; then
        echo kubectl scale deployment $deployment_name -n $namespace --replicas=0
        kubectl scale deployment $deployment_name -n $namespace --replicas=0
        kubectl rollout status deployment $deployment_name -n $namespace
      fi
      elif echo $owner_refs | grep -q "StatefulSet"; then
      statefulset_name=$(kubectl get pod $pod_name -n $namespace -o jsonpath='{.metadata.ownerReferences[?(@.kind=="StatefulSet")].name}')
      if [[ $(kubectl get statefulset $statefulset_name -n $namespace -o jsonpath='{.spec.replicas}') -gt 0 ]]; then
        echo kubectl scale statefulset $statefulset_name -n $namespace --replicas=0
        kubectl scale statefulset $statefulset_name -n $namespace --replicas=0
        kubectl rollout status statefulset $statefulset_name -n $namespace
      fi
      fi
    done <<< "$pods"
  done

  # Delete the nodeclaims
  kubectl delete nodepools.karpenter.sh --all
  kubectl delete nodeclaims.karpenter.sh --all


  # do a final check to make sure the nodes are gone, loop sleep 60 in between checks
  nodes=$(kubectl get nodes -l karpenter.sh/registered=true -o jsonpath='{.items[*].metadata.name}')
  while [[ ! -z $nodes ]]; do
    # Loop through each node and delete it
    for node in $nodes; do
        echo "Deleting node: $node"
        kubectl delete node $node
    done
    echo "Waiting for nodes to be deleted: $nodes"
    sleep 60
    nodes=$(kubectl get nodes -l karpenter.sh/registered=true -o jsonpath='{.items[*].metadata.name}')
  done
  echo "Waiting for karpenter nodes to be deleted up to 2 minutes"
  sleep 120


}


# This is required for certain resources that are not managed by Terraform
force_delete_vpc() {
  VPC_NAME=$1
  VPCID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=${VPC_NAME}" --query "Vpcs[*].VpcId" --output text)
  if [ -n "$VPCID" ]; then
      echo "VPC ID: $VPCID"
      echo "Cleaning VPC endpoints if exists..."
      vpc_endpoint_names=("com.amazonaws.eu-west-1.guardduty-data" "com.amazonaws.eu-west-1.ssm" "com.amazonaws.eu-west-1.ec2messages" "com.amazonaws.eu-west-1.ssmmessages" "com.amazonaws.eu-west-1.s3")
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