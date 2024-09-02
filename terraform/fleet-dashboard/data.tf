data "aws_caller_identity" "current" {}

data "aws_iam_session_context" "current_role" {
  arn = data.aws_caller_identity.current.arn
}

data "aws_iam_policy_document" "glue_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com", "quicksight.amazonaws.com"]
    }
  }
}
