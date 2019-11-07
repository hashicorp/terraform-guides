terraform {
  required_version = ">= 0.12.6"
}

provider "aws" {
  region = "us-east-1"
}

variable "zones" {
  description = "AWS availability zones"
  type = map
  default = {
    a = "us-east-1a"
    b = "us-east-1b"
    c = "us-east-1c"
    d = "us-east-1d"
    e = "us-east-1e"
    f = "us-east-1f"
  }
}

data "aws_ami" "ubuntu" {
  most_recent      = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "ubuntu" {
  for_each = var.zones
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  associate_public_ip_address = true
  availability_zone = each.value

  tags = {
    Name = format("for-each-demo-zone-%s", each.key)
  }

}

output "public_ips" {
  value = [for r in aws_instance.ubuntu: r.public_ip]
}
