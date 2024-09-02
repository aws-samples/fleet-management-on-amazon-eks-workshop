locals {
  eks_org_data_script                   = "fleet-dashboard-reports.py"
  eks_org_data_glue_temp_dir            = "s3://${aws_s3_bucket.org_data_bucket.id}/glue-scripts/temp_dir_for_glue_jobs/"
  eks_org_data_glue_job_script_location = "s3://${aws_s3_bucket.org_data_bucket.id}/glue-scripts/${local.eks_org_data_script}"
  eks_org_data_script_location          = "glue-scripts/fleet-dashboard-reports.py"
  eks_dashboard_json_filename           = "eks_dashboard_file.json"
  dataset_names                         = keys(var.quicksight_datasets)
}
