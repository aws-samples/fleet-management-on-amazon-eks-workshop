data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {
  # Do not include local zones
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}
data "aws_iam_session_context" "current" {
  # This data source provides information on the IAM source role of an STS assumed role
  # For non-role ARNs, this data source simply passes the ARN through issuer ARN
  # Ref https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2327#issuecomment-1355581682
  # Ref https://github.com/hashicorp/terraform-provider-aws/issues/28381
  arn = data.aws_caller_identity.current.arn
}

# Reading parameter created by hub cluster to allow access of argocd to spoke clusters
data "aws_ssm_parameter" "argocd_hub_role" {
  name = "${local.context_prefix}-${var.ssm_parameter_name_argocd_role_suffix}"
}

# Reading parameter created by common terraform module for team backend and frontend IAM roles
data "aws_ssm_parameter" "backend_team_view_role" {
  name  = "${local.context_prefix}-${var.backend_team_view_role_suffix}"
}
data "aws_ssm_parameter" "frontend_team_view_role" {
  name  = "${local.context_prefix}-${var.frontend_team_view_role_suffix}"
}


locals {
  context_prefix = var.project_context_prefix
  name            = "fleet-spoke-${terraform.workspace}"
  region          = data.aws_region.current.id
  cluster_version = var.kubernetes_version
  vpc_cidr        = var.vpc_cidr
  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  argocd_namespace    = "argocd"
  adot_collector_namespace = "adot-collector-kubeprometheus"
  adot_collector_serviceaccount = "adot-collector-kubeprometheus"
  opentelemetry_operator_namespace = "opentelemetry-operator-system"
  
  external_secrets = {
    namespace             = "external-secrets"
    service_account       = "external-secrets-sa"
    namespace_fleet       = "argocd"
  }
  aws_load_balancer_controller = {
    namespace       = "kube-system"
    service_account = "aws-load-balancer-controller-sa"
  }
  karpenter = {
    namespace       = "kube-system"
    service_account = "karpenter"
  }


  aws_addons = {
    enable_cert_manager                          = try(var.addons.enable_cert_manager, false)
    enable_aws_efs_csi_driver                    = try(var.addons.enable_aws_efs_csi_driver, false)
    enable_aws_fsx_csi_driver                    = try(var.addons.enable_aws_fsx_csi_driver, false)
    enable_aws_cloudwatch_metrics                = try(var.addons.enable_aws_cloudwatch_metrics, false)
    enable_aws_privateca_issuer                  = try(var.addons.enable_aws_privateca_issuer, false)
    enable_cluster_autoscaler                    = try(var.addons.enable_cluster_autoscaler, false)
    enable_external_dns                          = try(var.addons.enable_external_dns, false)
    enable_external_secrets                      = try(var.addons.enable_external_secrets, false)
    enable_aws_load_balancer_controller          = try(var.addons.enable_aws_load_balancer_controller, false)
    enable_fargate_fluentbit                     = try(var.addons.enable_fargate_fluentbit, false)
    enable_aws_for_fluentbit                     = try(var.addons.enable_aws_for_fluentbit, false)
    enable_aws_node_termination_handler          = try(var.addons.enable_aws_node_termination_handler, false)
    enable_karpenter                             = try(var.addons.enable_karpenter, false)
    enable_velero                                = try(var.addons.enable_velero, false)
    enable_aws_gateway_api_controller            = try(var.addons.enable_aws_gateway_api_controller, false)
    enable_aws_ebs_csi_resources                 = try(var.addons.enable_aws_ebs_csi_resources, false)
    enable_aws_secrets_store_csi_driver_provider = try(var.addons.enable_aws_secrets_store_csi_driver_provider, false)
    enable_ack_apigatewayv2                      = try(var.addons.enable_ack_apigatewayv2, false)
    enable_ack_dynamodb                          = try(var.addons.enable_ack_dynamodb, false)
    enable_ack_s3                                = try(var.addons.enable_ack_s3, false)
    enable_ack_rds                               = try(var.addons.enable_ack_rds, false)
    enable_ack_prometheusservice                 = try(var.addons.enable_ack_prometheusservice, false)
    enable_ack_emrcontainers                     = try(var.addons.enable_ack_emrcontainers, false)
    enable_ack_sfn                               = try(var.addons.enable_ack_sfn, false)
    enable_ack_eventbridge                       = try(var.addons.enable_ack_eventbridge, false)
    enable_aws_argocd                            = try(var.addons.enable_aws_argocd , false)
    enable_cw_prometheus                         = try(var.addons.enable_cw_prometheus, false)
    enable_cni_metrics_helper                    = try(var.addons.enable_cni_metrics_helper, false)

  }
  oss_addons = {
    enable_argocd                          = try(var.addons.enable_argocd, false)
    enable_argo_rollouts                   = try(var.addons.enable_argo_rollouts, false)
    enable_argo_events                     = try(var.addons.enable_argo_events, false)
    enable_argo_workflows                  = try(var.addons.enable_argo_workflows, false)
    enable_cluster_proportional_autoscaler = try(var.addons.enable_cluster_proportional_autoscaler, false)
    enable_gatekeeper                      = try(var.addons.enable_gatekeeper, false)
    enable_gpu_operator                    = try(var.addons.enable_gpu_operator, false)
    enable_ingress_nginx                   = try(var.addons.enable_ingress_nginx, false)
    enable_keda                            = try(var.addons.enable_keda, false)
    enable_kyverno                         = try(var.addons.enable_kyverno, false)
    enable_kyverno_policy_reporter         = try(var.addons.enable_kyverno_policy_reporter, false)
    enable_kyverno_policies                = try(var.addons.enable_kyverno_policies, false)
    enable_kube_prometheus_stack           = try(var.addons.enable_kube_prometheus_stack, false)
    enable_metrics_server                  = try(var.addons.enable_metrics_server, false)
    enable_prometheus_adapter              = try(var.addons.enable_prometheus_adapter, false)
    enable_secrets_store_csi_driver        = try(var.addons.enable_secrets_store_csi_driver, false)
    enable_vpa                             = try(var.addons.enable_vpa, false)
  }
  addons = merge(
    #
    # GitOps bridge does not use enable_XXXXX labels on the cluster secret in argocd.
    # Labels are removed to avoid confusion
    #
    #local.aws_addons,
    #local.oss_addons,
    { kubernetes_version = local.cluster_version },
    { aws_cluster_name = module.eks.cluster_name }
  )

  addons_metadata = merge(
    module.eks_blueprints_addons.gitops_metadata,
    {
      aws_cluster_name = module.eks.cluster_name
      aws_region       = local.region
      aws_account_id   = data.aws_caller_identity.current.account_id
      aws_vpc_id       = module.vpc.vpc_id
    },
    {
      karpenter_namespace = local.karpenter.namespace
      karpenter_service_account = local.karpenter.service_account
      karpenter_node_iam_role_name = module.karpenter.node_iam_role_name
      karpenter_sqs_queue_name = module.karpenter.queue_name
    },
    {
      external_secrets_namespace = local.external_secrets.namespace
      external_secrets_service_account = local.external_secrets.service_account
      external_secrets_namespace_fleet = local.external_secrets.namespace_fleet
      external_secrets_service_account_fleet = local.external_secrets.service_account
    },
    {
      aws_load_balancer_controller_namespace = local.aws_load_balancer_controller.namespace
      aws_load_balancer_controller_service_account = local.aws_load_balancer_controller.service_account
    },
    {
      # Opensource monitoring
      amp_endpoint_url = "${data.aws_ssm_parameter.amp_endpoint.value}"
      adot_collector_namespace = local.adot_collector_namespace
      adot_collector_serviceaccount = local.adot_collector_serviceaccount
      opentelemetry_operator_namespace = local.opentelemetry_operator_namespace
    }
  )

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/gitops-bridge-dev/gitops-bridge"
  }
}

