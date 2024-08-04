data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}
data "aws_iam_session_context" "current" {
  # This data source provides information on the IAM source role of an STS assumed role
  # For non-role ARNs, this data source simply passes the ARN through issuer ARN
  # Ref https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2327#issuecomment-1355581682
  # Ref https://github.com/hashicorp/terraform-provider-aws/issues/28381
  arn = data.aws_caller_identity.current.arn
}

# Reading parameter created by hub cluster to allow access of argocd to spoke clusters
data "aws_ssm_parameter" "argocd_hub_role" {
  name = "/hub/argocd-hub-role"
}

################################################################################
# Kubernetes Access for Spoke Cluster
################################################################################

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", local.region]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", local.region]
    }
  }
}

locals {
  name            = "spoke-${terraform.workspace}"
  environment     = terraform.workspace
  region          = data.aws_region.current.id
  cluster_version = var.kubernetes_version
  vpc_cidr        = var.vpc_cidr
  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  git_private_ssh_key = data.terraform_remote_state.git.outputs.git_private_ssh_key

  gitops_fleet_url      = data.terraform_remote_state.git.outputs.gitops_fleet_url
  gitops_fleet_basepath = data.terraform_remote_state.git.outputs.gitops_fleet_basepath
  gitops_fleet_path     = data.terraform_remote_state.git.outputs.gitops_fleet_path
  gitops_fleet_revision = data.terraform_remote_state.git.outputs.gitops_fleet_revision

  gitops_addons_url      = data.terraform_remote_state.git.outputs.gitops_addons_url
  gitops_addons_basepath = data.terraform_remote_state.git.outputs.gitops_addons_basepath
  gitops_addons_path     = data.terraform_remote_state.git.outputs.gitops_addons_path
  gitops_addons_revision = data.terraform_remote_state.git.outputs.gitops_addons_revision
# This will be updated as a seconf project
  gitops_platform_url      = data.terraform_remote_state.git.outputs.gitops_platform_url
  gitops_platform_basepath = data.terraform_remote_state.git.outputs.gitops_platform_basepath
  gitops_platform_path     = data.terraform_remote_state.git.outputs.gitops_platform_path
  gitops_platform_revision = data.terraform_remote_state.git.outputs.gitops_platform_revision

  gitops_workload_url      = data.terraform_remote_state.git.outputs.gitops_workload_url
  gitops_workload_basepath = data.terraform_remote_state.git.outputs.gitops_workload_basepath
  gitops_workload_path     = data.terraform_remote_state.git.outputs.gitops_workload_path
  gitops_workload_revision = data.terraform_remote_state.git.outputs.gitops_workload_revision

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
    enable_kube_prometheus_stack           = try(var.addons.enable_kube_prometheus_stack, false)
    enable_metrics_server                  = try(var.addons.enable_metrics_server, false)
    enable_prometheus_adapter              = try(var.addons.enable_prometheus_adapter, false)
    enable_secrets_store_csi_driver        = try(var.addons.enable_secrets_store_csi_driver, false)
    enable_vpa                             = try(var.addons.enable_vpa, false)
  }

  addons = merge(
    local.aws_addons,
    local.oss_addons,
    { kubernetes_version = local.cluster_version },
    { aws_cluster_name = module.eks.cluster_name },
  )

  addons_metadata = merge(
    module.eks_blueprints_addons.gitops_metadata,
    {
      aws_karpenter_role_name = "${module.eks.cluster_name}-karpenter"
    },
    {
      aws_cluster_name = module.eks.cluster_name
      aws_region       = local.region
      aws_account_id   = data.aws_caller_identity.current.account_id
      aws_vpc_id       = module.vpc.vpc_id
    },
    {
      addons_repo_url      = local.gitops_addons_url
      addons_repo_basepath = local.gitops_addons_basepath
      addons_repo_path     = local.gitops_addons_path
      addons_repo_revision = local.gitops_addons_revision
    },
    {
      platform_repo_url      = local.gitops_platform_url
      platform_repo_basepath = local.gitops_platform_basepath
      platform_repo_path     = local.gitops_platform_path
      platform_repo_revision = local.gitops_platform_revision
    },
    {
      workload_repo_url      = local.gitops_workload_url
      workload_repo_basepath = local.gitops_workload_basepath
      workload_repo_path     = local.gitops_workload_path
      workload_repo_revision = local.gitops_workload_revision
    }
  )

  fleet_addons = merge(
    { kubernetes_version = local.cluster_version },
    { aws_cluster_name = module.eks.cluster_name },
    {fleet_member = true}
  )

  fleet_metadata = merge(
    {
      aws_cluster_name = module.eks.cluster_name
      aws_region       = local.region
      aws_account_id   = data.aws_caller_identity.current.account_id
      aws_vpc_id       = module.vpc.vpc_id
    },
    {
      fleet_repo_url      = local.gitops_fleet_url
      fleet_repo_basepath = local.gitops_fleet_basepath
      fleet_repo_path     = local.gitops_fleet_path
      fleet_repo_revision = local.gitops_fleet_revision
    },
  )
  argocd_apps = {
    addons   = file("${path.module}/bootstrap/addons.yaml")
    platform = file("${path.module}/bootstrap/platform.yaml")
  }

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/gitops-bridge-dev/gitops-bridge"
  }
}

