
locals{
    scrape_interval = "30s"
    scrape_timeout  = "10s"
}

data "aws_ssm_parameter" "amp_arn" {
  name = "${local.context_prefix}-${var.amazon_managed_prometheus_suffix}-arn"
}

resource "aws_prometheus_scraper" "fleet-scraper" {
  # only enabled this if var enable_prometheus_scraper is true
  count = var.enable_prometheus_scraper ? 1 : 0
  source {
    eks {
      cluster_arn = module.eks.cluster_arn
      subnet_ids  = module.vpc.private_subnets
      security_group_ids = [module.eks.node_security_group_id]
    }
  }
  destination {
    amp {
       workspace_arn = data.aws_ssm_parameter.amp_arn.value
    }
  }
  alias = "fleet-hub"
  scrape_configuration = replace(
    replace(
      replace(
        replace(
          replace(
            file("${path.module}/../common/scraper-config.yaml"),
            "{scrape_interval}",
            local.scrape_interval
          ),
          "{scrape_timeout}",
          local.scrape_timeout
        ),
        "{cluster}",
        local.name
      ),
      "{region}",
      local.region
    ),
    "{account_id}",
    data.aws_caller_identity.current.account_id
  )

}

################################################################################
# ADOT
################################################################################
data "aws_partition" "current" {}

locals{
  context = {
    aws_caller_identity_account_id = data.aws_caller_identity.current.account_id
    aws_caller_identity_arn        = data.aws_caller_identity.current.arn
    aws_eks_cluster_endpoint       = module.eks.cluster_endpoint
    aws_partition_id               = data.aws_partition.current.partition
    aws_region_name                = data.aws_region.current.name
    eks_cluster_id                 = module.eks.cluster_name
    eks_oidc_issuer_url            = module.eks.oidc_provider
    eks_oidc_provider_arn          = module.eks.oidc_provider_arn
    tags                           = local.tags
    irsa_iam_role_path             = "/"
    irsa_iam_permissions_boundary  = null
  }  

}



# module "operator" {
#   source = "../modules/adot-operator"
#   enable_cert_manager = true
#   kubernetes_version  = module.eks.cluster_version
#   addon_context       = local.context
# }

# module "collector" {
#   source = "../modules/adot-collector"
#   cluster_name = module.eks.cluster_name
#   tags = local.tags
# }



