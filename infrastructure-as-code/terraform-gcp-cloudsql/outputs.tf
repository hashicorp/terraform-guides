output "connection_name" {
  value = "${google_sql_database_instance.cloudsql-postgres-master.connection_name}"
}

output "ip" {
  value = "${google_sql_database_instance.cloudsql-postgres-master.ip_address.0.ip_address}"
}

