output "k8s_endpoint" {
  value = "${google_container_cluster.k8sexample.endpoint}"
}

output "k8s_master_version" {
  value = "${google_container_cluster.k8sexample.master_version}"
}

output "k8s_instance_group_urls" {
  value = "${google_container_cluster.k8sexample.instance_group_urls.0}"
}

output "k8s_master_auth_client_certificate" {
  value = "${google_container_cluster.k8sexample.master_auth.0.client_certificate}"
}

output "k8s_master_auth_client_key" {
  value = "${google_container_cluster.k8sexample.master_auth.0.client_key}"
}

output "k8s_master_auth_cluster_ca_certificate" {
  value = "${google_container_cluster.k8sexample.master_auth.0.cluster_ca_certificate}"
}

output "vault_k8s_auth_backend" {
  value = "${vault_auth_backend.k8s.path}"
}

output "vault_user" {
  value = "${var.vault_user}"
}

output "vault_addr" {
  value = "${var.vault_addr}"
}
