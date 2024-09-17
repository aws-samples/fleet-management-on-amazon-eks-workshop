data "template_file" "manifest_template" {
  for_each = var.quicksight_datasets
  template = file("${path.module}/s3_manifest_template.tpl")
  vars = {
    S3_BUCKET_NAME = aws_s3_bucket.org_data_bucket.id
    REPORT_NAME    = each.key
  }
}

resource "aws_s3_object" "manifest_objects" {
  for_each = data.template_file.manifest_template
  bucket   = aws_s3_bucket.org_data_bucket.id
  key      = "manifests/${each.key}.json"
  content  = each.value.rendered
}

resource "aws_quicksight_group" "eks_dashboard_qs_group" {
  group_name = var.quicksight_access_group_name
}

resource "aws_quicksight_group_membership" "eks_dashboard_qs_group_membership" {
  for_each    = toset(var.quicksight_access_group_membership)
  group_name  = aws_quicksight_group.eks_dashboard_qs_group.group_name
  member_name = each.value
}

resource "aws_quicksight_data_source" "qs_data_source" {
  for_each       = data.template_file.manifest_template
  data_source_id = each.key
  name           = each.key

  parameters {
    s3 {
      manifest_file_location {
        bucket = aws_s3_bucket.org_data_bucket.id
        key    = "manifests/${each.key}.json"
      }
    }
  }

  type = "S3"

  depends_on = [aws_s3_object.manifest_objects, aws_glue_job.eks_org_data_glue_job, aws_s3_bucket_policy.manifest_bucket_policy, aws_glue_trigger.eks_org_data_glue_job_adhoc_trigger]
}

resource "aws_quicksight_data_set" "eks_dashboard_qs_dataset" {
  for_each = var.quicksight_datasets

  data_set_id = each.key
  name        = each.key
  import_mode = each.value.import_mode

  physical_table_map {
    physical_table_map_id = each.key

    s3_source {
      data_source_arn = aws_quicksight_data_source.qs_data_source[each.key].arn

      dynamic "input_columns" {
        for_each = each.value.input_columns
        content {
          name = input_columns.value.name
          type = input_columns.value.type
        }
      }

      upload_settings {
        format = each.value.upload_settings_format
      }
    }
  }

  dynamic "logical_table_map" {
    for_each = [each.value.logical_table_map]
    content {
      alias                = "${each.key}-alias"
      logical_table_map_id = "${each.key}-alias"

      source {
        physical_table_id = each.key
      }

      dynamic "data_transforms" {
        for_each = logical_table_map.value.cast_columns
        content {
          cast_column_type_operation {
            column_name     = data_transforms.value.column_name
            new_column_type = data_transforms.value.new_column_type
          }
        }
      }
      dynamic "data_transforms" {
        for_each = logical_table_map.value.rename_columns
        content {
          rename_column_operation {
            column_name     = data_transforms.value.column_name
            new_column_name = data_transforms.value.new_column_name
          }
        }
      }
      dynamic "data_transforms" {
        for_each = logical_table_map.value.geo_columns
        content {
          tag_column_operation {
            column_name = data_transforms.value.column_name
            tags {
              column_geographic_role = data_transforms.value.geographic_role
            }
          }
        }
      }
    }
  }

  permissions {
    actions = [
      "quicksight:CancelIngestion",
      "quicksight:CreateIngestion",
      "quicksight:DeleteDataSet",
      "quicksight:DescribeDataSet",
      "quicksight:DescribeDataSetPermissions",
      "quicksight:DescribeIngestion",
      "quicksight:ListIngestions",
      "quicksight:PassDataSet",
      "quicksight:UpdateDataSet",
      "quicksight:UpdateDataSetPermissions",
    ]
    principal = "arn:aws:quicksight:${var.eks_dashboard_qs_region}:${data.aws_caller_identity.current.account_id}:group/default/${aws_quicksight_group.eks_dashboard_qs_group.group_name}"
  }
  depends_on = [aws_quicksight_group.eks_dashboard_qs_group, aws_quicksight_group_membership.eks_dashboard_qs_group_membership, aws_quicksight_data_source.qs_data_source]
}

resource "aws_quicksight_refresh_schedule" "eks_dashboard_qs_dataset_refresh_schedule" {
  for_each    = var.quicksight_datasets
  data_set_id = each.key
  schedule_id = "${each.key}-schedule"

  schedule {
    refresh_type = "FULL_REFRESH"

    schedule_frequency {
      interval        = "DAILY"
      time_of_the_day = "23:00"
    }
  }

  depends_on = [aws_quicksight_data_set.eks_dashboard_qs_dataset]
}

data "template_file" "qs_dashboard_template" {
  template = file("${path.module}/quicksight_dashboard.tpl")
  vars = {
    AWS_ACCOUNT_ID              = data.aws_caller_identity.current.account_id
    AWS_REGION                  = var.eks_dashboard_qs_region
    UPGRADE_INSIGHTS_DATASET    = "eks-fleet-clusters-upgrade-insights"
    CLUSTERS_DATA_DATASET       = "eks-fleet-clusters-data"
    SUPPORT_DATA_DATASET        = "eks-fleet-support-data"
    CLUSTERS_DETAILS_DATASET    = "eks-fleet-clusters-details"
    KUBERNETES_RELEASE_CALENDAR = "eks-fleet-kubernetes-release-calendar"
    CLUSTERS_SUMMARY_DATASET    = "eks-fleet-clusters-summary-data"
    ARGO_PROJECTS_DATASET       = "eks-fleet-argo-projects-data"
    QS_DASHBOARD_NAME           = var.eks_dashboard_name
  }
}

resource "local_file" "dashboard_json_file" {
  content  = data.template_file.qs_dashboard_template.rendered
  filename = "${path.module}/${local.eks_dashboard_json_filename}"
}

resource "null_resource" "create_qs_dashboard" {
  triggers = {
    policy_sha1 = "${sha1(file("${path.module}/quicksight_dashboard.tpl"))}"
  }

  provisioner "local-exec" {
    command = <<-EOT
    aws quicksight delete-dashboard --region ${var.eks_dashboard_qs_region} --aws-account-id ${data.aws_caller_identity.current.account_id} --dashboard-id ${var.eks_dashboard_name} || true &&\
    aws quicksight create-dashboard --region ${var.eks_dashboard_qs_region} --aws-account-id ${data.aws_caller_identity.current.account_id} --cli-input-json file://${path.module}/${local.eks_dashboard_json_filename} &&\
    sleep 30 &&\ 
    aws quicksight update-dashboard-permissions --region ${var.eks_dashboard_qs_region} --aws-account-id ${data.aws_caller_identity.current.account_id} --dashboard-id ${var.eks_dashboard_name} --grant-permissions Principal=arn:aws:quicksight:${var.eks_dashboard_qs_region}:${data.aws_caller_identity.current.account_id}:group/default/${aws_quicksight_group.eks_dashboard_qs_group.group_name},Actions=quicksight:DescribeDashboard,quicksight:ListDashboardVersions,quicksight:UpdateDashboardPermissions,quicksight:QueryDashboard,quicksight:UpdateDashboard,quicksight:DeleteDashboard,quicksight:UpdateDashboardPublishedVersion,quicksight:DescribeDashboardPermissions
    EOT
  }

  depends_on = [
    local_file.dashboard_json_file,
    aws_glue_trigger.eks_org_data_glue_job_adhoc_trigger,
    aws_quicksight_data_source.qs_data_source,
    aws_quicksight_data_set.eks_dashboard_qs_dataset
  ]
}