 resource "aws_cloudwatch_dashboard" "cni-helper-cw-dashboard" {
  dashboard_name = "Fleet_Management_Vpc_Cni"
  dashboard_body = replace( file("cw-dashboard-vpc-cni.json"),"**aws_region**", local.region )

}

 resource "aws_cloudwatch_dashboard" "karpenter-cw-dashboard" {
  dashboard_name = "Fleet_Management_Karpenter"
  dashboard_body = replace( file("cw-dashboard-karpenter.json"),"**aws_region**", local.region )

}

 resource "aws_cloudwatch_dashboard" "coredns-cw-dashboard" {
  dashboard_name = "Fleet_Management_CoreDNS"
  dashboard_body = replace( file("cw-dashboard-coredns.json"),"**aws_region**", local.region )

}

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
# Monitoring notifications
################################################################################
resource "aws_sns_topic" "fleet-alerts" {
  name = "fleet-alerts"
}

resource "aws_sqs_queue" "fleet_alerts_queue" {
  name = "fleet_alerts"
}

resource "aws_sns_topic_subscription" "fleet_alerts_sqs_target" {
  topic_arn = aws_sns_topic.fleet-alerts.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.fleet_alerts_queue.arn
}

################################################################################
# ADOT
################################################################################
#data "aws_partition" "current" {}

# locals{
#   context = {
#     aws_caller_identity_account_id = data.aws_caller_identity.current.account_id
#     aws_caller_identity_arn        = data.aws_caller_identity.current.arn
#     aws_eks_cluster_endpoint       = module.eks.cluster_endpoint
#     aws_partition_id               = data.aws_partition.current.partition
#     aws_region_name                = data.aws_region.current.name
#     eks_cluster_id                 = module.eks.cluster_name
#     eks_oidc_issuer_url            = module.eks.oidc_provider
#     eks_oidc_provider_arn          = module.eks.oidc_provider_arn
#     tags                           = local.tags
#     irsa_iam_role_path             = "/"
#     irsa_iam_permissions_boundary  = null
#   }  

# }

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
locals{
  adot_collector_namespace = "adot-collector-kubeprometheus"
  adot_collector_serviceaccount = "adot-collector-kubeprometheus"   
  opentelemetry_namespace = "opentelemetry-operator-system"
}
resource "kubernetes_namespace" "opentelemetry_operator" {
  metadata {
    name = local.opentelemetry_namespace
  }
}

module "adot_collector_pod_identity" {
  source = "terraform-aws-modules/eks-pod-identity/aws"
  version = "~> 1.4.0"

  name = "adot-collector"

  additional_policy_arns = {
      "PrometheusReadWrite": "arn:aws:iam::aws:policy/AmazonPrometheusRemoteWriteAccess",
      "XrayAccess": "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
  }

  # Pod Identity Associations
  associations = {
    addon = {
      cluster_name = module.eks.cluster_name
      namespace       = local.adot_collector_namespace
      service_account = local.adot_collector_serviceaccount
    }
  }
  tags = local.tags
}
