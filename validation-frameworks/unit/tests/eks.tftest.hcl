variables {
  eks_cluster_version = "1.30"
  region = "us-east-1"
  name                = "eks-validation-frameworks"
  vpc_cidr            = "10.1.0.0/16"
}

run "create_eks_cluster" {
  command = plan
  
  assert {
    condition     = module.eks.cluster_name != ""
    error_message = "EKS cluster name should not be empty"
  }
  
  assert {
    condition     = module.eks.cluster_version == var.eks_cluster_version
    error_message = "EKS cluster version should match the specified version"
  }

  assert {
    condition     = length(module.eks.eks_managed_node_groups) == 1
    error_message = "There should be exactly one managed node group"
  }

  assert {
    condition     = contains(keys(module.eks.eks_managed_node_groups), "karpenter")
    error_message = "The managed node group should be named 'karpenter'"
  }
  
  assert {
    condition     = module.karpenter.node_iam_role_name == local.name
    error_message = "Karpenter node IAM role name should match the local name"
  }
  
  assert {
    condition     = helm_release.karpenter.namespace == "kube-system"
    error_message = "Karpenter Helm release should be in kube-system namespace"
  }

  assert {
    condition     = helm_release.karpenter.chart == "karpenter"
    error_message = "Karpenter Helm chart name should be 'karpenter'"
  }

  assert {
    condition     = helm_release.karpenter.version == "0.37.0"
    error_message = "Karpenter Helm chart version should be 0.37.0"
  }
  
  assert {
    condition     = module.vpc.name == local.name
    error_message = "VPC name should match the local name"
  }

  assert {
    condition     = module.vpc.vpc_cidr_block == var.vpc_cidr
    error_message = "VPC CIDR block should match the specified CIDR"
  }
  
  assert {
    condition     = length(module.vpc.private_subnets) == length(local.azs)
    error_message = "Number of private subnets should match the number of AZs"
  }

  assert {
    condition     = length(module.vpc.public_subnets) == length(local.azs)
    error_message = "Number of public subnets should match the number of AZs"
  }

  assert {
    condition     = length(module.vpc.intra_subnets) == length(local.azs)
    error_message = "Number of intra subnets should match the number of AZs"
  }

}