#!/bin/bash

#############################################################################
# Deploy Argo Rollouts Demo Application
#############################################################################
#
# DESCRIPTION:
#   This script deploys the Argo Rollouts demo application to the EKS clusters.
#   It performs the following steps:
#   1. Creates an Amazon ECR repository for container images
#   2. Clones the application source repository and builds an initial image
#   3. Creates a Git repository for the application deployment configuration
#   4. Updates configuration files with account-specific information
#   5. Configures ArgoCD and Kargo for the application deployment
#   6. Sets up access for Kargo to the Git repository
#
# USAGE:
#   ./4-deploy-argo-rollouts-demo.sh
#
# PREREQUISITES:
#   - Spoke EKS clusters must be created (run 3-create-spoke-clusters.sh first)
#   - Environment variables must be set:
#     - AWS_REGION: AWS region where resources are deployed
#     - WORKSPACE_PATH: Path to the workspace directory
#     - WORKING_REPO: Name of the working repository
#     - GITLAB_URL: URL of the GitLab instance
#     - GIT_USERNAME: Git username for authentication
#     - IDE_PASSWORD: Password for authentication
#     - MGMT_ACCOUNT_ID: AWS Management account ID
#     - NLB_DNS: DNS name of the GitLab load balancer
#
# SEQUENCE:
#   This is the fifth script (4) in the setup sequence.
#   Run after 3-create-spoke-clusters.sh and before 5-cluster-access.sh
#
#############################################################################


# Source the colors script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/colors.sh"

print_header "Deploying Argo Rollouts Demo Application"

print_step "Creating Amazon Elastic Container Repository (Amazon ECR) for container images"
aws ecr create-repository --repository-name rollouts-demo --region $AWS_REGION || true

print_step "Setting up cross-account permissions for ECR repository"
# Define spoke account IDs - if not already defined, use the provided accounts
if [ -z "$SPOKE_ACCOUNT_IDS" ]; then
  export SPOKE_ACCOUNT_IDS="515966522948 586794472760 825765380480"
  print_info "Using default SPOKE_ACCOUNT_IDS: $SPOKE_ACCOUNT_IDS"
fi

# Create policy statements for each spoke account
POLICY_STATEMENTS=""
for ACCOUNT_ID in $SPOKE_ACCOUNT_IDS; do
  if [ -n "$POLICY_STATEMENTS" ]; then
    POLICY_STATEMENTS="$POLICY_STATEMENTS,"
  fi
  POLICY_STATEMENTS="$POLICY_STATEMENTS
    {
      \"Sid\": \"AllowPullFrom${ACCOUNT_ID}\",
      \"Effect\": \"Allow\",
      \"Principal\": {
        \"AWS\": \"arn:aws:iam::${ACCOUNT_ID}:root\"
      },
      \"Action\": [
        \"ecr:BatchGetImage\",
        \"ecr:GetDownloadUrlForLayer\",
        \"ecr:BatchCheckLayerAvailability\"
      ]
    }"
done

# Create the repository policy using a heredoc to ensure proper JSON formatting
POLICY=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowPullFromSameAccount",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${MGMT_ACCOUNT_ID}:root"
      },
      "Action": [
        "ecr:*"
      ]
    },${POLICY_STATEMENTS}
  ]
}
EOF
)

# Apply the policy to the repository
print_info "Applying cross-account ECR repository policy"
aws ecr set-repository-policy \
  --repository-name rollouts-demo \
  --policy-text "$POLICY" \
  --region $AWS_REGION

print_success "ECR repository policy updated to allow access from spoke accounts"

print_step "Cloning application source repository and building initial image"
cd $WORKSPACE_PATH
git clone https://github.com/argoproj/rollouts-demo.git
cd rollouts-demo
$PATTERN_FULL_PATH/scripts/build-rollouts-demo.sh

print_step "Checking the EKS Pod Identity association for kargo addon"
aws eks list-pod-identity-associations --cluster-name hub-cluster | grep -A 3 "kargo-controller"

sleep 5

print_step "Creating Git repository for the application deployment configuration"
curl -Ss -X 'POST' "$GITLAB_URL/api/v4/projects/" \
  -H "PRIVATE-TOKEN: $IDE_PASSWORD" \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d "{
  \"name\": \"rollouts-demo-deploy\"
}" && echo -e "\n"

