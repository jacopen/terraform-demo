terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

data "aws_vpc" "main" {
  id = data.terraform_remote_state.vpc.outputs.vpc_id
}

data "aws_subnet" "public_0" {
  id = data.terraform_remote_state.vpc.outputs.public_0_subnet_id
}

data "aws_subnet" "public_1" {
  id = data.terraform_remote_state.vpc.outputs.public_1_subnet_id
}

data "aws_subnet" "private_0" {
  id = data.terraform_remote_state.vpc.outputs.private_0_subnet_id
}

data "aws_subnet" "private_1" {
  id = data.terraform_remote_state.vpc.outputs.private_1_subnet_id
}
