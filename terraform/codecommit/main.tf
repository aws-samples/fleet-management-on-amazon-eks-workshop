data "aws_region" "current" {}

locals {

  context_prefix = "fleet-gitops-bridge"

  gitops_fleet_repo_name = var.gitops_fleet_repo_name
  gitops_fleet_org       = "ssh://${aws_iam_user_ssh_key.gitops.id}@git-codecommit.${data.aws_region.current.id}.amazonaws.com"
  gitops_fleet_repo      = "v1/repos/${local.gitops_fleet_repo_name}"

  gitops_workload_repo_name = var.gitops_workload_repo_name
  gitops_workload_org       = "ssh://${aws_iam_user_ssh_key.gitops.id}@git-codecommit.${data.aws_region.current.id}.amazonaws.com"
  gitops_workload_repo      = "v1/repos/${local.gitops_workload_repo_name}"

  gitops_platform_repo_name = var.gitops_platform_repo_name
  gitops_platform_org       = "ssh://${aws_iam_user_ssh_key.gitops.id}@git-codecommit.${data.aws_region.current.id}.amazonaws.com"
  gitops_platform_repo      = "v1/repos/${local.gitops_platform_repo_name}"

  gitops_addons_repo_name = var.gitops_addons_repo_name
  gitops_addons_org       = "ssh://${aws_iam_user_ssh_key.gitops.id}@git-codecommit.${data.aws_region.current.id}.amazonaws.com"
  gitops_addons_repo      = "v1/repos/${local.gitops_addons_repo_name}"

  ssh_key_basepath           = var.ssh_key_basepath
  git_private_ssh_key        = "${local.ssh_key_basepath}/gitops_ssh.pem"
  git_private_ssh_key_config = "${local.ssh_key_basepath}/config"
  ssh_host                   = "git-codecommit.*.amazonaws.com"
  ssh_config                 = <<-EOF
  # AWS Workshop https://github.com/aws-samples/argocd-on-amazon-eks-workshop.git
  Host ${local.ssh_host}
    User ${aws_iam_user.gitops.unique_id}
    IdentityFile ${local.git_private_ssh_key}
  EOF

}

resource "aws_codecommit_repository" "workloads" {
  repository_name = local.gitops_workload_repo_name
  description     = "CodeCommit repository for ArgoCD workloads"
}

resource "aws_codecommit_repository" "platform" {
  repository_name = local.gitops_platform_repo_name
  description     = "CodeCommit repository for ArgoCD platform"
}

resource "aws_codecommit_repository" "addons" {
  repository_name = local.gitops_addons_repo_name
  description     = "CodeCommit repository for ArgoCD addons"
}

resource "aws_codecommit_repository" "fleet" {
  repository_name = local.gitops_fleet_repo_name
  description     = "CodeCommit repository for ArgoCD addons"
}

resource "aws_iam_user" "gitops" {
  name = "${local.context_prefix}-gitops"
  path = "/"
}

resource "aws_iam_user_ssh_key" "gitops" {
  username   = aws_iam_user.gitops.name
  encoding   = "SSH"
  public_key = tls_private_key.gitops.public_key_openssh
}

resource "tls_private_key" "gitops" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


resource "aws_secretsmanager_secret" "ssh_secrets" {
  name = var.secret_name_ssh_secrets
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "ssh_secrets_version" {
  secret_id = aws_secretsmanager_secret.ssh_secrets.id
  secret_string = jsonencode({
    private_key = tls_private_key.gitops.private_key_pem
    ssh_config  = local.ssh_config
  })
}

resource "aws_secretsmanager_secret" "git_data_fleet" {
  name = var.secret_name_git_data_fleet
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "git_data_version_fleet" {
  secret_id = aws_secretsmanager_secret.git_data_fleet.id
  secret_string = jsonencode({
    private_key = tls_private_key.gitops.private_key_pem
    url = "${local.gitops_fleet_org}/${local.gitops_fleet_repo}"
    org = local.gitops_fleet_org
    repo = local.gitops_fleet_repo
    basepath = var.gitops_fleet_basepath
    path = var.gitops_fleet_path
    revision = var.gitops_fleet_revision
  })
}


resource "aws_secretsmanager_secret" "git_data_addons" {
  name = var.secret_name_git_data_addons
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "git_data_version_addons" {
  secret_id = aws_secretsmanager_secret.git_data_addons.id
  secret_string = jsonencode({
    private_key = tls_private_key.gitops.private_key_pem
    url = "${local.gitops_addons_org}/${local.gitops_addons_repo}"
    org = local.gitops_addons_org
    repo = local.gitops_addons_repo
    basepath = var.gitops_addons_basepath
    path = var.gitops_addons_path
    revision = var.gitops_addons_revision
  })
}

resource "aws_secretsmanager_secret" "git_data_platform" {
  name = var.secret_name_git_data_platform
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "git_data_platform" {
  secret_id = aws_secretsmanager_secret.git_data_platform.id
  secret_string = jsonencode({
    private_key = tls_private_key.gitops.private_key_pem
    url = "${local.gitops_platform_org}/${local.gitops_platform_repo}"
    org = local.gitops_platform_org
    repo = local.gitops_platform_repo
    basepath = var.gitops_platform_basepath
    path = var.gitops_platform_path
    revision = var.gitops_platform_revision
  })
}

resource "aws_secretsmanager_secret" "git_data_workload" {
  name = var.secret_name_git_data_workload
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "git_data_workload" {
  secret_id = aws_secretsmanager_secret.git_data_workload.id
  secret_string = jsonencode({
    private_key = tls_private_key.gitops.private_key_pem
    url = "${local.gitops_workload_org}/${local.gitops_workload_repo}"
    org = local.gitops_workload_org
    repo = local.gitops_workload_repo
    basepath = var.gitops_workload_basepath
    path = var.gitops_workload_path
    revision = var.gitops_workload_revision
  })
}



data "aws_iam_policy_document" "gitops_access" {
  statement {
    sid = ""
    actions = [
      "codecommit:GitPull",
      "codecommit:GitPush"
    ]
    effect = "Allow"
    resources = [
      aws_codecommit_repository.workloads.arn,
      aws_codecommit_repository.platform.arn,
      aws_codecommit_repository.addons.arn,
      aws_codecommit_repository.fleet.arn
    ]
  }
}

resource "aws_iam_policy" "gitops_access" {
  name   = "${local.context_prefix}-gitops"
  path   = "/"
  policy = data.aws_iam_policy_document.gitops_access.json
}

resource "aws_iam_user_policy_attachment" "gitops_access" {
  user       = aws_iam_user.gitops.name
  policy_arn = aws_iam_policy.gitops_access.arn
}
