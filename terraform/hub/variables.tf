variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.29"
}

variable "kms_key_admin_roles" {
  description = "list of role ARNs to add to the KMS policy"
  type        = list(string)
  default     = []
}

variable "addons" {
  description = "Kubernetes addons"
  type        = any
  default = {
    enable_aws_load_balancer_controller = true
    enable_aws_ebs_csi_resources        = true # generate gp2 and gp3 storage classes for ebs-csi
    enable_metrics_server               = true
    enable_external_secrets             = true
    enable_argocd                       = true
    enable_kyverno                      = true
    enable_kyverno_policy_reporter      = true
    enable_kyverno_policies             = true
    enable_karpenter                    = true
    enable_cw_prometheus                = true
  }
}


variable "secret_name_git_data_addons" {
  description = "Secret name for Git data addons"
  type        = string
  default     = "eks-fleet-workshop-gitops-addons"
}

variable "secret_name_git_data_fleet" {
  description = "Secret name for Git data fleet"
  type        = string
  default     = "eks-fleet-workshop-gitops-fleet"
}

variable "secret_name_git_data_platform" {
  description = "Secret name for Git data platform"
  type        = string
  default     = "eks-fleet-workshop-gitops-platform"
}

variable "secret_name_git_data_workloads" {
  description = "Secret name for Git data workloads"
  type        = string
  default     = "eks-fleet-workshop-gitops-workloads"
}


variable "project_context_prefix" {
  description = "Prefix for project"
  type        = string
  default     = "eks-fleet-workshop-gitops"
}

variable "ssm_parameter_name_argocd_role_suffix" {
  description = "SSM parameter name for ArgoCD role"
  type        = string
  default     = "argocd-central-role"
}

variable "amazon_managed_prometheus_suffix" {
  description = "SSM parameter name for Amazon Manged Prometheus"
  type        = string
  default     = "amp-hub"
}