terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "kusama"

    workspaces {
      name = "aws-rds"
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

variable "name" {
  default = "jacopen-rds"
}

variable "deletion_protection" {
  default = true
}

variable "minimum_capacity" {
  default = 0.5
}

variable "maximum_capacity" {
  default = 1
}

variable "replica_number" {
  default = 1
}

variable "availability_zones" {
  default = ["ap-northeast-1a", "ap-northeast-1c"]
}

variable "publicly_accessible" {
  default = false
}

variable "apply_immediately" {
  default = true
}

variable "preferred_backup_window_in_utc" {
  default = "00:00-01:00"
}

variable "preffered_maintenance_window_in_utc" {
  default = "sun:00:00-sun:01:00"
}

variable "backup_retention_period_in_days" {
  default = 7
}

variable "allow_db_access_cidr_blocks" {
  default = ["0.0.0.0/0"]
}