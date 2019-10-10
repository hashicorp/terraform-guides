# For Expressions Example
This example illustrates how the new [For Expression](https://www.terraform.io/docs/configuration/expressions.html#for-expressions) can be used to iterate across multiple items in lists. It does this for several outputs, illustrating the usefulness and power of the **for** expression in several ways.  We use two tf files in this example:
1. main.tf creates a VPC, subnet, and 3 EC2 instances and then generates outputs related to the DNS and IP addresses of the EC2 instances.
1. lists-and-maps-with-for.tf shows how the **for** expression can be used inside lists and maps.

We first generate outputs that give the list of private DNS addresses for the 3 EC2 instances in several ways, first using the **old splat syntax**:
```
output "private_addresses_old" {
  value = aws_instance.ubuntu.*.private_dns
}
```

We also use the new [Splat Expression](https://www.hashicorp.com/blog/terraform-0-12-generalized-splat-operator) (`[*]`):
```
output "private_addresses_full_splat" {
  value = [ aws_instance.ubuntu[*].private_dns ]
}
```

For more on splat expressions, see [Splat Expressions](https://www.terraform.io/docs/configuration/expressions.html#splat-expressions).

We next use the new **for** expression:
```
output "private_addresses_new" {
  value = [
    for instance in aws_instance.ubuntu:
    instance.private_dns
  ]
}
```
All three of these give an output like this (with different output names):
```
private_addresses_new = [
  "ec2-54-159-217-16.compute-1.amazonaws.com",
  "ec2-35-170-33-78.compute-1.amazonaws.com",
  "ec2-18-233-162-38.compute-1.amazonaws.com",
]
```

When creating the EC2 instances, we only assign a public IP to one of them by using the [conditional expression](https://www.terraform.io/docs/configuration/expressions.html#conditional-expressions) like this: `associate_public_ip_address = ( count.index == 1 ? true : false)`

We then use the conditional expression with lists inside the **for** expression in an output to show all the private and public IPs of the 3 instances.  We do this in two ways, using the list() interpolation and using brackets.

This is the version with the list() interpolation:
```
output "ips_with_list_interpolation" {
  value = [
    for instance in aws_instance.ubuntu:
    (instance.public_ip != "" ? list(instance.private_ip, instance.public_ip) : list(instance.private_ip))
  ]
}
```

This is the version with brackets:
```
output "ips_with_list_in_brackets" {
  value = [
    for instance in aws_instance.ubuntu:
    (instance.public_ip != "" ? [instance.private_ip, instance.public_ip] : [instance.private_ip])
  ]
}
```

Both of these give outputs like:
```
ips = [
  [
    "172.16.10.218",
  ],
  [
    "172.16.10.199",
    "34.201.169.46",
  ],
  [
    "172.16.10.250",
  ],
]
```
Note that ips consists of 3 lists, of which only the second has two items because only the second EC2 instance has a public IP.

In the lists-and-maps-with-for.tf code, we demonstrate the use of the **for** expression to convert a list of lower-case letters to upper case. We first do this in a list:
```
output "upper-case-list" {
  value = [for l in var.letters: upper(l)]
}
```
and then in a map:
```
output "upper-case-map" {
  value = {for l in var.letters: l => upper(l)}
}
```
The first gives the output
which gives the output:
```
upper-case-list = [
  "A",
  "B",
  "C",
]
```
while the second gives:
```
upper-case-map = {
  "a" = "A"
  "b" = "B"
  "c" = "C"
}
```
