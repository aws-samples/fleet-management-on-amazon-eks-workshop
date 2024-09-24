# To use github repos need to set the following variables
# export TF_VAR_create_github_repos=true
# export TF_VAR_gitea_external_url=https://github.com
# export TF_VAR_gitea_repo_prefix="$GITHUB_USERNAME_OR_ORG/"
# export TF_VAR_gitea_user=$GITHUB_USERNAME
# export TF_VAR_gitea_password=$GITHUB_TOKEN



resource "github_repository" "gitops_repo" {
  # do not create if var.create_github_repos is false
  for_each = { for k, v in local.gitops_repos : k => v if var.create_github_repos }
  #for_each   = local.gitops_repos
  name       = "${local.gitops_repos[each.key].name}"
  visibility = "private"
  auto_init  = false
}

provider "github" {
  token = var.create_github_repos ? var.gitea_password : null
}