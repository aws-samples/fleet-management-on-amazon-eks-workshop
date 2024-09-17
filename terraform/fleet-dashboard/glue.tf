resource "aws_s3_object" "eks_org_data_script" {
  bucket = aws_s3_bucket.org_data_bucket.id
  key    = local.eks_org_data_script_location
  acl    = "private"
  source = "${path.module}/${local.eks_org_data_script_location}"
  etag   = filemd5("${path.module}/${local.eks_org_data_script_location}")
}

resource "aws_glue_job" "eks_org_data_glue_job" {
  name         = var.eks_org_data_glue_job_name
  role_arn     = data.aws_iam_session_context.current_role.issuer_arn
  glue_version = var.eks_org_data_glue_version

  # security_configuration = var.eks_insights_glue_sec_config
  command {
    name            = "pythonshell"
    script_location = local.eks_org_data_glue_job_script_location
    python_version  = var.eks_org_data_glue_python_version
  }

  default_arguments = {
    "--enable-job-insights"              = "false"
    "--additional-python-modules"        = "boto3>=1.34.50"
    "--enable-glue-datacatalog"          = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--job-language"                     = "python"
    "--TempDir"                          = local.eks_org_data_glue_temp_dir
    "--S3_BUCKET_NAME"                   = aws_s3_bucket.org_data_bucket.id
    "--ARGO_CD_NAMESPACE"    = var.argocd_namespace
    "--QS_DASHBOARD_REGION"  = var.eks_dashboard_qs_region
    "--QS_DASHBOARD_ACCOUNT" = data.aws_caller_identity.current.account_id
  }
}

resource "time_sleep" "wait_60_seconds" {
  depends_on      = [aws_glue_job.eks_org_data_glue_job]
  create_duration = "60s"
}

resource "aws_glue_trigger" "eks_org_data_glue_job_adhoc_trigger" {
  name = "${var.eks_org_data_glue_job_name}-adhoc-trigger"
  type = "ON_DEMAND"

  actions {
    job_name = aws_glue_job.eks_org_data_glue_job.name
  }
  depends_on = [aws_glue_job.eks_org_data_glue_job, time_sleep.wait_60_seconds]
}

resource "aws_glue_trigger" "eks_org_data_glue_job_trigger" {
  name     = "${var.eks_org_data_glue_job_name}-trigger"
  schedule = "cron(0 22 * * ? *)"
  type     = "SCHEDULED"

  actions {
    job_name = aws_glue_job.eks_org_data_glue_job.name
  }
  depends_on = [aws_glue_job.eks_org_data_glue_job]
}