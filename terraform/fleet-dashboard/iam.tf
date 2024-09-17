resource "aws_iam_role" "quicksight_role" {
  name = "${var.workshop_name}-quicksight"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "quicksight.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "quicksight_policy_attachment" {
  role       = aws_iam_role.quicksight_role.name
  policy_arn = aws_iam_policy.eks_insights_s3_access.arn
}

resource "aws_iam_role_policy_attachment" "quicksight_policy_attachment_svc_role" {
  role       = "aws-quicksight-service-role-v0"
  policy_arn = aws_iam_policy.eks_insights_s3_access.arn
}

resource "aws_iam_policy" "eks_insights_s3_access" {
  name        = "${var.workshop_name}-s3-permissions"
  description = "Policy to allow EKS Fleet management access to S3 bucket"

  policy = data.aws_iam_policy_document.eks_insights_role_policy_document.json
}

data "aws_iam_policy_document" "eks_insights_role_policy_document" {
  statement {
    sid       = "AllowS3Access"
    effect    = "Allow"
    resources = ["arn:aws:s3:::${aws_s3_bucket.org_data_bucket.id}", "arn:aws:s3:::${aws_s3_bucket.org_data_bucket.id}/*"]

    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
    ]
  }

  statement {
    sid       = "AllowCreatingLogGroups"
    effect    = "Allow"
    resources = ["arn:aws:logs:*:*:*"]
    actions   = ["logs:CreateLogGroup"]
  }

  statement {
    sid       = "AllowWritingLogs"
    effect    = "Allow"
    resources = ["arn:aws:logs:*:*:log-group:/aws-glue/*/*:*"]
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }

  statement {
    sid       = "AllowEKSClustersAccess"
    effect    = "Allow"
    resources = ["arn:aws:eks:*:*:*"]
    actions = [
      "eks:ListClusters",
      "eks:ListInsights",
      "eks:ListAddons",
      "eks:DescribeCluster",
      "eks:DescribeAddonConfiguration",
      "eks:DescribeAddonVersions",
      "eks:DescribeAddon",
      "eks:DescribeInsight",
      "eks:ListAccessEntries",
      "eks:ListAccessPolicies",
      "eks:ListAssociatedAccessPolicies"
    ]
  }
  statement {
    sid       = "AllowQuickSightAccess"
    effect    = "Allow"
    resources = ["arn:aws:quicksight:*:*:*"]
    actions = [
      "quicksight:CancelIngestion",
      "quicksight:CreateIngestion",
      "quicksight:ListDataSets",
      "quicksight:DescribeDataSet",
      "quicksight:DescribeDataSetPermissions",
      "quicksight:DescribeIngestion",
      "quicksight:ListIngestions",
      "quicksight:PassDataSet",
      "quicksight:UpdateDataSet",
    ]
  }
}

resource "aws_s3_bucket_policy" "manifest_bucket_policy" {
  bucket = aws_s3_bucket.org_data_bucket.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.quicksight_role.arn}"
      },
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.org_data_bucket.id}",
        "arn:aws:s3:::${aws_s3_bucket.org_data_bucket.id}/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role" "eks_insights_glue_role" {
  name               = "${var.workshop_name}-dashboard"
  assume_role_policy = data.aws_iam_policy_document.glue_assume.json
}


resource "aws_iam_role_policy_attachment" "eks_insights_s3_access_policy_attachment" {
  policy_arn = aws_iam_policy.eks_insights_role_access_policy.arn
  role       = aws_iam_role.eks_insights_glue_role.name
}

resource "aws_iam_policy" "eks_insights_role_access_policy" {
  name   = "${var.workshop_name}-dashboard-permissions"
  policy = data.aws_iam_policy_document.eks_insights_role_policy_document.json
}

