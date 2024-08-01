data "aws_iam_policy_document" "eks_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole", "sts:TagSession"]
  }
}

data "aws_iam_policy_document" "aws_assume_policy" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions   = ["sts:AssumeRole", "sts:TagSession"]
  }
}

resource "aws_iam_policy" "aws_assume_policy" {
  name        = "${module.eks.cluster_name}-pod-identity-aws-assume"
  description = "IAM Policy for Pod Identity"
  policy      = data.aws_iam_policy_document.aws_assume_policy.json
  tags        = local.tags
}

################################################################################
# ArgoCD EKS Access
################################################################################

resource "aws_iam_role" "argocd_hub" {
  name               = "${module.eks.cluster_name}-argocd-hub"
  assume_role_policy = data.aws_iam_policy_document.eks_assume.json
}

resource "aws_iam_role_policy_attachment" "argo_aws_assume_policy" {
  role       = aws_iam_role.argocd_hub.name
  policy_arn = aws_iam_policy.aws_assume_policy.arn
}
resource "aws_eks_pod_identity_association" "argocd_app_controller" {
  cluster_name    = module.eks.cluster_name
  namespace       = "argocd"
  service_account = "argocd-application-controller"
  role_arn        = aws_iam_role.argocd_hub.arn
}
resource "aws_eks_pod_identity_association" "argocd_api_server" {
  cluster_name    = module.eks.cluster_name
  namespace       = "argocd"
  service_account = "argocd-server"
  role_arn        = aws_iam_role.argocd_hub.arn
}



################################################################################
# ESO EKS Access
################################################################################

resource "aws_iam_role" "eso" {
  name               = "${module.eks.cluster_name}-eso"
  assume_role_policy = data.aws_iam_policy_document.eks_assume.json
}

data "aws_iam_policy_document" "eso" {
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:ListSecrets"]
    resources = ["*"]
  }

  statement {
    actions   = ["ssm:DescribeParameters"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    "secretsmanager:ListSecretVersionIds"]
    resources = [
      "arn:aws:secretsmanager:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:secret:${local.name}/*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
    "kms:Decrypt", ]
    resources = [
      "arn:aws:kms:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:key/*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
    "ssm:GetParameters", ]
    resources = [
      "arn:aws:ssm:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:parameter/${local.name}/*",
    ]
  }
}

# ## Create the IAM policy with the document created above
resource "aws_iam_policy" "eso" {
  name   = "${module.eks.cluster_name}-eso"
  policy = data.aws_iam_policy_document.eso.json
}

resource "aws_iam_role_policy_attachment" "eso_aws_assume_policy" {
  role       = aws_iam_role.eso.name
  policy_arn = aws_iam_policy.aws_assume_policy.arn
}

resource "aws_iam_role_policy_attachment" "eso" {
  role       = aws_iam_role.eso.name
  policy_arn = aws_iam_policy.eso.arn
}

resource "aws_eks_pod_identity_association" "eso_sa" {
  cluster_name    = module.eks.cluster_name
  namespace       = "external-secrets"
  service_account = "external-secrets-sa"
  role_arn        = aws_iam_role.eso.arn
}