resource "aws_secretsmanager_secret" "spoke_cluster_secret" {
  name                    = "hub-cluster/spoke-${terraform.workspace}"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "argocd_cluster_secret_version" {
  secret_id = aws_secretsmanager_secret.spoke_cluster_secret.id
  secret_string = jsonencode({
    cluster_name = module.eks.cluster_name
    environment  = local.environment
    metadata     = local.fleet_metadata
    addons       = local.fleet_addons
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

resource "kubernetes_secret" "git_secrets" {
  for_each = {
    git-addons = {
      type                  = "git"
      url                   = local.gitops_addons_url
      sshPrivateKey         = file(pathexpand(local.git_private_ssh_key))
      insecureIgnoreHostKey = "true"
    }
    git-platform = {
      type                  = "git"
      url                   = local.gitops_platform_url
      sshPrivateKey         = file(pathexpand(local.git_private_ssh_key))
      insecureIgnoreHostKey = "true"
    }
    git-workloads = {
      type                  = "git"
      url                   = local.gitops_workload_url
      sshPrivateKey         = file(pathexpand(local.git_private_ssh_key))
      insecureIgnoreHostKey = "true"
    }

  }

  metadata {
    name      = each.key
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }
  data = each.value
}
################################################################################
# GitOps Bridge: Bootstrap for Spoke Cluster
################################################################################
# Wait ArgoCD CRDs and "argocd" namespace to be created by hub cluster to this spoke cluster
resource "time_sleep" "wait_for_argocd_namespace_and_crds" {
  create_duration = "7m"

  depends_on = [aws_secretsmanager_secret_version.argocd_cluster_secret_version]
}
module "gitops_bridge_bootstrap_spoke" {
  source = "gitops-bridge-dev/gitops-bridge/helm"

  install = false # Not installing argocd via helm on spoke cluster
  cluster = {
    cluster_name = module.eks.cluster_name
    environment  = local.environment
    metadata     = local.addons_metadata
    addons       = local.addons
  }
  apps = local.argocd_apps

  depends_on = [time_sleep.wait_for_argocd_namespace_and_crds]
}

################################################################################
# EKS ACK Addons
################################################################################
module "eks_ack_addons" {
  source = "aws-ia/eks-ack-addons/aws"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  oidc_provider_arn = module.eks.oidc_provider_arn

  # Using GitOps Bridge
  create_kubernetes_resources = false

  # ACK Controllers to enable
  enable_apigatewayv2      = try(local.aws_addons.enable_ack_apigatewayv2, false)
  enable_dynamodb          = try(local.aws_addons.enable_ack_dynamodb, false)
  enable_s3                = try(local.aws_addons.enable_ack_s3, false)
  enable_rds               = try(local.aws_addons.enable_ack_rds, false)
  enable_prometheusservice = try(local.aws_addons.enable_ack_prometheusservice, false)
  enable_emrcontainers     = try(local.aws_addons.enable_ack_emrcontainers, false)
  enable_sfn               = try(local.aws_addons.enable_ack_sfn, false)
  enable_eventbridge       = try(local.aws_addons.enable_ack_eventbridge, false)

  tags = local.tags
}

################################################################################
# Dynamo DB IAM Role
################################################################################
locals {
  table_name = local.environment == "prod" ? "Items-Prod" : "Items-Staging"
}

module "dynamodb_workshop_irsa_aws" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.14"

  role_name = "carts-${local.environment}-role"

  role_policy_arns = {
    dynamodb = aws_iam_policy.dynamodb_workshop.arn
  }

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["carts:carts"]
    }
  }

  tags = local.tags
}

resource "aws_iam_policy" "dynamodb_workshop" {
  name_prefix = "argocd-workshop"
  description = "IAM policy for ArgoCD on EKS Workshop DynamoDB"
  path        = "/"
  policy      = data.aws_iam_policy_document.dynamodb_workshop.json

  tags = local.tags
}

data "aws_iam_policy_document" "dynamodb_workshop" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:*"
    ]

    resources = [
      "arn:aws:dynamodb:${local.region}:${data.aws_caller_identity.current.account_id}:table/${local.table_name}",
      "arn:aws:dynamodb:${local.region}:${data.aws_caller_identity.current.account_id}:table/${local.table_name}/index/*"
    ]
  }
}

