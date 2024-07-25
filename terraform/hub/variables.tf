variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"

}
variable "kubernetes_version" {
  description = "EKS version"
  type        = string
  default     = "1.27"
}

variable "aws_auth_roles" {
  description = "additional aws auth roles"
  type = list(
    object(
      {
        rolearn  = string
        username = string
        groups = list(string
        )
      }
    )
  )
  default = []
  # example structure
  #  {
  #     rolearn  = "arn:aws:iam::12345678901:role/role1"
  #     username = "role1"
  #     groups   = ["system:masters"]
  #   }
}

variable "kms_key_admin_roles" {
  description = "list of role ARNs to add to the KMS policy"
  type        = list(string)
  default     = []

}
