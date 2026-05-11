# Copyright IBM Corp. 2017, 2026

output "public_dns" {
  value = "${aws_instance.ubuntu.public_dns}"
}
