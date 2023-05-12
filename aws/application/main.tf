terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  cloud {
    organization = "kusama"

    workspaces {
      name = "aws-application"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

data "terraform_remote_state" "vpc" {
  backend = "remote"

  config = {
    organization = "kusama"

    workspaces = {
      name = "aws-vpc"
    }
  }
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

//// Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_network_interface" "web" {
  subnet_id = data.aws_subnet.public_0.id

  tags = {
    Name = "primary_network_interface"
    Division = var.division_name
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.medium"

  network_interface {
    network_interface_id = aws_network_interface.web.id
    device_index         = 0
  }

  tags = {
    Name = "WebServer-${var.division_name}"
    Division = var.division_name
  }
}

resource "aws_network_interface" "test" {
  subnet_id   = data.aws_subnet.public_0.id

  tags = {
    Name = "TestLinuxNIC"
    Division = var.division_name
  }
}

resource "aws_instance" "test" {
  ami           = "ami-0de5311b2a443fb89"
  instance_type = "t3.micro"

  network_interface {
    network_interface_id = aws_network_interface.test.id
    device_index         = 0
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

  tags = {
    Name = "Test-${var.division_name}"
    Division = var.division_name
  }
}


resource "aws_network_interface" "web2" {
  subnet_id = data.aws_subnet.public_0.id

  tags = {
    Name = "primary_network_interface"
    Division = var.division_name
  }
}

resource "aws_instance" "web2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.medium"

  network_interface {
    network_interface_id = aws_network_interface.web2.id
    device_index         = 0
  }

  tags = {
    Name = "WebServer-${var.division_name}"
    Division = var.division_name
  }
}

