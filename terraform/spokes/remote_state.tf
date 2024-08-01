data "terraform_remote_state" "git" {
  backend = "local"

  config = {
    path = "${path.module}/../codecommit/terraform.tfstate"
  }
}
