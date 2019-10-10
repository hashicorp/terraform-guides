# First Class Expressions Example
This example creates an AWS VPC, a subnet, a network interface, and an EC2 instance. It illustrates the following new features:
1. Referencing of Terraform variables and resource arguments without interpolation using [First Class Expressions](https://www.hashicorp.com/blog/terraform-0-12-preview-first-class-expressions). (Note that this blog post refers to "attributes" instead of to "arguments".)
1. The need to include `=` when setting the value for arguments of type map or list.

In particular, the Terraform code that creates the VPC refers to the variable called vpc_name directly (`Name = var.vpc_name`) without using interpolation which would have used `${var.vpc_name}`. Other code in this example also directly refers to the id of the VPC (`vpc_id = aws_vpc.my_vpc.id`) in the subnet resource, to the id of the subnet (`subnet_id = aws_subnet.my_subnet.id`) in the network interface resource, and to the id of the network interface (`network_interface_id = aws_network_interface.foo.id`) in the EC2 instance. In a similar fashion, the output refers to the private_dns attribute (`value = aws_instance.foo.private_dns`) of the EC2 instance.

Additionally, the code uses `=` when setting the tags arguments of all the resources to the maps that include the Name key/value pairs.  For example the tags for the subnet are added with:
```
tags = {
  Name = "tf-0.12-example"
}
```
This is required in Terraform 0.12 since tags is an argument rather than a block which would not use `=`. In contrast, we do not include `=` when specifying the network_interface block of the EC2 instance since this is a block.

It is not easy to distinguish blocks from arguments of type map when looking at pre-0.12 Terraform code. But if you look at the documentation for a resource, all blocks have their own sub-topic describing the block. So, there is a [Network Interfaces](https://www.terraform.io/docs/providers/aws/r/instance.html#network-interfaces) sub-topic for the network_interface block of the aws_instance resource, but there is no sub-topic for the tags argument of the same resource.

For more on the difference between arguments and blocks, see [Arguments and Blocks](https://www.terraform.io/docs/configuration/syntax.html#arguments-and-blocks).

For more on expressions in general, see [Expressions](https://www.terraform.io/docs/configuration/expressions.html).
