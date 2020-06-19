terraform {
  required_version = ">= 0.13.0"
}

variable "wait_for_write" {}

resource "null_resource" "dependency" {
  triggers = {
    dependency_id = var.wait_for_write
  }

}

data "local_file" "apple" {
    filename = "${path.root}/apple.txt"
    depends_on = [null_resource.dependency]
}

data "local_file" "banana" {
    filename = "${path.root}/banana.txt"
    depends_on = [null_resource.dependency]
}

data "local_file" "orange" {
    filename = "${path.root}/orange.txt"
    depends_on = [null_resource.dependency]
}

output "fruit" {
  value = [
    data.local_file.apple.content,
    data.local_file.banana.content,
    data.local_file.orange.content,
  ]
}
