variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "kubernetes_version" {
  description = "EKS version"
  type        = string
}

variable "addons" {
  description = "EKS addons"
  type        = any
  default = {
    enable_aws_load_balancer_controller = true
    enable_metrics_server               = true
    enable_karpenter                    = true
  }
}

variable "kms_key_admin_roles" {
  description = "list of role ARNs to add to the KMS policy"
  type        = list(string)
  default     = []

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