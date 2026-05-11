# Copyright IBM Corp. 2017, 2026

variable "network_config" {
  type = object({
    vpc_name = string
    vpc_cidr = string
    subnet_name = string
    subnet_cidr = string
  })
}
