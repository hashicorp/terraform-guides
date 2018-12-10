terraform {
  required_version = ">= 0.12.0"
}

variable "aws_region" {
  description = "AWS region"
  default = "us-east-1"
}

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "172.16.0.0/16"
  
  tags = {
    Name = "tf-0.12-gso-example"
  }
}

resource "aws_security_group" "allow_some_ingress" {
  name        = "allow_some_ingress"
  description = "Allow some inbound traffic"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "ports" {
  value = aws_security_group.allow_some_ingress.ingress.*.from_port
}
