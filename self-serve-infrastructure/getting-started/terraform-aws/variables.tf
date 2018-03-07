variable "name" {
  default     = "self-serve-getting-started"
  description = "Name to tag resources with."
}

variable "instance_type" {
  default     = "t2.micro"
  description = "EC2 instance type, defaults to \"t2.micro\"."
}

variable "tags" {
  type        = "map"
  description = "Tags to be passed to the provisioned resources, defaults to empty map."
  default     = { }
}
