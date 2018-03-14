variable "name" {
  default     = "self-serve-getting-started"
  description = "Name to tag resources with."
}

variable "region" {
  default     = "us-west1"
  description = "GCP region, defaults to \"us-west1\"."
}

variable "zone" {
  default     = "us-west1-a"
  description = "GCP zone, defaults to \"us-west1-a\"."
}

variable "service_port" {
  default     = "80"
  description = "Service port for instance group and LB, defaults to \"80\"."
}

variable "tags" {
  type        = "map"
  description = "Tags to be passed to the provisioned resources, defaults to empty map."
  default     = { }
}