data "aws_ssm_parameter" "amp_endpoint" {
  name = "${local.context_prefix}-${var.amazon_managed_prometheus_suffix}-endpoint"
}

resource "aws_secretsmanager_secret" "spoke_cluster_secret" {
  name                    = "fleet-hub-cluster/fleet-spoke-${terraform.workspace}"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "argocd_cluster_secret_version" {
  secret_id = aws_secretsmanager_secret.spoke_cluster_secret.id
  secret_string = jsonencode({
    metadata     = local.addons_metadata
    addons       = local.addons
    server       = module.eks.cluster_endpoint
    config = {
      tlsClientConfig = {
        insecure = false,
        caData   = module.eks.cluster_certificate_authority_data
      },
      awsAuthConfig = {
        clusterName = module.eks.cluster_name,
        roleARN     = aws_iam_role.spoke.arn
      }
    }
  })
}

################################################################################
# ArgoCD EKS Access
################################################################################
resource "aws_iam_role" "spoke" {
  name_prefix =  "${local.name}-argocd-spoke"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole", "sts:TagSession"]
    principals {
      type        = "AWS"
      identifiers = [data.aws_ssm_parameter.argocd_hub_role.value]
    }
  }
}

################################################################################
# EKS Blueprints Addons
################################################################################
module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.16.3"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  # Using GitOps Bridge
  create_kubernetes_resources = false

  # EKS Blueprints Addons
  enable_cert_manager                 = local.aws_addons.enable_cert_manager
  enable_aws_efs_csi_driver           = local.aws_addons.enable_aws_efs_csi_driver
  enable_aws_fsx_csi_driver           = local.aws_addons.enable_aws_fsx_csi_driver
  enable_aws_cloudwatch_metrics       = local.aws_addons.enable_aws_cloudwatch_metrics
  enable_aws_privateca_issuer         = local.aws_addons.enable_aws_privateca_issuer
  enable_cluster_autoscaler           = local.aws_addons.enable_cluster_autoscaler
  enable_external_dns                 = local.aws_addons.enable_external_dns
  # using pod identity for external secrets we don't need this
  #enable_external_secrets             = local.aws_addons.enable_external_secrets
  # using pod identity for external secrets we don't need this
  #enable_aws_load_balancer_controller = local.aws_addons.enable_aws_load_balancer_controller
  enable_fargate_fluentbit            = local.aws_addons.enable_fargate_fluentbit
  enable_aws_for_fluentbit            = local.aws_addons.enable_aws_for_fluentbit
  enable_aws_node_termination_handler = local.aws_addons.enable_aws_node_termination_handler
  # using pod identity for karpenter we don't need this
  #enable_karpenter                    = local.aws_addons.enable_karpenter
  enable_velero                       = local.aws_addons.enable_velero
  enable_aws_gateway_api_controller   = local.aws_addons.enable_aws_gateway_api_controller

  tags = local.tags
}

