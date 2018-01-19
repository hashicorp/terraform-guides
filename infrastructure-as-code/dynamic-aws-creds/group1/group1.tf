data "terraform_remote_state" "vault" {
  backend = "atlas"
  config {
    name = "trp/group"
  }
}

data "vault_aws_access_credentials" "creds" {
  backend = "${data.terraform_remote_state.vault.backend}"
  role    = "${data.terraform_remote_state.vault.role}"
}

provider "aws" {
  access_key = "${data.vault_aws_access_credentials.creds.access_key}"
  secret_key = "${data.vault_aws_access_credentials.creds.secret_key}"
}

# Create AWS IAM Group
resource "aws_iam_group" "group1" {
  name = "group1"
  path = "/users/"
}
