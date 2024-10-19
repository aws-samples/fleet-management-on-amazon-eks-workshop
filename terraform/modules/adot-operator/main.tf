
module "cert_manager" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons/cert-manager?ref=v4.32.0"
  count  = var.enable_cert_manager ? 1 : 0

  helm_config   = var.helm_config
  addon_context = var.addon_context
}

data "aws_eks_addon_version" "this" {
  addon_name         = local.name
  kubernetes_version = try(var.addon_config.kubernetes_version, var.kubernetes_version)
  most_recent        = try(var.addon_config.most_recent, true)
}

resource "aws_eks_addon" "adot" {
  cluster_name                = var.addon_context.eks_cluster_id
  addon_name                  = local.name
  addon_version               = try(var.addon_config.addon_version, data.aws_eks_addon_version.this.version)
  resolve_conflicts_on_create = try(var.addon_config.resolve_conflicts, "OVERWRITE")
  resolve_conflicts_on_update = try(var.addon_config.resolve_conflicts, "OVERWRITE")
  service_account_role_arn    = try(var.addon_config.service_account_role_arn, null)
  preserve                    = try(var.addon_config.preserve, true)

  tags = merge(
    var.addon_context.tags,
    try(var.addon_config.tags, {})
  )

  depends_on = [module.cert_manager]
}
