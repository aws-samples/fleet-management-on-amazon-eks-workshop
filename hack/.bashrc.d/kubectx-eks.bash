# Setup kubectx for EKS clusters as Admin
aws eks --region $AWS_REGION update-kubeconfig --name fleet-hub-cluster --alias fleet-hub-cluster
aws eks --region $AWS_REGION update-kubeconfig --name fleet-spoke-staging --alias fleet-staging-cluster
aws eks --region $AWS_REGION update-kubeconfig --name fleet-spoke-prod --alias fleet-prod-cluster

# Setup kubectx for EKS clusters as Team
export BACKEND_TEAM_ROLE_ARN=$(aws ssm --region $AWS_REGION get-parameter --name eks-fleet-workshop-gitops-backend-team-view-role --with-decryption --query "Parameter.Value" --output text)
aws eks --region $AWS_REGION update-kubeconfig --name fleet-spoke-staging --alias fleet-staging-cluster-backend --user-alias fleet-staging-cluster-backend --role-arn $BACKEND_TEAM_ROLE_ARN
aws eks --region $AWS_REGION update-kubeconfig --name fleet-spoke-prod --alias fleet-prod-cluster-backend --user-alias fleet-prod-cluster-backend --role-arn $BACKEND_TEAM_ROLE_ARN

export FRONTEND_TEAM_ROLE_ARN=$(aws ssm --region $AWS_REGION get-parameter --name eks-fleet-workshop-gitops-frontend-team-view-role --with-decryption --query "Parameter.Value" --output text)
aws eks --region $AWS_REGION update-kubeconfig --name fleet-spoke-staging --alias fleet-staging-cluster-frontend --user-alias fleet-staging-cluster-frontend --role-arn $FRONTEND_TEAM_ROLE_ARN
aws eks --region $AWS_REGION update-kubeconfig --name fleet-spoke-prod --alias fleet-prod-cluster-frontend --user-alias fleet-prod-cluster-frontend --role-arn $FRONTEND_TEAM_ROLE_ARN

