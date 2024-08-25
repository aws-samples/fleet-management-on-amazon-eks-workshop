
# This output is informational only and is not used by any other module
output "git_secrets_urls" {
  value       = local.git_secrets_urls
  description = "The URLs for the Git repositories"
}
output "git_secrets_names" {
  value       = local.git_secrets_names
  description = "The names of the AWS Secrets for the Git repositories"
}

output "ssh_secret_name" {
  value       = aws_secretsmanager_secret.ssh_secrets.name
  description = "Secret name for the SSH private key"
}

output "gitops_user_name" {
  value       = aws_iam_user.gitops.name
  description = "Name of the IAM user created for GitOps access"
}

output "aws_ssm_parameter_name" {
  value       = aws_ssm_parameter.argocd_hub_role.name
  description = "Name of the SSM parameter for the ArgoCD EKS role"
}
output "iam_argocd_role_arn" {
  value       = aws_iam_role.argocd_central.arn
  description = "ARN of the IAM role for ArgoCD EKS access"
}