terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region = var.aws_region
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-disco-19.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "ubuntu" {
  ami               = "${data.aws_ami.ubuntu.id}"
  instance_type     = var.instance_type
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = var.name
  }
}
