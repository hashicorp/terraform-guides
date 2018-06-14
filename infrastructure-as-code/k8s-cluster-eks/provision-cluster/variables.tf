#
# Variables Configuration
#

variable "cluster-name" {
  default = "terraform-eks-demo"
  type    = "string"
}

variable "cluster" {
  default = "kubernetes"
  type    = "string"
}

variable "user" {
  default = "aws"
  type    = "string"
}
