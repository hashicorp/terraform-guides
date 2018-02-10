variable "name" { default = "dynamic-aws-creds-consumer" }
variable "path" { default = "../producer-workspace/terraform.tfstate" }

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

data "terraform_remote_state" "producer" {
  backend = "local"

  config {
    path = "${var.path}"
  }
}

data "vault_aws_access_credentials" "creds" {
  backend = "${data.terraform_remote_state.producer.backend}"
  role    = "${data.terraform_remote_state.producer.role}"
}

provider "aws" {
  access_key = "${data.vault_aws_access_credentials.creds.access_key}"
  secret_key = "${data.vault_aws_access_credentials.creds.secret_key}"
}
resource "random_id" "name" {
  byte_length = 4
  prefix      = "${var.name}-"
}

# Create AWS IAM Group
resource "aws_iam_group" "consumer-group" {
  name = "group-${random_id.name.hex}"
  path = "/groups/"
}

# Create AWS IAM User
resource "aws_iam_user" "consumer-user" {
  name = "user-${random_id.name.hex}"
  path = "/users/"
}
