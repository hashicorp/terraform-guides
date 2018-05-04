output "cats_and_dogs_dns" {
  value = "http://cats-and-dogs-frontend.${data.terraform_remote_state.k8s_cluster.master_public_ip}.xip.io"
}
