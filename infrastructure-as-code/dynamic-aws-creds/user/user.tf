provider "vault" {}

resource "vault_aws_secret_backend_role" "user" {
  backend = "${var.backend}"
  name    = "user"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
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

output "backend" {
  value = "${var.backend}"
}

output "role" {
  value = "${vault_aws_secret_backend_role.user.name}"
}
