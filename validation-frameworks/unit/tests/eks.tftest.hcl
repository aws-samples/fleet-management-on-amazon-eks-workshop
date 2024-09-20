variables {
  eks_cluster_version = "1.30"
  region = "us-east-1"
  name                = "fleet-hub-cluster"
  vpc_cidr            = "10.0.0.0/16"
}

run "create_eks_cluster" {
  command = plan
  module {
    source = "../../../terraform/hub"
  }
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
    condition     = contains(keys(module.eks.eks_managed_node_groups), "fleet-hub-cluster")
    error_message = "The managed node group should be named 'fleet-hub-cluster'"
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
}