# For_each for Resources Example
This example illustrates how the [for_each meta-argument](https://www.terraform.io/docs/configuration/resources.html#for_each-multiple-resource-instances-defined-by-a-map-or-set-of-strings) can be used instead of the `count` meta-argument to create multiple instances of a resource with different properties based on the contents of a map or set of strings.

Note that the `for_each` meta-argument for resources was added in Terraform 0.12.6.

The example illustrates `for_each` by creating an EC2 instance in all six availability zones of the AWS region us-east-1.

We first define a variable of type map listing all six zones:
```
variable "zones" {
  description = "AWS availability zones"
  type = map
  default = {
    a = "us-east-1a"
    b = "us-east-1b"
    c = "us-east-1c"
    d = "us-east-1d"
    e = "us-east-1e"
    f = "us-east-1f"
  }
}
```

We then use an aws_ami data source to find the most recent Ubuntu 16.04 AMI issued by Canonical in the us-east-1 region.

The use of the `for_each` meta-argument actually occurs in the definition of the example's aws_instance resource:
```
resource "aws_instance" "ubuntu" {
  for_each = var.zones
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  associate_public_ip_address = true
  availability_zone = each.value

  tags = {
    Name = format("for-each-demo-zone-%s", each.key)
  }

}
```
Note that `for_each` in this case refers to the `zones` variable which defines the map of availability zones. We are then able to reference the keys and values of that map with `each.key` and `each.value` respectively. In particular, note the use of the values in `availability_zone = each.value` and the use of the keys in the `tags` map.

Finally, we also use the [for](https://www.terraform.io/docs/configuration/expressions.html#for-expressions) expression in the `public_ips` output that gives the public IPs of all six EC2 instances in a list:
```
output "public_ips" {
  value = [for r in aws_instance.ubuntu: r.public_ip]
}
```
