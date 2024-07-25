output "configure_argocd" {
  value = "argocd repo add ${local.gitops_workload_org}/${local.gitops_workload_repo} --ssh-private-key-path $${HOME}/.ssh/gitops_ssh.pem --insecure-ignore-host-key --upsert --name git-repo"
}
output "git_clone" {
  value = "git clone ${local.gitops_workload_org}/${local.gitops_workload_repo}"
}
output "ssh_config" {
  value = local.ssh_config
}
output "ssh_host" {
  value = local.ssh_host
}

output "git_private_ssh_key" {
  value = local.git_private_ssh_key
}

output "gitops_addons_url" {
  value = "${local.gitops_addons_org}/${local.gitops_addons_repo}"
}
output "gitops_addons_org" {
  description = "Git repository org/user contains for addons"
  value       = local.gitops_addons_org
}
output "gitops_addons_repo" {
  description = "Git repository contains for addons"
  value       = local.gitops_addons_repo
}
output "gitops_addons_basepath" {
  description = "Git repository base path for addons"
  value       = var.gitops_addons_basepath
}
output "gitops_addons_path" {
  description = "Git repository path for addons"
  value       = var.gitops_addons_path
}
output "gitops_addons_revision" {
  description = "Git repository revision/branch/ref for addons"
  value       = var.gitops_addons_revision
}

output "gitops_platform_url" {
  value = "${local.gitops_platform_org}/${local.gitops_platform_repo}"
}
output "gitops_platform_org" {
  description = "Git repository org/user contains for platform"
  value       = local.gitops_platform_org
}
output "gitops_platform_repo" {
  description = "Git repository contains for platform"
  value       = local.gitops_workload_repo
}
output "gitops_platform_basepath" {
  description = "Git repository base path for platform"
  value       = var.gitops_platform_basepath
}
output "gitops_platform_path" {
  description = "Git repository path for platform"
  value       = var.gitops_platform_path
}
output "gitops_platform_revision" {
  description = "Git repository revision/branch/ref for platform"
  value       = var.gitops_platform_revision
}

output "gitops_workload_url" {
  value = "${local.gitops_workload_org}/${local.gitops_workload_repo}"
}
output "gitops_workload_org" {
  description = "Git repository org/user contains for workload"
  value       = local.gitops_workload_org
}
output "gitops_workload_repo" {
  description = "Git repository contains for workload"
  value       = local.gitops_workload_repo
}
output "gitops_workload_basepath" {
  description = "Git repository base path for workload"
  value       = var.gitops_workload_basepath
}
output "gitops_workload_path" {
  description = "Git repository path for workload"
  value       = var.gitops_workload_path
}
output "gitops_workload_revision" {
  description = "Git repository revision/branch/ref for workload"
  value         = var.gitops_workload_revision
}
output "codecommit_key_id" {
  description = "Secret name that holds the SSH key for accessing CodeCommit"
  value       = aws_secretsmanager_secret.codecommit_key.id
}
output "codecommit_key_name" {
  description = "Secret name that holds the SSH key for accessing CodeCommit"
  value       = aws_secretsmanager_secret.codecommit_key.name
}
