# Copyright IBM Corp. 2017, 2026

resource "aws_vpc" "main" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags {
    Name = "${var.environment_name}"
  }
}
