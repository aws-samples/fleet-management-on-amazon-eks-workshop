variable "ssh_key_basepath" {
  description = "path to .ssh directory"
  type        = string
  # For AWS EC2 override with
  # export TF_VAR_ssh_key_basepath="/home/ec2-user/.ssh"
  default = "~/.ssh"
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
  default     = "gitops-addons"
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
  default     = "gitops-platform"
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
  default     = "gitops-apps"
}
