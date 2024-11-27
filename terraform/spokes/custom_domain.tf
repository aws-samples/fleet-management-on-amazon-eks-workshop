variable "hosted_zone_name" {
  type        = string
  description = "Route53 domain for the cluster."
  default     = ""
}

locals {
  external_dns = {
    namespace             = "external-dns"
    service_account       = "external-dns-sa"
    namespace_fleet       = "argocd"
    hosted_zone_name      = var.hosted_zone_name
    policy                = "sync"
  }

  external_dns_addons_metadata = merge(
    {
      external_dns_namespace = local.external_dns.namespace
      external_dns_service_account = local.external_dns.service_account
      external_dns_domain_filters = "${local.name}.${local.external_dns.hosted_zone_name}"
      external_dns_policy = local.external_dns.policy
    }
  )
}

# Retrieve existing root hosted zone
data "aws_route53_zone" "root" {
  name = local.external_dns.hosted_zone_name
}

# Get HostedZone four our deployment
resource "aws_route53_zone" "sub" {
  name = "${local.name}.${local.external_dns.hosted_zone_name}"
}

# Validate records for the new HostedZone
resource "aws_route53_record" "ns" {
  zone_id = data.aws_route53_zone.root.zone_id
  name    = "${local.name}.${local.external_dns.hosted_zone_name}"
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.sub.name_servers
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = "${local.name}.${local.external_dns.hosted_zone_name}"
  zone_id     = aws_route53_zone.sub.zone_id

  subject_alternative_names = [
    "*.${local.name}.${local.external_dns.hosted_zone_name}"
  ]

  wait_for_validation = true

  tags = {
    Name = "${local.name}.${local.external_dns.hosted_zone_name}"
  }
}

################################################################################
# External DNS EKS Access
################################################################################
module "external_dns_pod_identity" {
  source = "terraform-aws-modules/eks-pod-identity/aws"
  version = "~> 1.4.0"

  name = "external-dns"

  attach_external_dns_policy        = true
  external_dns_hosted_zone_arns     = [aws_route53_zone.sub.arn]

  # Pod Identity Associations
  associations = {
    addon = {
      cluster_name    = module.eks.cluster_name
      namespace       = local.external_dns.namespace
      service_account = local.external_dns.service_account
    },
    fleet = {
      cluster_name    = module.eks.cluster_name
      namespace       = local.external_dns.namespace_fleet
      service_account = local.external_dns.service_account
    }
  }

  tags = local.tags
}