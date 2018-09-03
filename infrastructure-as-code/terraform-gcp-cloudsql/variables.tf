variable "gcp_credentials" {
  description = "GCP credentials needed by Google Terraform provider"
}

variable "gcp_project" {
  description = "GCP project name needed by Google Terraform provider"
}

variable "region" {
  default = "us-central1"
}

variable "gcp_sql_root_user_name" {
  default = "root"
}

variable "gcp_sql_root_user_pw" {}

variable "authorized_network" {}

variable "database_name_prefix" {
  default = "cloudsql-master"
}

variable "database_version" {
  default = "POSTGRES_9_6"
}

