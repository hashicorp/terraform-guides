variable "aws_region" {
  description = "AWS region"
  default = "eu-west-2"
}

variable "ami_id" {
  description = "ID of the AMI to provision. Default is CentOS Hashistack Base Image"
  default = "ami-090b7b12bc73152c3"
}

variable "instance_type" {
  description = "type of EC2 instance to provision."
  default = "t2.micro"
}

variable "name" {
  description = "name to pass to Name tag"
  default = "demo-vm-jboero"
}
