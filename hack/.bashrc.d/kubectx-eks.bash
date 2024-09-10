# Setup kubectx for EKS clusters as Admin
aws eks --region $AWS_REGION update-kubeconfig --name fleet-hub-cluster --alias fleet-hub-cluster 2>/dev/null
aws eks --region $AWS_REGION update-kubeconfig --name fleet-spoke-staging --alias fleet-staging-cluster 2>/dev/null
aws eks --region $AWS_REGION update-kubeconfig --name fleet-spoke-prod --alias fleet-prod-cluster 2>/dev/null

# Setup kubectx for EKS clusters as Team
export BACKEND_TEAM_ROLE_ARN=$(aws ssm --region $AWS_REGION get-parameter --name eks-fleet-workshop-gitops-backend-team-view-role --with-decryption --query "Parameter.Value" --output text)
aws eks --region $AWS_REGION update-kubeconfig --name fleet-spoke-staging --alias fleet-staging-cluster-backend  --role-arn $BACKEND_TEAM_ROLE_ARN 2>/dev/null
aws eks --region $AWS_REGION update-kubeconfig --name fleet-spoke-prod --alias fleet-prod-cluster-backend     --role-arn $BACKEND_TEAM_ROLE_ARN 2>/dev/null
export FRONTEND_TEAM_ROLE_ARN=$(aws ssm --region $AWS_REGION get-parameter --name eks-fleet-workshop-gitops-frontend-team-view-role --with-decryption --query "Parameter.Value" --output text)
aws eks --region $AWS_REGION update-kubeconfig --name fleet-spoke-staging --alias fleet-staging-cluster-frontend --role-arn $FRONTEND_TEAM_ROLE_ARN 2>/dev/null
aws eks --region $AWS_REGION update-kubeconfig --name fleet-spoke-prod --alias fleet-prod-cluster-frontend    --role-arn $FRONTEND_TEAM_ROLE_ARN 2>/dev/null