################################################################################
# ArgoCD EKS Access
################################################################################
resource "aws_iam_role" "spoke" {
  name               = "${local.name}-argocd-spoke"
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
  version = "~> 1.0"

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
  enable_external_secrets             = local.aws_addons.enable_external_secrets
  enable_aws_load_balancer_controller = local.aws_addons.enable_aws_load_balancer_controller
  enable_fargate_fluentbit            = local.aws_addons.enable_fargate_fluentbit
  enable_aws_for_fluentbit            = local.aws_addons.enable_aws_for_fluentbit
  enable_aws_node_termination_handler = local.aws_addons.enable_aws_node_termination_handler
  enable_karpenter                    = local.aws_addons.enable_karpenter
  enable_velero                       = local.aws_addons.enable_velero
  enable_aws_gateway_api_controller   = local.aws_addons.enable_aws_gateway_api_controller

  karpenter_node = {
    # Use static name so that it matches what is defined in `karpenter.yaml` example manifest
    iam_role_use_name_prefix = false
  }

  tags = local.tags
}

################################################################################
# EKS Cluster
################################################################################
#tfsec:ignore:aws-eks-enable-control-plane-logging
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.20.0"

  cluster_name                   = local.name
  cluster_version                = local.cluster_version
  cluster_endpoint_public_access = true

  kms_key_administrators = distinct(concat([
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"],
    var.kms_key_admin_roles,
    [data.aws_iam_session_context.current.issuer_arn]
  ))
  
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets


  enable_cluster_creator_admin_permissions = true

  access_entries = {
    # One access entry with a policy associated
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
  }

  eks_managed_node_groups = {
    spoke = {
      instance_types = ["c5.large"]

      min_size     = 3
      max_size     = 10
      desired_size = 3
      iam_role_additional_policies = {
          cloudwatch_agent_server_policy = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
      }
    }
  }

  # EKS Addons
  cluster_addons = {
    coredns    = {}
    kube-proxy = {}
    amazon-cloudwatch-observability = {
      most_recent    = true
      before_compute = true
    }
    eks-pod-identity-agent = {
      most_recent    = true
      before_compute = true
    }
    vpc-cni = {
      # Specify the VPC CNI addon should be deployed before compute to ensure
      # the addon is configured before data plane compute resources are created
      # See README for further details
      before_compute = true
      most_recent    = true # To ensure access to the latest settings provided
      configuration_values = jsonencode({
        env = {
          # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        },
        enableNetworkPolicy = "true"
      })
    }
    aws-ebs-csi-driver = {
      service_account_role_arn = module.ebs_csi_driver_irsa.iam_role_arn
    }
  }
  tags = merge(local.tags, {
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    # (i.e. - at most, only one security group should have this tag in your account)
    "karpenter.sh/discovery" = local.name
  })
}

resource "aws_eks_access_entry" "karpenter_node_access_entry" {
  cluster_name      = module.eks.cluster_name
  principal_arn     = module.eks_blueprints_addons.karpenter.node_iam_role_arn
  kubernetes_groups = []
  type              = "EC2_LINUX"
  lifecycle {
    ignore_changes = [kubernetes_groups]
  }
}

module "ebs_csi_driver_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.20"

  role_name_prefix = "${module.eks.cluster_name}-ebs-csi-"

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

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
