terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.67.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }

  # ##  Used for end-to-end testing on project; update to suit your needs
  # backend "s3" {
  #   bucket = "terraform-state-duektsah"
  #   region = "eu-west-1"
  #   key    = "argocd-on-amazon-eks-workshop/codecommit"
  # }
}
