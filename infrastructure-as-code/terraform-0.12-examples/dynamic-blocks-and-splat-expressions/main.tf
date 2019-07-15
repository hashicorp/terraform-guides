terraform {
  required_version = ">= 0.12.0"
}

variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "ingress_ports" {
  type        = list(number)
  description = "list of ingress ports"
  default     = [8200, 8201]
}

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "172.16.0.0/16"
  tags = {
    Name = "tf-0.12-dynamic-block-example"
  }
}

resource "aws_security_group" "vault" {
  name        = "vault"
  description = "Ingress for Vault"
  vpc_id      = aws_vpc.my_vpc.id

  dynamic "ingress" {
    iterator = port
    for_each = var.ingress_ports
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

output "from_ports" {
  value = aws_security_group.vault.ingress[*].from_port
  #value = aws_security_group.vault.ingress.*.from_port
}
