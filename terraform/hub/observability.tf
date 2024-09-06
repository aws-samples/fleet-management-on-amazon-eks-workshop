 resource "aws_cloudwatch_dashboard" "cni-helper-cw-dashboard" {
  dashboard_name = "VPC-CNI"
  dashboard_body = replace( file("vpc-cni-dw-dashboard.json"),"**aws_region**", local.region )

}

locals{
    scrape_interval = "30s"
    scrape_timeout  = "10s"
}


#Managed Prometheus workspace
resource "aws_prometheus_workspace" "amp" {
  alias = "fleet-hub"
  tags  = local.tags
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
      workspace_arn = aws_prometheus_workspace.amp.arn
    }
  }
  
  alias = "fleet-hub"
  #scrape_configuration = file("${path.module}/../common/scraper-config.yaml")
  #scrape_configuration = replace(replace(file("${path.module}/../common/scraper-config.yaml"), "{scrape_interval}", local.scrape_interval), "{scrape_timeout}",local.scrape_timeout, "{cluster}", local.name), "{region}",local.region,"{account_id}", data.aws_caller_identity.current.account_id)
  #scrape_configuration = replace(replace(file("${path.module}/../common/scraper-config.yaml"), "**scrape_interval**", local.scrape_interval), "**scrape_timeout**",local.scrape_timeout, "**cluster**", local.name), "**region**",local.region,"**account_id**", data.aws_caller_identity.current.account_id)
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



# module "grafana_pod_identity" {
#   source = "terraform-aws-modules/eks-pod-identity/aws"
#   version = "~> 1.4.0"

#   name = "grafana-sa"

#   #amazon_managed_service_prometheus_workspace_arns = [aws_prometheus_workspace.amp.arn]
#   additional_policy_arns = {
#     "PrometheusQueryAccess ": "arn:aws:iam::aws:policy/AmazonPrometheusQueryAccess"
#   }


#   # Pod Identity Associations
#   association_defaults = {
#     namespace       = "grafana-operator"
#   }
#   associations = {
#     server = {
#       cluster_name = module.eks.cluster_name
#       service_account = "grafana-sa"
#     }
#   }

#   tags = local.tags
# }



data "aws_iam_policy_document" "grafana_irsa_trust_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:sub"
      values   = ["system:serviceaccount:grafana-operator:grafana-sa"]
    }
    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:aud"
      values   = ["sts.amazonaws.com"]
    }    

    principals {
      identifiers = [module.eks.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "grafana_irsa_role" {
  name                 = "grafana-irsa-role"
  assume_role_policy   = data.aws_iam_policy_document.grafana_irsa_trust_policy.json
  force_detach_policies = true
}
resource "aws_iam_role_policy_attachment" "prometheus_query_access" {
  role       = aws_iam_role.grafana_irsa_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonPrometheusQueryAccess"
}
output "grafana_irsa_role_arn" {
  value       = aws_iam_role.grafana_irsa_role.arn
  description = "ARN of the Grafana IRSA role"
}