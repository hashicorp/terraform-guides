variable "region" {
  default = "us-central1"
}

variable "gcp_sql_root_user_name" {
	 default = "root"
}

variable "gcp_sql_root_user_pw" {}

variable "authorized_network" {}

variable "database_name" {
  default = "master-instance"
}

variable "database_version" {
  default = "POSTGRES_9_6"
}

