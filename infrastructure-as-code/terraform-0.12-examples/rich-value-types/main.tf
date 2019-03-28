terraform {
  required_version = ">= 0.12.0"
}

provider "aws" {
  region = "us-west-2"
}

variable "vpc_name" {
  description = "name of the VPC"
  default = "tf-0.12-rvt-example-vpc"
}

variable "vpc_cidr" {
  description = "CIDR for VPC"
  default = "172.16.0.0/16"
}

variable "subnet_name" {
  description = "name for subnet"
  default = "tf-0.12-rvt-example-subnet"
}

variable "subnet_cidr" {
  description = "CIDR for subnet"
  default = "172.16.10.0/24"
}

variable "interface_ips" {
  type = list
  description = "IP for network interface"
  default = ["172.16.10.100"]
}

locals {
  network_config = {
    vpc_name = var.vpc_name
    vpc_cidr = var.vpc_cidr
    subnet_name = var.subnet_name
    subnet_cidr = var.subnet_cidr
  }
}

module "network" {
  source = "./network"
  network_config = local.network_config
}

resource "aws_network_interface" "rvt" {
  subnet_id = module.network.subnet_id
  private_ips = var.interface_ips
  
  tags = {
    Name = "tf-0.12-rvt-example-interface"
  }
}

data "aws_ami" "ubuntu_14_04" {
  most_recent      = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm/ubuntu-trusty-14.04-amd64-server-*"]
  }

  owners     = ["099720109477"]
}

resource "aws_instance" "rvt" {
  ami = data.aws_ami.ubuntu_14_04.image_id
  instance_type = "t2.micro"

  tags = {
    Name = "tf-0.12-rvt-example-instance"
  }

  network_interface {
    network_interface_id = aws_network_interface.rvt.id
    device_index = 0
  }
}

output "instance_private_dns" {
  value = aws_instance.rvt.private_dns
}

output "vpc" {
  value = module.network.vpc
}

output "subnet" {
  value = module.network.subnet
}

output "interface_sec_groups" {
  value = aws_network_interface.rvt.security_groups
}

/*output "network_module" {
  value = module.network
}*/
