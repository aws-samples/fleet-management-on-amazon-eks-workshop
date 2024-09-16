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


