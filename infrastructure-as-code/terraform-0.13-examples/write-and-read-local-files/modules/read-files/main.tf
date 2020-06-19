terraform {
  required_version = ">= 0.13.0"
}

data "local_file" "apple" {
    filename = "${path.root}/apple.txt"
}

data "local_file" "banana" {
    filename = "${path.root}/banana.txt"
}

data "local_file" "orange" {
    filename = "${path.root}/orange.txt"
}

output "fruit" {
  value = [
    data.local_file.apple.content,
    data.local_file.banana.content,
    data.local_file.orange.content,
  ]
}
