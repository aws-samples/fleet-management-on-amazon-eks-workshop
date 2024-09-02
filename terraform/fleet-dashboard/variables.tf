variable "aws_default_region" {
  type        = string
  description = "The region where the components are to be deployed"
}

variable "argocd_namespace" {
  type        = string
  description = "Namespace where Argo CD components will be deployed"
}

variable "eks_dashboard_qs_region" {
  type        = string
  description = "Region where the EKS Organization dashboard should be deployed"
}

variable "eks_dashboard_name" {
  type        = string
  description = "Name for the EKS Organization dashboard"
}

variable "eks_org_data_glue_job_name" {
  type        = string
  description = "Name for the Glue job that generates datasets for EKS Organization dashboard"
}

variable "eks_org_data_glue_version" {
  type        = string
  description = "Glue version to use for the EKS Organization data jobs"
}

variable "eks_org_data_glue_python_version" {
  type        = string
  description = "Glue Python version to use for the EKS Organization data jobs"
}

variable "workshop_name" {
  type        = string
  description = "The name of workshop"
}

variable "quicksight_access_group_name" {
  type        = string
  description = "Access group name for QuickSight dashboard"
}
variable "quicksight_access_group_membership" {
  type        = list(any)
  description = "Membership access level for the QuickSight access group"
}

variable "quicksight_dashboard_access_actions" {
  type        = string
  description = "Dashboard access actions for the QuickSight group"
}

variable "quicksight_datasets" {
  description = "Datasets definition for EKS Organization QuickSight dashboard"
  type = map(object({
    import_mode = string
    input_columns = list(object({
      name = string
      type = string
    }))
    upload_settings_format = string
    logical_table_map = object({
      cast_columns = list(object({
        column_name     = string
        new_column_type = string
      }))
      rename_columns = list(object({
        column_name     = string
        new_column_name = string
      }))
      geo_columns = list(object({
        column_name     = string
        geographic_role = string
      }))
    })
  }))
}