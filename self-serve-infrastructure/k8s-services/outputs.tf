# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "cats_and_dogs_ip" {
  value = "${kubernetes_service.cats-and-dogs-frontend.load_balancer_ingress.0.ip}"
}
