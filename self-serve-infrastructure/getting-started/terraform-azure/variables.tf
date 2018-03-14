variable "name" {
  default     = "self-serve-getting-started"
  description = "Name to tag resources with."
}

variable "network_location" {
  default     = "westus"
  description = "Network location, defaults to \"westus\"."
}

variable "compute_location" {
  default     = "West US 2"
  description = "Compute location, defaults to \"westus\"."
}

variable "tags" {
  type        = "map"
  description = "Tags to be passed to the provisioned resources, defaults to empty map."
  default     = { }
}
