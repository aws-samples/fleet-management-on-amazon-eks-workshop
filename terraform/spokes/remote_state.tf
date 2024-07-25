data "terraform_remote_state" "cluster_hub" {
  backend = "local"

  config = {
    path = "${path.module}/../hub/terraform.tfstate"
  }
}

data "terraform_remote_state" "git" {
  backend = "local"

  config = {
    path = "${path.module}/../codecommit/terraform.tfstate"
  }
}
