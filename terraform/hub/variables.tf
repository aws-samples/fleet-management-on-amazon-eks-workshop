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
    enable_karpenter                    = true
    enable_cw_prometheus                = true
  }
}

variable "enable_addon_selector" {
  description = "select addons using cluster selector"
  type        = bool
  default     = false
}


variable "secret_name_git_data_fleet" {
  description = "Secret name for Git data fleet"
  type        = string
  default     = "eks-fleet-workshop/git-data-fleet"
}

variable "secret_name_git_data_addons" {
  description = "Secret name for Git data addons"
  type        = string
  default     = "eks-fleet-workshop/git-data-addons"
}

variable "secret_name_git_data_platform" {
  description = "Secret name for Git data platform"
  type        = string
  default     = "eks-fleet-workshop/git-data-platform"
}

variable "secret_name_git_data_workload" {
  description = "Secret name for Git data workload"
  type        = string
  default     = "eks-fleet-workshop/git-data-workload"
}
