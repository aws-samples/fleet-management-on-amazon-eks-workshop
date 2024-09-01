resource "aws_cloudwatch_dashboard" "cni-helper-cw-dashboard" {
  dashboard_name = "VPC-CNI"
  dashboard_body = replace( file("vpc-cni-dw-dashboard.json"),"**aws_region**", local.region )

}