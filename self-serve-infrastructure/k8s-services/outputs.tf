# Copyright IBM Corp. 2017, 2026

output "cats_and_dogs_ip" {
  value = "${kubernetes_service.cats-and-dogs-frontend.load_balancer_ingress.0.ip}"
}
