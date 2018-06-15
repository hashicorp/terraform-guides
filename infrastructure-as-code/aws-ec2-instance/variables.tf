variable "aws_region" {
  description = "AWS region"
  default     = "us-west-1"
}

variable "aws_availability_zone" {
  description = "AWS Availability Zone"
  default     = "us-west-1b"
}

variable "ami_id" {
  description = "ID of the AMI to provision. Default is Ubuntu 14.04 Base Image"
  default     = "ami-2e1ef954"
}

variable "instance_type" {
  description = "type of EC2 instance to provision."
  default     = "t2.micro"
}

variable "name" {
  description = "name to pass to Name tag"
  default     = "Provisioned by Terraform"
}
