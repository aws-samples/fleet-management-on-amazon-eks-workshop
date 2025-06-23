#!/bin/bash

#############################################################################
# ArgoCD and GitLab Setup Script
#############################################################################
#
# DESCRIPTION:
#   This script configures ArgoCD and GitLab for the EKS cluster management
#   environment. It:
#   1. Updates the kubeconfig to connect to the hub cluster
#   2. Retrieves and displays the ArgoCD URL and credentials
#   3. Sets up GitLab repository and SSH keys
#   4. Configures Git remote for the working repository
#   5. Creates a secret in ArgoCD for Git repository access
#   6. Logs in to ArgoCD CLI and lists applications
#
# USAGE:
#   ./1-argocd-gitlab-setup.sh
#
# PREREQUISITES:
#   - The management cluster must be created (run 0-initial-setup.sh first)
#   - Environment variables must be set:
#     - AWS_REGION: AWS region where resources are deployed
#     - WORKSPACE_PATH: Path to the workspace directory
#     - WORKING_REPO: Name of the working repository
#     - GIT_USERNAME: Git username for authentication
#     - IDE_PASSWORD: Password for ArgoCD and GitLab authentication
#
# SEQUENCE:
#   This is the second script (1) in the setup sequence.
#   Run after 0-initial-setup.sh and before 2-bootstrap-accounts.sh
#
#############################################################################

# Source the colors script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/colors.sh"

print_header "ArgoCD and GitLab Setup"

print_step "Updating kubeconfig to connect to the hub cluster"
aws eks update-kubeconfig --name hub-cluster --alias hub-cluster

export DOMAIN_NAME=$(aws cloudfront list-distributions --query "DistributionList.Items[?contains(Origins.Items[0].Id, 'http-origin')].DomainName | [0]" --output text)
echo "export DOMAIN_NAME=$DOMAIN_NAME" >> ~/environment/.envrc

print_header "Setting up GitLab repository and ArgoCD access"

export GITLAB_URL=https://$(aws cloudfront list-distributions --query "DistributionList.Items[?contains(Origins.Items[0].Id, 'gitlab')].DomainName | [0]" --output text)
export NLB_DNS=$(aws elbv2 describe-load-balancers --region $AWS_REGION --names gitlab --query 'LoadBalancers[0].DNSName' --output text) >> ~/environment/.envrc
echo "export GITLAB_URL=$GITLAB_URL" >> ~/environment/.envrc
echo "export NLB_DNS=$NLB_DNS" >> ~/environment/.envrc

print_info "Creating GitLab SSH keys"
$PATTERN_FULL_PATH/scripts/gitlab_create_keys.sh

print_step "Configuring Git remote and pushing to GitLab"
cd $WORKSPACE_PATH/$WORKING_REPO
git remote add origin ssh://git@$NLB_DNS/$GIT_USERNAME/$WORKING_REPO.git

print_step "Updating Backstage templates"
$PATTERN_FULL_PATH/scripts/update_template_defaults.sh
git add . && git commit -m "Update Backstage Templates"

git push --set-upstream origin main

print_step "Creating ArgoCD Git repository secret"
envsubst << 'EOF' | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
   name: git-${WORKING_REPO}
   namespace: argocd
   labels:
      argocd.argoproj.io/secret-type: repository
stringData:
   url: ${GITLAB_URL}/${GIT_USERNAME}/${WORKING_REPO}.git
   type: git
   username: $GIT_USERNAME
   password: $IDE_PASSWORD
EOF

sleep 5

print_step "Creating Amazon Elastic Container Repository (Amazon ECR) for Backstage image"
aws ecr create-repository --repository-name backstage --region $AWS_REGION || true

print_step "Building Backstage image"
$PATTERN_FULL_PATH/scripts/build_backstage.sh $PATTERN_FULL_PATH/backstage

print_step "Logging in to ArgoCD CLI"
argocd login --username admin --password $IDE_PASSWORD --grpc-web-root-path /argocd $DOMAIN_NAME

print_info "Listing ArgoCD applications"
argocd app list

print_step "Syncing bootstrap application"
argocd app sync bootstrap

print_info "Checking ArgoCD applications status"
kubectl get applications -n argocd

print_success "ArgoCD and GitLab setup completed successfully."

print_header "Access Information"
print_info "You can connect to Argo CD UI and check everything is ok"
echo -e "${CYAN}ArgoCD URL:${BOLD} https://$DOMAIN_NAME/argocd${NC}"
echo -e "${CYAN}   Login:${BOLD} admin${NC}"
echo -e "${CYAN}   Password:${BOLD} $IDE_PASSWORD${NC}"

print_info "Next step: Run 2-bootstrap-accounts.sh to bootstrap management and spoke accounts."
