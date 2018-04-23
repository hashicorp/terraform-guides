output "cats_and_dogs_dns" {
  value = "http://cats-and-dogs-frontend.${data.terraform_remote_state.k8s_cluster.master_public_ip}.xip.io"
}

output "cats_and_dogs_token" {
  value = "${data.null_data_source.retrieve_token_from_file.outputs["cats_and_dogs_token"]}"
}
