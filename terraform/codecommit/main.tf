data "aws_region" "current" {}

locals {

  context_prefix = "gitops-bridge"

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

resource "random_string" "secret_suffix" {
  length  = 5     # Length of the random string
  special = false # Set to true if you want to include special characters
  upper   = true  # Set to true if you want uppercase letters in the string
  lower   = true  # Set to true if you want lowercase letters in the string
  number  = true  # Set to true if you want numbers in the string
}
resource "aws_secretsmanager_secret" "codecommit_key" {
  name = "codecommit-key-${random_string.secret_suffix.result}"
}

resource "aws_secretsmanager_secret_version" "private_key_secret_version" {
  secret_id     = aws_secretsmanager_secret.codecommit_key.id
  secret_string = tls_private_key.gitops.private_key_pem
}

resource "local_file" "ssh_private_key" {
  content         = tls_private_key.gitops.private_key_pem
  filename        = pathexpand(local.git_private_ssh_key)
  file_permission = "0600"
}

resource "local_file" "ssh_config" {
  count           = local.ssh_key_basepath == "/home/ec2-user/.ssh" ? 1 : 0
  content         = local.ssh_config
  filename        = pathexpand(local.git_private_ssh_key_config)
  file_permission = "0600"
}

resource "null_resource" "append_string_block" {
  count = local.ssh_key_basepath == "/home/ec2-user/.ssh" ? 0 : 1
  triggers = {
    always_run = "${timestamp()}"
    file       = pathexpand(local.git_private_ssh_key_config)
  }

  provisioner "local-exec" {
    when    = create
    command = <<-EOL
      start_marker="### START BLOCK AWS Workshop ###"
      end_marker="### END BLOCK AWS Workshop ###"
      block="$start_marker\n${local.ssh_config}\n$end_marker"
      file="${self.triggers.file}"

      if ! grep -q "$start_marker" "$file"; then
        echo "$block" >> "$file"
      fi
    EOL
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOL
      start_marker="### START BLOCK AWS Workshop ###"
      end_marker="### END BLOCK AWS Workshop ###"
      file="${self.triggers.file}"

      if grep -q "$start_marker" "$file"; then
        sed -i '' "/$start_marker/,/$end_marker/d" "$file"
      fi
    EOL

  }
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
      aws_codecommit_repository.addons.arn
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
