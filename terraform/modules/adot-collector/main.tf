
locals{
  adot_collector_namespace = "adot-collector-kubeprometheus"
  adot_collector_serviceaccount = "adot-collector-kubeprometheus"    
}

resource "kubernetes_namespace" "adot_collector_namespace" {
   metadata {
    name = local.adot_collector_namespace
  }
}

resource "kubernetes_service_account" "adot_collector_serviceaccount" {
  metadata {
    name = local.adot_collector_serviceaccount
    namespace = local.adot_collector_namespace
  }
}


module "adot_collector_pod_identity" {
  source = "terraform-aws-modules/eks-pod-identity/aws"
  version = "~> 1.4.0"

  name = "adot-collector"

  additional_policy_arns = {
      "PrometheusReadWrite": "arn:aws:iam::aws:policy/AmazonPrometheusRemoteWriteAccess",
      "XrayAccess": "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
  }

  # Pod Identity Associations
  associations = {
    addon = {
      cluster_name = var.cluster_name
      namespace       = local.adot_collector_namespace
      service_account = local.adot_collector_serviceaccount
    }
  }
  tags = var.tags
}
