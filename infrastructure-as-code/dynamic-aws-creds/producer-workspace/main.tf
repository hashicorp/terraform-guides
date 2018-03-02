variable "aws_access_key" { }
variable "aws_secret_key" { }
variable "name"           { default = "dynamic-aws-creds-producer" }

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "vault" {}

resource "vault_aws_secret_backend" "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  path       = "${var.name}-path"

  default_lease_ttl_seconds = "120"
  max_lease_ttl_seconds     = "240"
}

resource "vault_aws_secret_backend_role" "producer" {
  backend = "${vault_aws_secret_backend.aws.path}"
  name    = "${var.name}-role"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:*", "ec2:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

output "backend" {
  value = "${vault_aws_secret_backend.aws.path}"
}

output "role" {
  value = "${vault_aws_secret_backend_role.producer.name}"
}
