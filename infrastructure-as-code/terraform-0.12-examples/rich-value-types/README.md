# Rich Value Types Example
This example illustrates how the new [Rich Value Types](https://www.hashicorp.com/blog/terraform-0-12-rich-value-types) can be passed into and out of a module. It also shows that entire resources can be returned as outputs of a module. In fact, you can even return an entire module as an output of the root module.

The top-level main.tf file passes a single map with 4 strings into a module after defining the map as a local value:
```
module "network" {
  source = "./network"
  network_config = local.network_config
}
```
This works because the variable for the module is defined as a map with 4 strings too:
```
variable "network_config" {
  type = object({
    vpc_name = string
    vpc_cidr = string
    subnet_name = string
    subnet_cidr = string
  })
}
```
Inside the module, we refer to the strings with expressions like `var.network_config.vpc_name`.

The module creates an AWS VPC and subnet and then passes those resources back to the root module as outputs:
```
output "vpc" {
  value = aws_vpc.my_vpc
}
output "subnet" {
  value = aws_subnet.my_subnet
}
```
These outputs are then in turn exported by the root module as outputs:
```
output "vpc" {
  value = module.network.vpc
}

output "subnet" {
  value = module.network.subnet
}
```

Here is what the vpc output gives us:
```
vpc = {
  "arn" = "arn:aws:ec2:us-west-2:753646501470:vpc/vpc-0a1d5a09545df5d29"
  "assign_generated_ipv6_cidr_block" = false
  "cidr_block" = "172.16.0.0/16"
  "default_network_acl_id" = "acl-0d43c530585af11f6"
  "default_route_table_id" = "rtb-07cbd1dc962def19f"
  "default_security_group_id" = "sg-095119122ea1bf847"
  "dhcp_options_id" = "dopt-11683568"
  "enable_classiclink" = false
  "enable_classiclink_dns_support" = false
  "enable_dns_hostnames" = false
  "enable_dns_support" = true
  "id" = "vpc-0a1d5a09545df5d29"
  "instance_tenancy" = "default"
  "ipv6_association_id" = ""
  "ipv6_cidr_block" = ""
  "main_route_table_id" = "rtb-07cbd1dc962def19f"
  "owner_id" = "753646501470"
  "tags" = {
    "Name" = "tf-0.12-rvt-example-vpc"
  }
}
```

We also show that the entire network module could be passed as an output from the root module if desired, but we have left the code commented out.
```
/*output "network_module" {
  value = module.network
}*/
```

This example also illustrates that we can define a variable as an explicit list with a default value (interface_ips) and assign that to a resource.  We define the variable with:
```
variable "interface_ips" {
  type = list
  description = "IP for network interface"
  default = ["172.16.10.100"]
}
```
Note that we don't use quotes around "list" because types are now first-class values. We also could have used `list(string)`.

We pass the variable into the aws_network_interface.rvt resource of the root module with `private_ips = var.interface_ips`. In the past, we would probably have set some string variable like interface_ip to "172.16.10.100" and then used `private_ips = ["${var.interface_ip}"]`. To some extent, we have just shifted the list brackets and quotes to the definition of the variable, but this does allow the specification of the resource to be clearer.

We also create an EC2 instance in the root module.
