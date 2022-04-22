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
resource "aws_network_interface" "web2" {
  subnet_id   = data.aws_subnet.public_0.id

  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_instance" "web2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  network_interface {
    network_interface_id = aws_network_interface.web2.id
    device_index         = 0
  }

  tags = {
    Name = "No2"
  }
}

resource "aws_network_interface" "instance" {
  for_each = toset(["Web1", "Web2", "Web3"])
  subnet_id   = data.aws_subnet.public_0.id

  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_instance" "instance" {
  for_each = toset(["Web1", "Web2", "Web3"])
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"

  network_interface {
    network_interface_id = aws_network_interface.instance[each.key].id
    device_index         = 0
  }

  tags = {
    Name = each.key
  }
}


resource "aws_instance" "test" {
  ami           = "ami-088da9557aae42f39"
  instance_type = "t3.micro"

  # network_interface {
  #   network_interface_id = aws_network_interface.web.id
  #   device_index         = 0
  # }

  tags = {
    Name = "test",
    Created = "terraform"
  }
}