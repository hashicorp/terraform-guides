data "terraform_remote_state" "vault" {
  backend = "atlas"
  config {
    name = "trp/user"
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

# Create AWS IAM User
resource "aws_iam_user" "user1" {
  name = "user1"
  path = "/users/"
}
