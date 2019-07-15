output "private_key_pem" {
  value = "${chomp(tls_private_key.ssh_key.private_key_pem)}"
}

output "k8s_id" {
  value = "${azurerm_kubernetes_cluster.k8sexample.id}"
}

output "k8s_endpoint" {
  value = "${azurerm_kubernetes_cluster.k8sexample.fqdn}"
}

output "k8s_master_auth_client_certificate" {
  value = "${azurerm_kubernetes_cluster.k8sexample.kube_config.0.client_certificate}"
}

output "k8s_master_auth_client_key" {
  value = "${azurerm_kubernetes_cluster.k8sexample.kube_config.0.client_key}"
}

output "k8s_master_auth_cluster_ca_certificate" {
  value = "${azurerm_kubernetes_cluster.k8sexample.kube_config.0.cluster_ca_certificate}"
}

output "environment" {
  value = "${var.environment}"
}

output "vault_user" {
  value = "${var.vault_user}"
}

output "vault_addr" {
  value = "${var.vault_addr}"
}
