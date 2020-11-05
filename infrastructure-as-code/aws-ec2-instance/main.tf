terraform {
  required_version = ">= 0.11.0"
}

module "module2" {
  source  = "app.terraform.io/TFE_PoV/module2/demo"
  version = "1.0.3"
  # insert required variables here
}

provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_instance" "ubuntu" {
  ami           = "${var.ami_id}"
  instance_type = "${var.instance_type}"
  availability_zone = "${var.aws_region}a"

  tags {
    Name = "pre-${var.name}"
  }
}
