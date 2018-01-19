provider "vault" {}

resource "vault_aws_secret_backend" "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"

  default_lease_ttl_seconds = "60"
  max_lease_ttl_seconds     = "120"
}

resource "vault_aws_secret_backend_role" "role" {
  backend = "${vault_aws_secret_backend.aws.path}"
  name    = "jb-test"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:GetGroup",
        "iam:CreateGroup",
        "iam:DeleteGroup",
        "iam:GetUser",
        "iam:CreateUser",
        "iam:DeleteUser"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

data "vault_aws_access_credentials" "creds" {
  backend = "${vault_aws_secret_backend.aws.path}"
  role    = "${vault_aws_secret_backend_role.role.name}"
}

provider "aws" {
  access_key = "${data.vault_aws_access_credentials.creds.access_key}"
  secret_key = "${data.vault_aws_access_credentials.creds.secret_key}"
}

resource "random_id" "name" {
  byte_length = 4
  prefix      = "developers-"
}

# Create AWS IAM Group
resource "aws_iam_group" "developers" {
  name = "${random_id.name.hex}"
  path = "/users/"
}

# Create AWS IAM User
resource "aws_iam_user" "developers" {
  name = "${random_id.name.hex}"
  path = "/users/"
}