################################################################################
# EKS Cluster
################################################################################
#tfsec:ignore:aws-eks-enable-control-plane-logging
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.23.0"

  cluster_name                   = local.name
  cluster_version                = local.cluster_version
  cluster_endpoint_public_access = true
  authentication_mode            = "API"

  # Disabling encryption for workshop purposes
  cluster_encryption_config = {}

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_cluster_creator_admin_permissions = true

  access_entries = {
    # This is the role that will be assume by the hub cluster role to access the spoke cluster
    argocd = {
      principal_arn = aws_iam_role.spoke.arn

      policy_associations = {
        argocd = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
    backend_team = {
      user_name = "backend-team"
      kubernetes_groups = ["backend-team-view"]
      principal_arn     = data.aws_ssm_parameter.backend_team_view_role.value
    }
    frontend_team = {
      user_name = "frontend-team"
      kubernetes_groups = ["frontend-team-view"]
      principal_arn     = data.aws_ssm_parameter.frontend_team_view_role.value
    }
  }


  eks_managed_node_groups = {
    "${local.name}" = {
      ami_type = "BOTTLEROCKET_x86_64"
      instance_types = ["m5.large"]

      # Attach additional IAM policies to the Karpenter node IAM role
      # Adding IAM policy needed for fluentbit
      iam_role_additional_policies = {
        AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
        CloudWatchAgentServerPolicy = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
      }

      min_size     = 2
      max_size     = 6
      desired_size = 2

      taints = local.aws_addons.enable_karpenter ? {
        dedicated = {
          key    = "CriticalAddonsOnly"
          operator   = "Exists"
          effect    = "NO_SCHEDULE"
        }
      } : {}
    }
  }

  # EKS Addons
  cluster_addons = {
    coredns    = {
      addon_version  = "v1.11.3-eksbuild.1"
    }
    kube-proxy = {
      addon_version  = "v1.30.3-eksbuild.9"
    }
    amazon-cloudwatch-observability = {
      addon_version  = "v2.1.2-eksbuild.1"
    }
    aws-ebs-csi-driver = {
      addon_version  = "v1.35.0-eksbuild.1"
    }
    eks-pod-identity-agent = {
      addon_version  = "v1.3.2-eksbuild.2"
      before_compute = true
    }
    vpc-cni = {
      # Specify the VPC CNI addon should be deployed before compute to ensure
      # the addon is configured before data plane compute resources are created
      # See README for further details
      before_compute = true
      addon_version  = "v1.18.5-eksbuild.1"
      configuration_values = jsonencode({
        env = {
          # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        },
        enableNetworkPolicy = "true"
      })
    }
  }
  node_security_group_additional_rules = {
      # Allows Control Plane Nodes to talk to Worker nodes vpc cni metrics port
      vpc_cni_metrics_traffic = {
        description                   = "Cluster API to node 61678/tcp vpc cni metrics"
        protocol                      = "tcp"
        from_port                     = 61678
        to_port                       = 61678
        type                          = "ingress"
        source_cluster_security_group = true
      }
    }
  node_security_group_tags = merge(local.tags, {
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    # (i.e. - at most, only one security group should have this tag in your account)
    "karpenter.sh/discovery" = local.name
  })
  tags = local.tags
}


################################################################################
# Supporting Resources
################################################################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    # Tags subnets for Karpenter auto-discovery
    "karpenter.sh/discovery" = local.name
  }

  tags = local.tags
}

