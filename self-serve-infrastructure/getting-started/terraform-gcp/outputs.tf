output "instance_template" {
  value = "${module.mig1.google_compute_instance_template.default}"
}

output "instance_group_manager" {
  value = "${module.mig1.google_compute_instance_group_manager.default}"
}

output "firewall" {
  value = "${module.mig1.google_compute_firewall.default-ssh}"
}
