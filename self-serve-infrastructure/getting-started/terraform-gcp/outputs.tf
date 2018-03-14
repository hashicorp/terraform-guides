output "compute_network_consumable" {
  value       = "${google_compute_network.demo_network.name}"
  description = "The Network Name"
}

output "subnetwork_consumable_name" {
  value       = "${google_compute_subnetwork.demo_subnetwork.name}"
  description = "The Subnet Name"
}

output "subnetwork_consumable_ip_cidr_range" {
  value       = "${google_compute_subnetwork.demo_subnetwork.ip_cidr_range}"
  description = "The default Cidr Range"
}
