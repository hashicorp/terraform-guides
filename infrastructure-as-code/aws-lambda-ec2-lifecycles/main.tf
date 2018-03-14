# Terraform configurations for creating lambda functions to help manage
# your ec2 instance lifecycles. The data_collectors.tf and iam_roles.tf
# files are required. You may also use one or more of the following:
#
# notify_instance_usage.tf - Notify slack with instance usage #s
# notify_untagged.tf - Checks for mandatory tags, notifies slack.
# instance_reaper.tf - Terminates instances that have passed their TTL.
# untagged_janitor.tf - Cleans up untagged instances.

provider "aws" {                                             
  region     = "${var.region}"                                    
}
