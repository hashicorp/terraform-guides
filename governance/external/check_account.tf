terraform {
  required_version = ">= 0.11.7"
}

variable "account_code" {
   description = "code of cloud account: can be 1 or 2"
}


# Add fake resource to make sure that TFE runs this each time
resource "null_resource" "fake" {
   triggers {
      uuid = "${uuid()}"
   }
}

data "external" "check_balance" {
  program = ["./check_account.sh", "${var.account_code}"]
}

output "balance" {
  value = "${data.external.check_balance.result["balance"]}"
}


