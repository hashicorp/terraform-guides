output "vpc" {
  value = aws_vpc.my_vpc
}

output "subnet" {
  value = aws_subnet.my_subnet
}

output "subnet_id" {
  value = aws_subnet.my_subnet.id
}
