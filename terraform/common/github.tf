# create github repos for local.gitops_repos
resource "github_repository" "gitops_repo" {
  # do not create if var.create_github_repos is false
  for_each = { for k, v in local.gitops_repos : k => v if var.create_github_repos }
  #for_each   = local.gitops_repos
  name       = "${local.gitops_repos[each.key].name}"
  visibility = "private"
  auto_init  = false
}

provider "github" {
  token = var.gitea_password
}