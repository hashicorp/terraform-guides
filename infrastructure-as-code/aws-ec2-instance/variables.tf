variable "aws_region" {
  description = "AWS region"
  default     = "us-west-1"
}

variable "instance_type" {
  description = "type of EC2 instance to provision."
  default     = "t2.micro"
}

variable "name" {
  description = "name to pass to Name tag"
  default     = "Provisioned by Terraform"
}

