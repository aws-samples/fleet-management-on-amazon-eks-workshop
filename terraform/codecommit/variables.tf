variable "ssh_key_basepath" {
  description = "path to .ssh directory"
  type        = string
  # For AWS EC2 override with
  # export TF_VAR_ssh_key_basepath="/home/ec2-user/.ssh"
  default = "~/.ssh"
}

variable "secret_name_ssh_secrets" {
  description = "Secret name for SSH secrets"
  type        = string
  default     = "git-ssh-secrets-fleet-workshop"
}

variable "secret_name_git_data_fleet" {
  description = "Secret name for Git data fleet"
  type        = string
  default     = "eks-fleet-workshop/git-data-fleet"
}

variable "secret_name_git_data_addons" {
  description = "Secret name for Git data addons"
  type        = string
  default     = "eks-fleet-workshop/git-data-addons"
}

variable "secret_name_git_data_platform" {
  description = "Secret name for Git data platform"
  type        = string
  default     = "eks-fleet-workshop/git-data-platform"
}

variable "secret_name_git_data_workload" {
  description = "Secret name for Git data workload"
  type        = string
  default     = "eks-fleet-workshop/git-data-workload"
}


variable "gitops_fleet_basepath" {
  description = "Git repository base path for addons"
  default     = ""
}
variable "gitops_fleet_path" {
  description = "Git repository path for addons"
  default     = "bootstrap"
}
variable "gitops_fleet_revision" {
  description = "Git repository revision/branch/ref for addons"
  default     = "HEAD"
}
variable "gitops_fleet_repo_name" {
  description = "Git repository name for addons"
  default     = "gitops-fleet"
}

variable "gitops_addons_basepath" {
  description = "Git repository base path for addons"
  default     = ""
}
variable "gitops_addons_path" {
  description = "Git repository path for addons"
  default     = "bootstrap"
}
variable "gitops_addons_revision" {
  description = "Git repository revision/branch/ref for addons"
  default     = "HEAD"
}
variable "gitops_addons_repo_name" {
  description = "Git repository name for addons"
  default     = "fleet-gitops-addons"
}

variable "gitops_platform_basepath" {
  description = "Git repository base path for platform"
  default     = ""
}
variable "gitops_platform_path" {
  description = "Git repository path for workload"
  default     = "bootstrap"
}
variable "gitops_platform_revision" {
  description = "Git repository revision/branch/ref for workload"
  default     = "HEAD"
}
variable "gitops_platform_repo_name" {
  description = "Git repository name for platform"
  default     = "fleet-gitops-platform"
}

variable "gitops_workload_basepath" {
  description = "Git repository base path for workload"
  default     = ""
}
variable "gitops_workload_path" {
  description = "Git repository path for workload"
  default     = ""
}
variable "gitops_workload_revision" {
  description = "Git repository revision/branch/ref for workload"
  default     = "HEAD"
}
variable "gitops_workload_repo_name" {
  description = "Git repository name for workload"
  default     = "fleet-gitops-apps"
}
