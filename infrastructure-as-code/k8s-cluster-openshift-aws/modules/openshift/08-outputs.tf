//  Output some useful variables for quick SSH access etc.
output "master_public_dns" {
  value = "${aws_instance.master.public_dns}"
}
output "master_public_ip" {
  value = "${aws_instance.master.public_ip}"
}
output "master_private_dns" {
  value = "${aws_instance.master.private_dns}"
}
output "master_private_ip" {
  value = "${aws_instance.master.private_ip}"
}

output "node1_public_dns" {
  value = "${aws_instance.node1.public_dns}"
}
output "node1_public_ip" {
  value = "${aws_instance.node1.public_ip}"
}
output "node1_private_dns" {
  value = "${aws_instance.node1.private_dns}"
}
output "node1_private_ip" {
  value = "${aws_instance.node1.private_ip}"
}

output "bastion_public_dns" {
  value = "${aws_instance.bastion.public_dns}"
}
output "bastion_public_ip" {
  value = "${aws_instance.bastion.public_ip}"
}
output "bastion_private_dns" {
  value = "${aws_instance.bastion.private_dns}"
}
output "bastion_private_ip" {
  value = "${aws_instance.bastion.private_ip}"
}
