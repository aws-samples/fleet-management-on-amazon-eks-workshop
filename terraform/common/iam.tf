################################################################################
# ArgoCD EKS Access
################################################################################
resource "aws_iam_role" "argocd_central" {
  name = "${local.context_prefix}-argocd-central"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEksAuthToAssumeRoleForPodIdentity"
        Effect = "Allow"
        Action = ["sts:AssumeRole","sts:TagSession"]
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      },
    ]
  })
  inline_policy {
    name = "argocd"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["sts:AssumeRole", "sts:TagSession"]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }
  tags = local.tags
}
# Creating parameter for all clusters to read
resource "aws_ssm_parameter" "argocd_hub_role" {
  name  = "${local.context_prefix}-${var.ssm_parameter_name_argocd_role_suffix}"
  type  = "String"
  value = aws_iam_role.argocd_central.arn
}
