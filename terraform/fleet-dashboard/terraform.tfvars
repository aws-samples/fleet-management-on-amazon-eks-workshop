workshop_name                       = "eks-fleet-management"
#aws_default_region                  = "us-west-2"
argocd_namespace                    = "argocd"
#eks_dashboard_qs_region             = "us-west-2"
eks_org_data_glue_python_version    = "3.9"
eks_org_data_glue_version           = "3.0"
eks_org_data_glue_job_name          = "eks-fleet-management-dashboard"
eks_dashboard_name                  = "eks-fleet-management-dashboard"
quicksight_access_group_name        = "eks_fleet_dashboard_admins"
quicksight_access_group_membership  = ["WSParticipantRole/Participant"]
quicksight_dashboard_access_actions = "quicksight:DescribeDashboard,quicksight:ListDashboardVersions,quicksight:UpdateDashboardPermissions,quicksight:QueryDashboard,quicksight:UpdateDashboard,quicksight:DeleteDashboard,quicksight:UpdateDashboardPublishedVersion,quicksight:DescribeDashboardPermissions"

quicksight_datasets = {
  eks-fleet-clusters-data = {
    import_mode = "SPICE"
    input_columns = [
      {
        name = "Account Id"
        type = "STRING"
      },
      {
        name = "Region"
        type = "STRING"
      },
      {
        name = "Cluster Name"
        type = "STRING"
      },
      {
        name = "Cluster Version"
        type = "STRING"
      },
      {
        name = "Latest Version"
        type = "STRING"
      },
      {
        name = "Versions Back"
        type = "STRING"
      }
    ]
    upload_settings_format = "JSON"
    logical_table_map = {
      cast_columns = [
        {
          column_name     = "Cluster Version"
          new_column_type = "DECIMAL"
        },
        {
          column_name     = "Latest Version"
          new_column_type = "DECIMAL"
        },
        {
          column_name     = "Versions Back"
          new_column_type = "INTEGER"
        }
      ]
      geo_columns = [{
        geographic_role = "STATE"
        column_name     = "Region"
      }]
      rename_columns = []
    }
  },
  eks-fleet-clusters-details = {
    import_mode = "SPICE"
    input_columns = [
      {
        name = "Account Id"
        type = "STRING"
      },
      { name = "Region"
        type = "STRING"
      },
      {
        name = "Cluster Name"
        type = "STRING"
      },
      {
        name = "Cluster Version"
        type = "STRING"
      },
      {
        name = "aws-ebs-csi-driver"
        type = "STRING"
      },
      {
        name = "aws-efs-csi-driver"
        type = "STRING"
      },
      {
        name = "coredns"
        type = "STRING"
      },
      {
        name = "kube-proxy"
        type = "STRING"
      },
      {
        name = "vpc-cni"
        type = "STRING"
      }
    ]
    upload_settings_format = "JSON"
    logical_table_map = {
      cast_columns = [
        {
          column_name     = "Cluster Version"
          new_column_type = "DECIMAL"
        }
      ]
      geo_columns = [
        {
          geographic_role = "STATE"
          column_name     = "Region"
        }
      ]
      rename_columns = [
        {
          column_name     = "aws-ebs-csi-driver"
          new_column_name = "EBS CSI Driver"
        },
        {
          column_name     = "aws-efs-csi-driver"
          new_column_name = "EFS CSI Driver"
        },
        {
          column_name     = "coredns"
          new_column_name = "Core DNS"
        },
        {
          column_name     = "kube-proxy"
          new_column_name = "Kube Proxy"
        },
        {
          column_name     = "vpc-cni"
          new_column_name = "VPC CNI"
        }
      ]
    }
  },
  eks-fleet-clusters-summary-data = {
    import_mode = "SPICE"
    input_columns = [
      {
        name = "Account Id"
        type = "STRING"
      },
      {
        name = "Region"
        type = "STRING"
      },
      {
        name = "Number of Clusters"
        type = "STRING"
      }
    ]
    upload_settings_format = "JSON"
    logical_table_map = {
      cast_columns = [
        {
          column_name     = "Number of Clusters"
          new_column_type = "INTEGER"
        }
      ]
      geo_columns = [{
        geographic_role = "STATE"
        column_name     = "Region"
      }]
      rename_columns = []
    }
  },
  eks-fleet-support-data = {
    import_mode = "SPICE"
    input_columns = [
      {
        name = "Account Id"
        type = "STRING"
      },
      {
        name = "Region"
        type = "STRING"
      },
      {
        name = "Cluster Name"
        type = "STRING"
      },
      {
        name = "Cluster Version"
        type = "STRING"
      },
      {
        name = "EndOfSupportDate"
        type = "STRING"
      },
      {
        name = "EndOfExtendedSupportDate"
        type = "STRING"
      },
      {
        name = "Status"
        type = "STRING"
      },
      {
        name = "UpgradesReport"
        type = "STRING"
      }
    ]
    upload_settings_format = "JSON"
    logical_table_map = {
      cast_columns = [
        {
          column_name     = "Cluster Version"
          new_column_type = "DECIMAL"
        }
      ]
      geo_columns = [{
        geographic_role = "STATE"
        column_name     = "Region"
      }]
      rename_columns = [
        {
          column_name     = "EndOfSupportDate"
          new_column_name = "End Of Standard Support Date"
        },
        {
          column_name     = "EndOfExtendedSupportDate"
          new_column_name = "End Of Extended Support Date"
        },
        {
          column_name     = "Status"
          new_column_name = "Support Status"
        },
        {
          column_name     = "UpgradesReport"
          new_column_name = "Upgrades S3 Report"
        }
      ]
    }
  },
  eks-fleet-kubernetes-release-calendar = {
    import_mode = "SPICE"
    input_columns = [
      {
        name = "Kubernetes version"
        type = "STRING"
      },
      {
        name = "Upstream release"
        type = "STRING"
      },
      {
        name = "Amazon EKS release"
        type = "STRING"
      },
      {
        name = "End of standard support"
        type = "STRING"
      },
      {
        name = "End of extended support"
        type = "STRING"
      },
      {
        name = "EndOfExtendedSupportDate"
        type = "STRING"
      }
    ]
    upload_settings_format = "JSON"
    logical_table_map = {
      cast_columns = [
        {
          column_name     = "Kubernetes version"
          new_column_type = "STRING"
        }
      ]
      geo_columns = []
      rename_columns = [{
        column_name     = "Kubernetes version"
        new_column_name = "Kubernetes Version"
      }]
    }
  },
  eks-fleet-clusters-upgrade-insights = {
    import_mode = "SPICE"
    input_columns = [
      {
        name = "Account Id"
        type = "STRING"
      },
      {
        name = "Region"
        type = "STRING"
      },
      {
        name = "Cluster Name"
        type = "STRING"
      },
      {
        name = "Cluster Version"
        type = "STRING"
      },
      {
        name = "InsightId"
        type = "STRING"
      },
      {
        name = "Current API Usage"
        type = "STRING"
      },
      {
        name = "API Deprecated Version"
        type = "STRING"
      },
      {
        name = "API Replacement"
        type = "STRING"
      },
      {
        name = "User Agent"
        type = "STRING"
      },
      {
        name = "Number of Requests In Last 30Days"
        type = "STRING"
      },
      {
        name = "Last Request Time"
        type = "STRING"
      }
    ]
    upload_settings_format = "JSON"
    logical_table_map = {
      cast_columns = [
        {
          column_name     = "Cluster Version"
          new_column_type = "DECIMAL"
        },
        {
          column_name     = "API Deprecated Version"
          new_column_type = "DECIMAL"
        },
        {
          column_name     = "Number of Requests In Last 30Days"
          new_column_type = "INTEGER"
        }
      ]
      geo_columns = [{
        geographic_role = "STATE"
        column_name     = "Region"
      }]
      rename_columns = []
    }
  },
  eks-fleet-argo-projects-data = {
    import_mode = "SPICE"
    input_columns = [
      {
        name = "Account Id"
        type = "STRING"
      },
      {
        name = "Region"
        type = "STRING"
      },
      {
        name = "Cluster Name"
        type = "STRING"
      },
      {
        name = "Argo Application Name"
        type = "STRING"
      },
      {
        name = "Application Repo"
        type = "STRING"
      },
      {
        name = "Application Health"
        type = "STRING"
      },

      {
        name = "Application Sync Status"
        type = "STRING"
      },
      {
        name = "Operation State"
        type = "STRING"
      },
      {
        name = "Source Type"
        type = "STRING"
      },
      {
        name = "Last Sync"
        type = "STRING"
      },
      {
        name = "Resource Kind"
        type = "STRING"
      },
      {
        name = "Resource Name"
        type = "STRING"
      },
      {
        name = "Resource Namespace"
        type = "STRING"
      },
      {
        name = "Resource Health"
        type = "STRING"
      },
      {
        name = "Resource Status"
        type = "STRING"
      },
      {
        name = "Resource Version"
        type = "STRING"
      }
    ]
    upload_settings_format = "JSON"
    logical_table_map = {
      cast_columns = [
        {
          column_name     = "Account Id"
          new_column_type = "STRING"
        },
        {
          column_name     = "Last Sync"
          new_column_type = "STRING"
        }
      ]
      geo_columns = [{
        geographic_role = "STATE"
        column_name     = "Region"
      }]
      rename_columns = []
    }
  }
}