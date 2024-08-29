locals {

 context_prefix = var.project_context_prefix

  tags = {
    Blueprint  = local.context_prefix
    GithubRepo = "github.com/gitops-bridge-dev/gitops-bridge"
  }

}
