
# TODO: Remove all this output this information will only be accesible thru aws secrets manager
output "gitops_fleet_url" {
  value = "${local.gitops_fleet_org}/${local.gitops_fleet_repo}"
}
output "gitops_addons_url" {
  value = "${local.gitops_addons_org}/${local.gitops_addons_repo}"
}
output "gitops_platform_url" {
  value = "${local.gitops_platform_org}/${local.gitops_platform_repo}"
}
output "gitops_workload_url" {
  value = "${local.gitops_workload_org}/${local.gitops_workload_repo}"
}

