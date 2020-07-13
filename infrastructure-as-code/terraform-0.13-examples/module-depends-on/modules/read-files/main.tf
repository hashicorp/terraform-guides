terraform {
  required_version = ">= 0.13.0"
}

data "local_file" "apple" {
    count = 2
    filename = "${path.root}/apple.txt"
}

data "local_file" "banana" {
    filename = "${path.root}/banana.txt"
}

data "local_file" "orange" {
    filename = "${path.root}/orange.txt"
    depends_on = ["data.local_file.banana"]
}

output "fruit" {
  value = [
    data.local_file.apple.0.content,
    data.local_file.banana.content,
    data.local_file.orange.content,
  ]
}
