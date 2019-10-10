# Advanced Dynamic Blocks Example
This example shows how [dynamic blocks](https://www.terraform.io/docs/configuration/expressions.html#dynamic-blocks) can be used to dynamically create multiple instances of a block within a resource from a complex value such as a list of maps.

In this example, we create an [Elastic Beanstalk Environment](https://www.terraform.io/docs/providers/aws/r/elastic_beanstalk_environment.html) resource with two option settings dynamically generated from a variable `settings` defined as a list of maps, each of which has three entries: `namespace`, `name`, and `value`.  

We define the `settings` variable in main.tf like this:

```
variable "settings" {
  type = list(map(string))
}
```
Note that we specify the type of the variable as `list(map(string))` which indicates that it is a list of maps whose values are strings.

We provide the value for the `settings` variable in a terraform.tfvars file:

```
settings = [
 {
   namespace = "aws:ec2:vpc"
   name = "VPCId"
   value = "vpc-xxxxxxxxxxxxxxxxx"
 },
 {
   namespace = "aws:ec2:vpc"
   name = "Subnets"
   value = "subnet-xxxxxxxxxxxxxxxxx"
 },
]
```

Finally, we dynamically create the setting blocks within the aws_elastic_beanstalk_environment resource like this:

```
resource "aws_elastic_beanstalk_environment" "tfenvtest" {
  name                = "tf-test-name"
  application         = "${aws_elastic_beanstalk_application.tftest.name}"
  solution_stack_name = "64bit Amazon Linux 2018.03 v2.11.4 running Go 1.12.6"

  dynamic "setting" {
    for_each = var.settings
    content {
      namespace = setting.value["namespace"]
      name = setting.value["name"]
      value = setting.value["value"]
    }
  }
}
```

Note that we specify the `settings` variable in the `for_each` argument and then reference the three items of each map within the `settings` variable using the names of the map's keys.

To actually run this, please specify valid VPC and subnet IDs in your copy of terraform.tfvars.

You should see output from running `terraform apply` that looks like this:

```
  # aws_elastic_beanstalk_environment.tfenvtest will be created
  + resource "aws_elastic_beanstalk_environment" "tfenvtest" {
      + all_settings           = (known after apply)
      + application            = "tf-test-name"
      + arn                    = (known after apply)
      + autoscaling_groups     = (known after apply)
      + cname                  = (known after apply)
      + cname_prefix           = (known after apply)
      + id                     = (known after apply)
      + instances              = (known after apply)
      + launch_configurations  = (known after apply)
      + load_balancers         = (known after apply)
      + name                   = "tf-test-name"
      + platform_arn           = (known after apply)
      + queues                 = (known after apply)
      + solution_stack_name    = "64bit Amazon Linux 2018.03 v2.11.4 running Go 1.12.6"
      + tier                   = "WebServer"
      + triggers               = (known after apply)
      + version_label          = (known after apply)
      + wait_for_ready_timeout = "20m"

      + setting {
          + name      = "Subnets"
          + namespace = "aws:ec2:vpc"
          + value     = "subnet-06dcc5d225b48b816"
        }
      + setting {
          + name      = "VPCId"
          + namespace = "aws:ec2:vpc"
          + value     = "vpc-00e555dc5f3a3cbc2"
        }
    }
```
