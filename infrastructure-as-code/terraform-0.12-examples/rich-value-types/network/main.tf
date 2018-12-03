resource "aws_vpc" "my_vpc" {
  cidr_block = var.network_config.vpc_cidr
  tags = {
    Name = var.network_config.vpc_name
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = var.network_config.subnet_cidr
  availability_zone = "us-west-2a"
  tags = {
    Name = var.network_config.subnet_name
  }
}
