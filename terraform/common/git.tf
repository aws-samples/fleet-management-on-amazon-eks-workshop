

locals {
  gitops_repos = {
    fleet = {
      name     = var.gitops_fleet_repo_name
      basepath = var.gitops_fleet_basepath
      path     = var.gitops_fleet_path
      revision = var.gitops_fleet_revision
    }
    addons = {
      name     = var.gitops_addons_repo_name
      basepath = var.gitops_addons_basepath
      path     = var.gitops_addons_path
      revision = var.gitops_addons_revision
    }
    platform = {
      name     = var.gitops_platform_repo_name
      basepath = var.gitops_platform_basepath
      path     = var.gitops_platform_path
      revision = var.gitops_platform_revision
    }
    workloads = {
      name     = var.gitops_workload_repo_name
      basepath = var.gitops_workload_basepath
      path     = var.gitops_workload_path
      revision = var.gitops_workload_revision
    }

  }
  gitea_user = var.gitea_user
  gitea_password = var.gitea_password

  git_secrets_version_locals = {
    # private_key = tls_private_key.gitops.private_key_pem
    #org         = "ssh://${aws_iam_user_ssh_key.gitops.id}@git-codecommit.${data.aws_region.current.id}.amazonaws.com"
    org         = "${var.gitea_external_url}"
    repo_prefix = var.gitea_repo_prefix
  }

  git_secrets_urls  = { for repo_key, repo in local.gitops_repos : repo_key => "${local.git_secrets_version_locals.org}/${local.git_secrets_version_locals.repo_prefix}${repo.name}" }
  git_secrets_names = { for repo_key, repo in local.gitops_repos : repo_key => "${local.context_prefix}-${repo_key}" }
}


resource "aws_secretsmanager_secret" "git_secrets" {
  for_each                = local.gitops_repos
  name                    = "${local.context_prefix}-${each.key}"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "git_secrets_version" {
  for_each  = aws_secretsmanager_secret.git_secrets
  secret_id = each.value.id
  secret_string = jsonencode({
    #private_key = local.git_secrets_version_locals.private_key
    username    = local.gitea_user
    password    = local.gitea_password
    url         = local.git_secrets_urls[each.key]
    org         = local.git_secrets_version_locals.org
    repo        = "${local.git_secrets_version_locals.repo_prefix}${local.gitops_repos[each.key].name}"
    basepath    = local.gitops_repos[each.key].basepath
    path        = local.gitops_repos[each.key].path
    revision    = local.gitops_repos[each.key].revision
  })
}

