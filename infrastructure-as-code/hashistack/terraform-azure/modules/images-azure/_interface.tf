//
// Variables
//
variable "os" {
  type = "string"
}

//
// Variables w/ Defaults
//
variable "user" {
  default = "azure-user"
}

################################################################
# NOTE!!
#
# As of 2017/03/17, the RHEL images on Azure do not support cloud-init, so
# we specifically disabled support for RHEL on Azure until cloud-init is
# available.
################################################################
variable "publisher_map" {
  default = {
    #rhel   = "RedHat"
    ubuntu = "Canonical"
  }
}

variable "offer_map" {
  default = {
    #rhel   = "RHEL"
    ubuntu = "UbuntuServer"
  }
}

variable "sku_map" {
  default = {
    #rhel   = "7.3"
    ubuntu = "16.04-LTS"
  }
}

variable "version_map" {
  default = {
    #rhel   = "latest"
    ubuntu = "latest"
  }
}

//
// Outputs
//
output "os_user" {
  value = "${var.user}"
}

output "base_publisher" {
  value = "${lookup(var.publisher_map,var.os)}"
}

output "base_offer" {
  value = "${lookup(var.offer_map,var.os)}"
}

output "base_sku" {
  value = "${lookup(var.sku_map,var.os)}"
}

output "base_version" {
  value = "${lookup(var.version_map,var.os)}"
}
