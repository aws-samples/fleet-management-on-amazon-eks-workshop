aws eks --region $AWS_REGION update-kubeconfig --name fleet-hub-cluster --alias fleet-hub-cluster
aws eks --region $AWS_REGION update-kubeconfig --name fleet-spoke-staging --alias fleet-staging-cluster
aws eks --region $AWS_REGION update-kubeconfig --name fleet-spoke-prod --alias fleet-prod-cluster
