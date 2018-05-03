variable "region" {
  description = "The region to deploy the cluster in, e.g: us-east-1."
}

variable "amisize" {
  description = "The size of the cluster nodes, e.g: t2.large. Note that OpenShift will not run on anything smaller than t2.large"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC, e.g: 10.0.0.0/16"
}

variable "subnetaz" {
  description = "The AZ for the public subnet, e.g: us-east-1a"
  type = "map"
}

variable "subnet_cidr" {
  description = "The CIDR block for the public subnet, e.g: 10.0.1.0/24"
}

variable "key_name" {
  description = "The name of the key to user for ssh access"
}

variable "private_key_data" {
  description = "contents of the private key"
}

variable "name_tag_prefix" {
  description = "prefixed to Name tag added to EC2 instances and other AWS resources"
}

variable "owner" {
  description = "value set on EC2 owner tag"
}

variable "ttl" {
  description = "value set on EC2 TTL tag. -1 means forever. Measured in hours."
}
