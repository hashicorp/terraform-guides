provider "google" {
  # Google provider credentials via environment variable: GOOGLE_CLOUD_KEYFILE_JSON
  # Google project name configured via environment variable: GOOGLE_PROJECT
  region  = "${var.region}"
}

resource "google_sql_database_instance" "cloudsql-postgres-master" {
  name = "${var.database_name}"
  database_version = "${var.database_version}"
  region = "${var.region}"

  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier = "db-f1-micro"
    ip_configuration {
            ipv4_enabled = true
            require_ssl = false
            authorized_networks = {
                name = "terraform-server-IP-whitelist"
                value = "${var.authorized_network}"
            }
        }
  }
}

resource "google_sql_user" "users" {
  name     = "${var.gcp_sql_root_user_name}"
  instance = "${google_sql_database_instance.cloudsql-postgres-master.name}"
  password = "${var.gcp_sql_root_user_pw}"
}
