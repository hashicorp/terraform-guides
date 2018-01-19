provider "vault" {}

resource "vault_aws_secret_backend" "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"

  default_lease_ttl_seconds = "60"
  max_lease_ttl_seconds     = "120"
}

resource "vault_aws_secret_backend_role" "group" {
  backend = "${vault_aws_secret_backend.aws.path}"
  name    = "group"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:GetGroup",
        "iam:CreateGroup",
        "iam:DeleteGroup"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

output "backend" {
  value = "${vault_aws_secret_backend.group.path}"
}

output "role" {
  value = "${vault_aws_secret_backend_role.group.name}"
}
