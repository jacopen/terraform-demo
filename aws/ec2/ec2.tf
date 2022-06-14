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

//// Windows AMI
data "aws_ami" "latest_windows_2019" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["Windows_Server-2019-Japanese-Full-Base-*"]
  }
}


//// NIC
resource "aws_network_interface" "web" {
  subnet_id   = data.aws_subnet.public_0.id

  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  network_interface {
    network_interface_id = aws_network_interface.web.id
    device_index         = 0
  }

  tags = {
    Name = "HelloWorld"
  }
}


//// NIC
resource "aws_network_interface" "windows" {
  subnet_id   = data.aws_subnet.public_0.id

  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_instance" "windows" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.medium"

  network_interface {
    network_interface_id = aws_network_interface.windows.id
    device_index         = 0
  }

  tags = {
    Name = "windows"
  }
}

# resource "aws_network_interface" "instance" {
#   for_each = toset(["Web1", "Web2", "Web3"])
#   subnet_id   = data.aws_subnet.public_0.id

#   tags = {
#     Name = "primary_network_interface"
#   }
# }

# resource "aws_instance" "instance" {
#   for_each = toset(["Web1", "Web2", "Web3"])
#   ami           = data.aws_ami.ubuntu.id
#   instance_type = "t3.small"

#   network_interface {
#     network_interface_id = aws_network_interface.instance[each.key].id
#     device_index         = 0
#   }

#   tags = {
#     Name = each.key
#   }
# }
# resource "aws_instance" "test" {
#   ami           = "ami-088da9557aae42f39"
#   instance_type = "t3.micro"

#   # network_interface {
#   #   network_interface_id = aws_network_interface.web.id
#   #   device_index         = 0
#   # }

#   user_data_replace_on_change = false

#   tags = {
#     Name = "test",
#     Created = "terraform"
#   }
# }