print_step "Cloning and populating the deployment Git repository"
git clone ssh://git@$NLB_DNS/$GIT_USERNAME/rollouts-demo-deploy.git $WORKSPACE_PATH/rollouts-demo-deploy
cp -r $WORKSPACE_PATH/$WORKING_REPO/apps/rollouts-demo-deploy/* $WORKSPACE_PATH/rollouts-demo-deploy/

print_step "Updating Account ID in ECR URLs and repoUrl in the application configuration"
find "$WORKSPACE_PATH/rollouts-demo-deploy" -type f -exec sed -i'' -e "s|GITLAB_URL|${GITLAB_URL}|g" {} +
find "$WORKSPACE_PATH/rollouts-demo-deploy" -type f -exec sed -i'' -e "s|GIT_USERNAME|${GIT_USERNAME}|g" {} +
find "$WORKSPACE_PATH/rollouts-demo-deploy" -type f -exec sed -i'' -e "s|MANAGEMENT_ACCOUNT_ID|${MGMT_ACCOUNT_ID}|g" {} +
find "$WORKSPACE_PATH/rollouts-demo-deploy" -type f -exec sed -i'' -e "s|AWS_REGION|${AWS_REGION}|g" {} +

find "$WORKSPACE_PATH/$WORKING_REPO/workloads" -type f -exec sed -i'' -e "s|GITLAB_URL|${GITLAB_URL}|g" {} +
find "$WORKSPACE_PATH/$WORKING_REPO/workloads" -type f -exec sed -i'' -e "s|GIT_USERNAME|${GIT_USERNAME}|g" {} +

print_step "Enabling workloads in Argo CD application"
cat << EOF > $WORKSPACE_PATH/$WORKING_REPO/workloads/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - rollouts-demo-application-set.yaml
  - rollouts-demo-kargo.yaml
EOF

print_step "Giving ArgoCD access to Git rollouts-demo-deploy repository"
envsubst << 'EOF' | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
   name: git-rollouts-demo-deploy
   namespace: argocd
   labels:
      argocd.argoproj.io/secret-type: repository
stringData:
   url: ${GITLAB_URL}/${GIT_USERNAME}/rollouts-demo-deploy.git
   type: git
   username: $GIT_USERNAME
   password: $IDE_PASSWORD
EOF

print_step "Adding, committing and pushing changes"
cd $WORKSPACE_PATH/rollouts-demo-deploy/
git status
git add .
git commit -m "Initial commit"
git push

cd $WORKSPACE_PATH/$WORKING_REPO/
git status
git pull
git add .
git commit -m "Enable rollouts-demo-deploy"
git push

print_info "Refreshing cluster-workloads application and waiting for rollouts-demo-kargo to be ready"

# Login to ArgoCD CLI
print_step "Logging in to ArgoCD CLI"
argocd login --username admin --password $IDE_PASSWORD --grpc-web-root-path /argocd $DOMAIN_NAME

# Sync the cluster-workloads application
print_step "Syncing the cluster-workloads application"
argocd app sync cluster-workloads

# Wait for the rollouts-demo-kargo application to be synced and healthy
print_info "Waiting for the rollouts-demo-kargo application to be synced and healthy"
argocd app wait rollouts-demo-kargo --health --sync

print_header "Setting up Kargo Access"

export KARGO_URL=https://$DOMAIN_NAME
curl --head -X GET --retry 20 --retry-all-errors --retry-delay 15 \
  --connect-timeout 5 --max-time 10 -k $KARGO_URL
print_info "Kargo URL: ${BOLD}$KARGO_URL${NC}"
print_info "Kargo password: ${BOLD}$IDE_PASSWORD${NC}"

print_step "Giving Kargo access to Git rollouts-demo-deploy repository"
envsubst << 'EOF' | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
   name: git-rollouts-demo-kargo
   namespace: rollouts-demo-kargo
   labels:
      kargo.akuity.io/cred-type: git
stringData:
   repoURL:  ${GITLAB_URL}/${GIT_USERNAME}/rollouts-demo-deploy.git
   username: $GIT_USERNAME
   password: $IDE_PASSWORD
EOF

print_step "Restarting Kargo controller"
kubectl -n kargo rollout restart deploy kargo-controller

print_info "Waiting for rollouts-demo-kargo application to be synced and healthy"
argocd app wait rollouts-demo-kargo --health --sync

print_success "Argo Rollouts demo application deployment completed."
print_info "Next step: Run 5-cluster-access.sh to configure access to the EKS clusters."
