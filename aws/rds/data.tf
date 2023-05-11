data "terraform_remote_state" "vpc" {
  backend = "remote"

  config = {
    organization = "kusama"

    workspaces = {
      name = "aws-vpc"
    }
  }
}
