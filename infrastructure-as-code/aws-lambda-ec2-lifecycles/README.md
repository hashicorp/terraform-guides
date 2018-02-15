# Terraforming EC2 lifecycles with AWS Lambda & Slack
Terraform configuration for lifecycle management of AWS instances.

![Lambda bot posting to Slack](./assets/good_morning.png)

Are you spending too much on your AWS instances every month? Do your developers create instances and forget to turn them off? Perhaps you struggle with identifying which person or system created AWS resources? This guide is for you!

## Reference Material
 * [AWS Lambda & Slack Tutorial](https://api.slack.com/tutorials/aws-lambda)
 * [Slack Integration Blueprints for AWS Lambda](https://aws.amazon.com/blogs/aws/new-slack-integration-blueprints-for-aws-lambda/)
 * [Terraform aws_lambda_function resource](https://www.terraform.io/docs/providers/aws/r/lambda_function.html)


## Estimated Time to Complete
30-60 minutes

## Personas
Our target persona is anyone concerned with monitoring and keeping AWS instance costs under control. This may include system administrators, cloud engineers, or solutions architects. 

## Challenge
Many organizations struggle to maintain control over spending on AWS resources. Amazon Web Services makes it very easy to spin up new applicaiton workloads in the cloud, but the user is left to their own devices to clean up any unused or expired infrastructure. Users need an easy way to enforce tagging standards and shut down or terminate instances that are no longer required.

## Solution
This Terraform configuration deploys AWS Lambda functions that can do the following:

 - Check for mandatory tags on AWS instances and notify via Slack if untagged instances are found.
 - Notify on how many of each instance type are currently running across all regions.
 - Shutdown untagged instances after X days.
 - Delete untagged instances after Y days.
 - Delete machines whose TTL (time to live) has expired.

### Directory Structure
A description of what each file does:
```
 main.tf - Main configuration file. REQUIRED
 data_collectors.tf - Lambda functions for gathering instance data. REQUIRED
 iam_roles.tf - Configures IAM role and policies for your Lambda functions. REQUIRED
 notify_slack_instance_usage.tf - sends reports to Slack about running instances.
 notify_slack_untagged.tf - sends reports to slack about untagged instances and their key names.
 instance_reaper.tf - Checks instance TTL tag, terminates instances that have expired.
 untagged_janitor.tf - Cleans up untagged instances after a set number of days.
 files/ - Contains all of the lambda source code, zip files, and IAM template files.
```

## Prerequisites
1. Admin level access to your AWS account via API. If admin access is not available you must have the ability to create, describe, and delete the following types of resources in AWS. Fine-grained configuration of IAM policies is beyond the scope of this guide. We will assume you have API keys and appropriate permissions that allow you to create the following resources using Terraform:

    aws\_cloudwatch\_event\_rule  
    aws\_cloudwatch\_event\_target  
    aws\_iam\_role  
    aws\_iam\_role\_policy  
    aws\_lambda\_function  
    aws\_lambda\_permission  
    aws\_kms\_alias  
    aws\_kms\_key  

2. Properly configured workstation or server for running Terraform commands. New to Terraform? Try our [Getting Started Guide](https://www.terraform.io/intro/getting-started/install.html)

3. An [incoming webhook integration](https://api.slack.com/incoming-webhooks) in your Slack account. If you want to receive notifications about instance usage and tags you'll need to be able to create a webhook or ask your administrator to help you create one.

## TL;DR
Below are all of the commands you'll need to run to get these lambda scripts deployed in your account:
```
# Be sure to configure your Slack webhook and edit your variables.tf file first!
terraform init
terraform plan
terraform apply
```

## Steps
The following walkthrough describes in detail the steps required to enable the cleanup and 'reaper' scripts that are included in this repo.

### Step 1: Configure incoming Slack webhook
Set up your Slack incoming webhook: https://my.slack.com/services/new/incoming-webhook/. Feel free to give your new bot a unique name, icon and description. Make note of the Webhook URL. This is a specially coded URL that allows remote applications to post data into your Slack channels. Do not share this link publicly or commit it to your source code repo. Choose the channel you want your bot to post messages to.

![Slack Webhook Config Page](./assets/aws_bot.png)

### Step 2: Configure your variables
Edit the `variables.tf` file and choose which region you want to run your Lambda functions in. These functions can be run from any region and manage instances in any other region.

```
variable "region" {
  default     = "us-west-2"
  description = "AWS Region"
}

variable "slack_hook_url" {
  default = "https://hooks.slack.com/services/REPLACE/WITH/YOUR_WEBHOOK"
  description = "Slack incoming webhook URL, get this from the slack management page."
}
```

 * Set the `slack_hook_url` variable to the URL you generated in step #1.  
 * Set any tags that you want to be considered mandatory in the `mandatory_tags` variable. This is a comma separated list, with no spaces between items.  
 * Set the `reap_days` and `sleep_days` to your liking. These represent the number of days after launch that an untagged instance will be stopped and terminated respectively.  
 * Save the `variables.tf` file.  

### Step 3: Run Terraform Plan

#### CLI
 * [Terraform Plan Docs](https://www.terraform.io/docs/commands/plan.html)

#### Request

```
$ terraform plan
```

#### Response
```
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

data.aws_caller_identity.current: Refreshing state...
data.template_file.iam_lambda_stop_and_terminate_instances: Refreshing state...
data.template_file.iam_lambda_notify_slack: Refreshing state...
data.template_file.iam_lambda_read_instances: Refreshing state...

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  + aws_cloudwatch_event_rule.check_instance_ttls
      id:                                   <computed>
      arn:                                  <computed>
      description:                          "Check instance TTLs to see if they are expired"
      is_enabled:                           "true"
      name:                                 "check_instance_ttls"
      schedule_expression:                  "cron(0 8 * * ? *)"

  + aws_cloudwatch_event_rule.clean_untagged_instances
      id:                                   <computed>
      arn:                                  <computed>
      description:                          "Check untagged instances and stop/terminate old ones"
      is_enabled:                           "true"
      name:                                 "clean_untagged_instances"
      schedule_expression:                  "cron(0 8 * * ? *)"

  + aws_cloudwatch_event_rule.notify_slack_running_instances
      id:                                   <computed>
      arn:                                  <computed>
      description:                          "Notify users about their running AWS instances via Slack"
      is_enabled:                           "true"
      name:                                 "notify_slack_running_instances"
      schedule_expression:                  "cron(0 8 * * ? *)"

  + aws_cloudwatch_event_rule.notify_slack_untagged_instances
      id:                                   <computed>
      arn:                                  <computed>
      description:                          "Notify users about their untagged AWS instances via Slack"
      is_enabled:                           "true"
      name:                                 "notify_slack_untagged_instances"
      schedule_expression:                  "cron(0 6 * * ? *)"

  + aws_cloudwatch_event_target.daily_running_report
      id:                                   <computed>
      arn:                                  "${aws_lambda_function.notifySlackInstanceUsage.arn}"
      rule:                                 "notify_slack_running_instances"
      target_id:                            "notifySlackInstanceUsage"

  + aws_cloudwatch_event_target.daily_untagged_report
      id:                                   <computed>
      arn:                                  "${aws_lambda_function.notifySlackUntaggedInstances.arn}"
      rule:                                 "notify_slack_untagged_instances"
      target_id:                            "notifySlackUntaggedInstances"

  + aws_cloudwatch_event_target.reaper_report
      id:                                   <computed>
      arn:                                  "${aws_lambda_function.checkInstanceTTLs.arn}"
      rule:                                 "check_instance_ttls"
      target_id:                            "checkInstanceTTLs"

  + aws_cloudwatch_event_target.untagged_instance_cleanup
      id:                                   <computed>
      arn:                                  "${aws_lambda_function.cleanUntaggedInstances.arn}"
      rule:                                 "clean_untagged_instances"
      target_id:                            "cleanUntaggedInstances"

  + aws_iam_role.lambda_notify_slack
      id:                                   <computed>
      arn:                                  <computed>
      assume_role_policy:                   "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Effect\": \"Allow\",\n      \"Action\": \"sts:AssumeRole\",\n      \"Principal\": {\n        \"Service\": \"lambda.amazonaws.com\"\n      }\n    }\n  ]\n}\n"
      create_date:                          <computed>
      force_detach_policies:                "false"
      name:                                 "lambda_notify_slack"
      path:                                 "/"
      unique_id:                            <computed>

  + aws_iam_role.lambda_read_instances
      id:                                   <computed>
      arn:                                  <computed>
      assume_role_policy:                   "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Effect\": \"Allow\",\n      \"Action\": \"sts:AssumeRole\",\n      \"Principal\": {\n        \"Service\": \"lambda.amazonaws.com\"\n      }\n    }\n  ]\n}\n"
      create_date:                          <computed>
      force_detach_policies:                "false"
      name:                                 "lambda_read_instances"
      path:                                 "/"
      unique_id:                            <computed>

  + aws_iam_role.lambda_stop_and_terminate_instances
      id:                                   <computed>
      arn:                                  <computed>
      assume_role_policy:                   "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Effect\": \"Allow\",\n      \"Action\": \"sts:AssumeRole\",\n      \"Principal\": {\n        \"Service\": \"lambda.amazonaws.com\"\n      }\n    }\n  ]\n}\n"
      create_date:                          <computed>
      force_detach_policies:                "false"
      name:                                 "lambda_stop_and_terminate_instances"
      path:                                 "/"
      unique_id:                            <computed>

  + aws_iam_role_policy.lambda_notify_slack_policy
      id:                                   <computed>
      name:                                 "lambda_notify_slack_policy"
      policy:                               "{\n    \"Version\": \"2012-10-17\",\n    \"Statement\": [\n        {\n            \"Effect\": \"Allow\",\n            \"Action\": \"logs:CreateLogGroup\",\n            \"Resource\": \"arn:aws:logs:us-west-2:867530986753:*\"\n        },\n
      {\n            \"Effect\": \"Allow\",\n            \"Action\": [\n                \"logs:CreateLogStream\",\n                \"logs:PutLogEvents\"\n            ],\n            \"Resource\": [\n                \"arn:aws:logs:us-west-2:867530986753:*\"\n            ]\n        },\n        {\n            \"Effect\": \"Allow\",\n            \"Action\": \"lambda:InvokeFunction\",\n            \"Resource\": \"*\"\n        }\n    ]\n}"
      role:                                 "${aws_iam_role.lambda_notify_slack.id}"

  + aws_iam_role_policy.lambda_read_instances_policy
      id:                                   <computed>
      name:                                 "lambda_read_instances_policy"
      policy:                               "{\n    \"Version\": \"2012-10-17\",\n    \"Statement\": [\n        {\n            \"Effect\": \"Allow\",\n            \"Action\": \"logs:CreateLogGroup\",\n            \"Resource\": \"arn:aws:logs:us-west-2:867530986753:*\"\n        },\n
      {\n            \"Effect\": \"Allow\",\n            \"Action\": [\n                \"logs:CreateLogStream\",\n                \"logs:PutLogEvents\"\n            ],\n            \"Resource\": [\n                \"arn:aws:logs:us-west-2:867530986753:*\"\n            ]\n        },\n        {\n            \"Effect\": \"Allow\",\n            \"Action\": \"ec2:Describe*\",\n            \"Resource\": \"*\"\n        },\n        {\n            \"Effect\": \"Allow\",\n            \"Action\": \"elasticloadbalancing:Describe*\",\n            \"Resource\": \"*\"\n
  },\n        {\n            \"Effect\": \"Allow\",\n            \"Action\": [\n                \"cloudwatch:ListMetrics\",\n                \"cloudwatch:GetMetricStatistics\",\n                \"cloudwatch:Describe*\"\n            ],\n            \"Resource\": \"*\"\n        },\n
     {\n            \"Effect\": \"Allow\",\n            \"Action\": \"autoscaling:Describe*\",\n            \"Resource\": \"*\"\n        }\n    ]\n}"
      role:                                 "${aws_iam_role.lambda_read_instances.id}"

  + aws_iam_role_policy.lambda_stop_and_terminate_instances
      id:                                   <computed>
      name:                                 "lambda_stop_and_terminate_instances"
      policy:                               "{\n    \"Version\": \"2012-10-17\",\n    \"Statement\": [\n        {\n            \"Effect\": \"Allow\",\n            \"Action\": \"logs:CreateLogGroup\",\n            \"Resource\": \"arn:aws:logs:us-west-2:867530986753:*\"\n        },\n
      {\n            \"Effect\": \"Allow\",\n            \"Action\": [\n                \"logs:CreateLogStream\",\n                \"logs:PutLogEvents\"\n            ],\n            \"Resource\": [\n                \"arn:aws:logs:us-west-2:867530986753:*\"\n            ]\n        },\n        {\n            \"Effect\": \"Allow\",\n            \"Action\": \"lambda:InvokeFunction\",\n            \"Resource\": \"*\"\n        },\n        {\n            \"Effect\": \"Allow\",\n            \"Action\": \"ec2:*\",\n            \"Resource\": \"*\"\n        }\n    ]\n}"
      role:                                 "${aws_iam_role.lambda_stop_and_terminate_instances.id}"

  + aws_lambda_function.checkInstanceTTLs
      id:                                   <computed>
      arn:                                  <computed>
      description:                          "Checks instance TTLs for expiration and deals with them accordingly."
      environment.#:                        "1"
      environment.0.variables.%:            "2"
      environment.0.variables.slackChannel: "#aws-hc-se-demos"
      environment.0.variables.slackHookUrl: "https://hooks.slack.com/services/REPLACE/WITH/YOURWEBHOOK"
      filename:                             "./files/checkInstanceTTLs.zip"
      function_name:                        "checkInstanceTTLs"
      handler:                              "checkInstanceTTLs.lambda_handler"
      invoke_arn:                           <computed>
      last_modified:                        <computed>
      memory_size:                          "128"
      publish:                              "false"
      qualified_arn:                        <computed>
      role:                                 "${aws_iam_role.lambda_stop_and_terminate_instances.arn}"
      runtime:                              "python3.6"
      source_code_hash:                     "sSzROEXCA3CwFxxvh0ja1+jLGegjec3/FLTtlHZUoVo="
      timeout:                              "120"
      tracing_config.#:                     <computed>
      version:                              <computed>

  + aws_lambda_function.cleanUntaggedInstances
      id:                                   <computed>
      arn:                                  <computed>
      description:                          "Checks instance TTLs for expiration and deals with them accordingly."
      environment.#:                        "1"
      environment.0.variables.%:            "4"
      environment.0.variables.reapDays:     "90"
      environment.0.variables.slackChannel: "#aws-hc-se-demos"
      environment.0.variables.slackHookUrl: "https://hooks.slack.com/services/REPLACE/WITH/YOURWEBHOOK"
      environment.0.variables.sleepDays:    "14"
      filename:                             "./files/cleanUntaggedInstances.zip"
      function_name:                        "cleanUntaggedInstances"
      handler:                              "cleanUntaggedInstances.lambda_handler"
      invoke_arn:                           <computed>
      last_modified:                        <computed>
      memory_size:                          "128"
      publish:                              "false"
      qualified_arn:                        <computed>
      role:                                 "${aws_iam_role.lambda_stop_and_terminate_instances.arn}"
      runtime:                              "python3.6"
      source_code_hash:                     "UAtooFP4yd/p1/5pk1yN9yqZ9KWATkbbeZbN/GemX8A="
      timeout:                              "120"
      tracing_config.#:                     <computed>
      version:                              <computed>

  + aws_lambda_function.getRunningInstances
      id:                                   <computed>
      arn:                                  <computed>
      description:                          "Gathers a list of running instances."
      filename:                             "./files/getRunningInstances.zip"
      function_name:                        "getRunningInstances"
      handler:                              "getRunningInstances.lambda_handler"
      invoke_arn:                           <computed>
      last_modified:                        <computed>
      memory_size:                          "128"
      publish:                              "false"
      qualified_arn:                        <computed>
      role:                                 "${aws_iam_role.lambda_read_instances.arn}"
      runtime:                              "python3.6"
      source_code_hash:                     "iUEHHBeeBnXfmJn9dUMFvrTzlmDdItZZDhIVDlsTTzM="
      timeout:                              "120"
      tracing_config.#:                     <computed>
      version:                              <computed>

  + aws_lambda_function.getTaggedInstances
      id:                                   <computed>
      arn:                                  <computed>
      description:                          "Gathers a list of correctly tagged instances."
      environment.#:                        "1"
      environment.0.variables.%:            "1"
      environment.0.variables.REQTAGS:      "TTL,owner"
      filename:                             "./files/getTaggedInstances.zip"
      function_name:                        "getTaggedInstances"
      handler:                              "getTaggedInstances.lambda_handler"
      invoke_arn:                           <computed>
      last_modified:                        <computed>
      memory_size:                          "128"
      publish:                              "false"
      qualified_arn:                        <computed>
      role:                                 "${aws_iam_role.lambda_read_instances.arn}"
      runtime:                              "python3.6"
      source_code_hash:                     "HIHlffjNm8J7bPxg88vsTPP60trn4jPy+848YfuADlc="
      timeout:                              "120"
      tracing_config.#:                     <computed>
      version:                              <computed>

  + aws_lambda_function.getUntaggedInstances
      id:                                   <computed>
      arn:                                  <computed>
      description:                          "Gathers a list of untagged or improperly tagged instances."
      environment.#:                        "1"
      environment.0.variables.%:            "1"
      environment.0.variables.REQTAGS:      "TTL,owner"
      filename:                             "./files/getUntaggedInstances.zip"
      function_name:                        "getUntaggedInstances"
      handler:                              "getUntaggedInstances.lambda_handler"
      invoke_arn:                           <computed>
      last_modified:                        <computed>
      memory_size:                          "128"
      publish:                              "false"
      qualified_arn:                        <computed>
      role:                                 "${aws_iam_role.lambda_read_instances.arn}"
      runtime:                              "python3.6"
      source_code_hash:                     "AqaC9D61lTcN+0cxJaKSvPuaSEK5/RwzIOsj5+Hug60="
      timeout:                              "120"
      tracing_config.#:                     <computed>
      version:                              <computed>

  + aws_lambda_function.notifySlackInstanceUsage
      id:                                   <computed>
      arn:                                  <computed>
      description:                          "Sends a notification message to slack with info about number of running instances by type."
      environment.#:                        "1"
      environment.0.variables.%:            "2"
      environment.0.variables.slackChannel: "#aws-hc-se-demos"
      environment.0.variables.slackHookUrl: "https://hooks.slack.com/services/REPLACE/WITH/YOURWEBHOOK"
      filename:                             "./files/notifySlackInstanceUsage.zip"
      function_name:                        "notifySlackInstanceUsage"
      handler:                              "notifySlackInstanceUsage.lambda_handler"
      invoke_arn:                           <computed>
      last_modified:                        <computed>
      memory_size:                          "128"
      publish:                              "false"
      qualified_arn:                        <computed>
      role:                                 "${aws_iam_role.lambda_notify_slack.arn}"
      runtime:                              "python3.6"
      source_code_hash:                     "Cvf18Bppw9lDmFHUJQz5ZU1t0TyZC8dIW9Sr1RCUh9c="
      timeout:                              "120"
      tracing_config.#:                     <computed>
      version:                              <computed>

  + aws_lambda_function.notifySlackUntaggedInstances
      id:                                   <computed>
      arn:                                  <computed>
      description:                          "Sends a notification message to slack with info about untagged instances."
      environment.#:                        "1"
      environment.0.variables.%:            "2"
      environment.0.variables.slackChannel: "#aws-hc-se-demos"
      environment.0.variables.slackHookUrl: "https://hooks.slack.com/services/REPLACE/WITH/YOURWEBHOOK"
      filename:                             "./files/notifySlackUntaggedInstances.zip"
      function_name:                        "notifySlackUntaggedInstances"
      handler:                              "notifySlackUntaggedInstances.lambda_handler"
      invoke_arn:                           <computed>
      last_modified:                        <computed>
      memory_size:                          "128"
      publish:                              "false"
      qualified_arn:                        <computed>
      role:                                 "${aws_iam_role.lambda_notify_slack.arn}"
      runtime:                              "python3.6"
      source_code_hash:                     "7mQyGa4tF+a6Pj+5n+vHYiAuuKGNLm2FRti8/ZCb1nk="
      timeout:                              "120"
      tracing_config.#:                     <computed>
      version:                              <computed>

  + aws_lambda_permission.allow_cloudwatch_check_ttls
      id:                                   <computed>
      action:                               "lambda:InvokeFunction"
      function_name:                        "checkInstanceTTLs"
      principal:                            "events.amazonaws.com"
      source_arn:                           "${aws_cloudwatch_event_rule.check_instance_ttls.arn}"
      statement_id:                         "AllowExecutionFromCloudWatch"

  + aws_lambda_permission.allow_cloudwatch_clean_untagged_instances
      id:                                   <computed>
      action:                               "lambda:InvokeFunction"
      function_name:                        "cleanUntaggedInstances"
      principal:                            "events.amazonaws.com"
      source_arn:                           "${aws_cloudwatch_event_rule.clean_untagged_instances.arn}"
      statement_id:                         "AllowExecutionFromCloudWatch"

  + aws_lambda_permission.allow_cloudwatch_instance_usage
      id:                                   <computed>
      action:                               "lambda:InvokeFunction"
      function_name:                        "notifySlackInstanceUsage"
      principal:                            "events.amazonaws.com"
      source_arn:                           "${aws_cloudwatch_event_rule.notify_slack_running_instances.arn}"
      statement_id:                         "AllowExecutionFromCloudWatch"

  + aws_lambda_permission.allow_cloudwatch_untagged_instances
      id:                                   <computed>
      action:                               "lambda:InvokeFunction"
      function_name:                        "notifySlackUntaggedInstances"
      principal:                            "events.amazonaws.com"
      source_arn:                           "${aws_cloudwatch_event_rule.notify_slack_untagged_instances.arn}"
      statement_id:                         "AllowExecutionFromCloudWatch"


Plan: 25 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

### Step 4: Run Terraform Apply

#### CLI
 * [Terraform Apply Docs](https://www.terraform.io/docs/commands/apply.html)

#### Request

```
$ terraform apply
```

#### Response
```
data.aws_caller_identity.current: Refreshing state...
data.template_file.iam_lambda_read_instances: Refreshing state...
data.template_file.iam_lambda_stop_and_terminate_instances: Refreshing state...
data.template_file.iam_lambda_notify_slack: Refreshing state...

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  + aws_cloudwatch_event_rule.check_instance_ttls
      id:                                   <computed>
      arn:                                  <computed>
      description:                          "Check instance TTLs to see if they are expired"
      is_enabled:                           "true"
      name:                                 "check_instance_ttls"
      schedule_expression:                  "cron(0 8 * * ? *)"

  + aws_cloudwatch_event_rule.clean_untagged_instances
      id:                                   <computed>
      arn:                                  <computed>
      description:                          "Check untagged instances and stop/terminate old ones"
      is_enabled:                           "true"
      name:                                 "clean_untagged_instances"
      schedule_expression:                  "cron(0 8 * * ? *)"

  + aws_cloudwatch_event_rule.notify_slack_running_instances
      id:                                   <computed>
      arn:                                  <computed>
      description:                          "Notify users about their running AWS instances via Slack"
      is_enabled:                           "true"
      name:                                 "notify_slack_running_instances"
      schedule_expression:                  "cron(0 8 * * ? *)"

  + aws_cloudwatch_event_rule.notify_slack_untagged_instances
      id:                                   <computed>
      arn:                                  <computed>
      description:                          "Notify users about their untagged AWS instances via Slack"
      is_enabled:                           "true"
      name:                                 "notify_slack_untagged_instances"
      schedule_expression:                  "cron(0 6 * * ? *)"

  + aws_cloudwatch_event_target.daily_running_report
      id:                                   <computed>
      arn:                                  "${aws_lambda_function.notifySlackInstanceUsage.arn}"
      rule:                                 "notify_slack_running_instances"
      target_id:                            "notifySlackInstanceUsage"

  + aws_cloudwatch_event_target.daily_untagged_report
      id:                                   <computed>
      arn:                                  "${aws_lambda_function.notifySlackUntaggedInstances.arn}"
      rule:                                 "notify_slack_untagged_instances"
      target_id:                            "notifySlackUntaggedInstances"

  + aws_cloudwatch_event_target.reaper_report
      id:                                   <computed>
      arn:                                  "${aws_lambda_function.checkInstanceTTLs.arn}"
      rule:                                 "check_instance_ttls"
      target_id:                            "checkInstanceTTLs"

  + aws_cloudwatch_event_target.untagged_instance_cleanup
      id:                                   <computed>
      arn:                                  "${aws_lambda_function.cleanUntaggedInstances.arn}"
      rule:                                 "clean_untagged_instances"
      target_id:                            "cleanUntaggedInstances"

  + aws_iam_role.lambda_notify_slack
      id:                                   <computed>
      arn:                                  <computed>
      assume_role_policy:                   "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Effect\": \"Allow\",\n      \"Action\": \"sts:AssumeRole\",\n      \"Principal\": {\n        \"Service\": \"lambda.amazonaws.com\"\n      }\n    }\n  ]\n}\n"
      create_date:                          <computed>
      force_detach_policies:                "false"
      name:                                 "lambda_notify_slack"
      path:                                 "/"
      unique_id:                            <computed>

  + aws_iam_role.lambda_read_instances
      id:                                   <computed>
      arn:                                  <computed>
      assume_role_policy:                   "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Effect\": \"Allow\",\n      \"Action\": \"sts:AssumeRole\",\n      \"Principal\": {\n        \"Service\": \"lambda.amazonaws.com\"\n      }\n    }\n  ]\n}\n"
      create_date:                          <computed>
      force_detach_policies:                "false"
      name:                                 "lambda_read_instances"
      path:                                 "/"
      unique_id:                            <computed>

  + aws_iam_role.lambda_stop_and_terminate_instances
      id:                                   <computed>
      arn:                                  <computed>
      assume_role_policy:                   "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Effect\": \"Allow\",\n      \"Action\": \"sts:AssumeRole\",\n      \"Principal\": {\n        \"Service\": \"lambda.amazonaws.com\"\n      }\n    }\n  ]\n}\n"
      create_date:                          <computed>
      force_detach_policies:                "false"
      name:                                 "lambda_stop_and_terminate_instances"
      path:                                 "/"
      unique_id:                            <computed>

  + aws_iam_role_policy.lambda_notify_slack_policy
      id:                                   <computed>
      name:                                 "lambda_notify_slack_policy"
      policy:                               "{\n    \"Version\": \"2012-10-17\",\n    \"Statement\": [\n        {\n            \"Effect\": \"Allow\",\n            \"Action\": \"logs:CreateLogGroup\",\n            \"Resource\": \"arn:aws:logs:us-west-2:867530986753:*\"\n        },\n
      {\n            \"Effect\": \"Allow\",\n            \"Action\": [\n                \"logs:CreateLogStream\",\n                \"logs:PutLogEvents\"\n            ],\n            \"Resource\": [\n                \"arn:aws:logs:us-west-2:867530986753:*\"\n            ]\n        },\n        {\n            \"Effect\": \"Allow\",\n            \"Action\": \"lambda:InvokeFunction\",\n            \"Resource\": \"*\"\n        }\n    ]\n}"
      role:                                 "${aws_iam_role.lambda_notify_slack.id}"

  + aws_iam_role_policy.lambda_read_instances_policy
      id:                                   <computed>
      name:                                 "lambda_read_instances_policy"
      policy:                               "{\n    \"Version\": \"2012-10-17\",\n    \"Statement\": [\n        {\n            \"Effect\": \"Allow\",\n            \"Action\": \"logs:CreateLogGroup\",\n            \"Resource\": \"arn:aws:logs:us-west-2:867530986753:*\"\n        },\n
      {\n            \"Effect\": \"Allow\",\n            \"Action\": [\n                \"logs:CreateLogStream\",\n                \"logs:PutLogEvents\"\n            ],\n            \"Resource\": [\n                \"arn:aws:logs:us-west-2:867530986753:*\"\n            ]\n        },\n        {\n            \"Effect\": \"Allow\",\n            \"Action\": \"ec2:Describe*\",\n            \"Resource\": \"*\"\n        },\n        {\n            \"Effect\": \"Allow\",\n            \"Action\": \"elasticloadbalancing:Describe*\",\n            \"Resource\": \"*\"\n
  },\n        {\n            \"Effect\": \"Allow\",\n            \"Action\": [\n                \"cloudwatch:ListMetrics\",\n                \"cloudwatch:GetMetricStatistics\",\n                \"cloudwatch:Describe*\"\n            ],\n            \"Resource\": \"*\"\n        },\n
     {\n            \"Effect\": \"Allow\",\n            \"Action\": \"autoscaling:Describe*\",\n            \"Resource\": \"*\"\n        }\n    ]\n}"
      role:                                 "${aws_iam_role.lambda_read_instances.id}"

  + aws_iam_role_policy.lambda_stop_and_terminate_instances
      id:                                   <computed>
      name:                                 "lambda_stop_and_terminate_instances"
      policy:                               "{\n    \"Version\": \"2012-10-17\",\n    \"Statement\": [\n        {\n            \"Effect\": \"Allow\",\n            \"Action\": \"logs:CreateLogGroup\",\n            \"Resource\": \"arn:aws:logs:us-west-2:867530986753:*\"\n        },\n
      {\n            \"Effect\": \"Allow\",\n            \"Action\": [\n                \"logs:CreateLogStream\",\n                \"logs:PutLogEvents\"\n            ],\n            \"Resource\": [\n                \"arn:aws:logs:us-west-2:867530986753:*\"\n            ]\n        },\n        {\n            \"Effect\": \"Allow\",\n            \"Action\": \"lambda:InvokeFunction\",\n            \"Resource\": \"*\"\n        },\n        {\n            \"Effect\": \"Allow\",\n            \"Action\": \"ec2:*\",\n            \"Resource\": \"*\"\n        }\n    ]\n}"
      role:                                 "${aws_iam_role.lambda_stop_and_terminate_instances.id}"

  + aws_lambda_function.checkInstanceTTLs
      id:                                   <computed>
      arn:                                  <computed>
      description:                          "Checks instance TTLs for expiration and deals with them accordingly."
      environment.#:                        "1"
      environment.0.variables.%:            "2"
      environment.0.variables.slackChannel: "#aws-hc-se-demos"
      environment.0.variables.slackHookUrl: "https://hooks.slack.com/services/REPLACE/WITH/YOURWEBHOOK"
      filename:                             "./files/checkInstanceTTLs.zip"
      function_name:                        "checkInstanceTTLs"
      handler:                              "checkInstanceTTLs.lambda_handler"
      invoke_arn:                           <computed>
      last_modified:                        <computed>
      memory_size:                          "128"
      publish:                              "false"
      qualified_arn:                        <computed>
      role:                                 "${aws_iam_role.lambda_stop_and_terminate_instances.arn}"
      runtime:                              "python3.6"
      source_code_hash:                     "sSzROEXCA3CwFxxvh0ja1+jLGegjec3/FLTtlHZUoVo="
      timeout:                              "120"
      tracing_config.#:                     <computed>
      version:                              <computed>

  + aws_lambda_function.cleanUntaggedInstances
      id:                                   <computed>
      arn:                                  <computed>
      description:                          "Checks instance TTLs for expiration and deals with them accordingly."
      environment.#:                        "1"
      environment.0.variables.%:            "4"
      environment.0.variables.reapDays:     "90"
      environment.0.variables.slackChannel: "#aws-hc-se-demos"
      environment.0.variables.slackHookUrl: "https://hooks.slack.com/services/REPLACE/WITH/YOURWEBHOOK"
      environment.0.variables.sleepDays:    "14"
      filename:                             "./files/cleanUntaggedInstances.zip"
      function_name:                        "cleanUntaggedInstances"
      handler:                              "cleanUntaggedInstances.lambda_handler"
      invoke_arn:                           <computed>
      last_modified:                        <computed>
      memory_size:                          "128"
      publish:                              "false"
      qualified_arn:                        <computed>
      role:                                 "${aws_iam_role.lambda_stop_and_terminate_instances.arn}"
      runtime:                              "python3.6"
      source_code_hash:                     "UAtooFP4yd/p1/5pk1yN9yqZ9KWATkbbeZbN/GemX8A="
      timeout:                              "120"
      tracing_config.#:                     <computed>
      version:                              <computed>

  + aws_lambda_function.getRunningInstances
      id:                                   <computed>
      arn:                                  <computed>
      description:                          "Gathers a list of running instances."
      filename:                             "./files/getRunningInstances.zip"
      function_name:                        "getRunningInstances"
      handler:                              "getRunningInstances.lambda_handler"
      invoke_arn:                           <computed>
      last_modified:                        <computed>
      memory_size:                          "128"
      publish:                              "false"
      qualified_arn:                        <computed>
      role:                                 "${aws_iam_role.lambda_read_instances.arn}"
      runtime:                              "python3.6"
      source_code_hash:                     "iUEHHBeeBnXfmJn9dUMFvrTzlmDdItZZDhIVDlsTTzM="
      timeout:                              "120"
      tracing_config.#:                     <computed>
      version:                              <computed>

  + aws_lambda_function.getTaggedInstances
      id:                                   <computed>
      arn:                                  <computed>
      description:                          "Gathers a list of correctly tagged instances."
      environment.#:                        "1"
      environment.0.variables.%:            "1"
      environment.0.variables.REQTAGS:      "TTL,owner"
      filename:                             "./files/getTaggedInstances.zip"
      function_name:                        "getTaggedInstances"
      handler:                              "getTaggedInstances.lambda_handler"
      invoke_arn:                           <computed>
      last_modified:                        <computed>
      memory_size:                          "128"
      publish:                              "false"
      qualified_arn:                        <computed>
      role:                                 "${aws_iam_role.lambda_read_instances.arn}"
      runtime:                              "python3.6"
      source_code_hash:                     "HIHlffjNm8J7bPxg88vsTPP60trn4jPy+848YfuADlc="
      timeout:                              "120"
      tracing_config.#:                     <computed>
      version:                              <computed>

  + aws_lambda_function.getUntaggedInstances
      id:                                   <computed>
      arn:                                  <computed>
      description:                          "Gathers a list of untagged or improperly tagged instances."
      environment.#:                        "1"
      environment.0.variables.%:            "1"
      environment.0.variables.REQTAGS:      "TTL,owner"
      filename:                             "./files/getUntaggedInstances.zip"
      function_name:                        "getUntaggedInstances"
      handler:                              "getUntaggedInstances.lambda_handler"
      invoke_arn:                           <computed>
      last_modified:                        <computed>
      memory_size:                          "128"
      publish:                              "false"
      qualified_arn:                        <computed>
      role:                                 "${aws_iam_role.lambda_read_instances.arn}"
      runtime:                              "python3.6"
      source_code_hash:                     "AqaC9D61lTcN+0cxJaKSvPuaSEK5/RwzIOsj5+Hug60="
      timeout:                              "120"
      tracing_config.#:                     <computed>
      version:                              <computed>

  + aws_lambda_function.notifySlackInstanceUsage
      id:                                   <computed>
      arn:                                  <computed>
      description:                          "Sends a notification message to slack with info about number of running instances by type."
      environment.#:                        "1"
      environment.0.variables.%:            "2"
      environment.0.variables.slackChannel: "#aws-hc-se-demos"
      environment.0.variables.slackHookUrl: "https://hooks.slack.com/services/REPLACE/WITH/YOURWEBHOOK"
      filename:                             "./files/notifySlackInstanceUsage.zip"
      function_name:                        "notifySlackInstanceUsage"
      handler:                              "notifySlackInstanceUsage.lambda_handler"
      invoke_arn:                           <computed>
      last_modified:                        <computed>
      memory_size:                          "128"
      publish:                              "false"
      qualified_arn:                        <computed>
      role:                                 "${aws_iam_role.lambda_notify_slack.arn}"
      runtime:                              "python3.6"
      source_code_hash:                     "Cvf18Bppw9lDmFHUJQz5ZU1t0TyZC8dIW9Sr1RCUh9c="
      timeout:                              "120"
      tracing_config.#:                     <computed>
      version:                              <computed>

  + aws_lambda_function.notifySlackUntaggedInstances
      id:                                   <computed>
      arn:                                  <computed>
      description:                          "Sends a notification message to slack with info about untagged instances."
      environment.#:                        "1"
      environment.0.variables.%:            "2"
      environment.0.variables.slackChannel: "#aws-hc-se-demos"
      environment.0.variables.slackHookUrl: "https://hooks.slack.com/services/REPLACE/WITH/YOURWEBHOOK"
      filename:                             "./files/notifySlackUntaggedInstances.zip"
      function_name:                        "notifySlackUntaggedInstances"
      handler:                              "notifySlackUntaggedInstances.lambda_handler"
      invoke_arn:                           <computed>
      last_modified:                        <computed>
      memory_size:                          "128"
      publish:                              "false"
      qualified_arn:                        <computed>
      role:                                 "${aws_iam_role.lambda_notify_slack.arn}"
      runtime:                              "python3.6"
      source_code_hash:                     "7mQyGa4tF+a6Pj+5n+vHYiAuuKGNLm2FRti8/ZCb1nk="
      timeout:                              "120"
      tracing_config.#:                     <computed>
      version:                              <computed>

  + aws_lambda_permission.allow_cloudwatch_check_ttls
      id:                                   <computed>
      action:                               "lambda:InvokeFunction"
      function_name:                        "checkInstanceTTLs"
      principal:                            "events.amazonaws.com"
      source_arn:                           "${aws_cloudwatch_event_rule.check_instance_ttls.arn}"
      statement_id:                         "AllowExecutionFromCloudWatch"

  + aws_lambda_permission.allow_cloudwatch_clean_untagged_instances
      id:                                   <computed>
      action:                               "lambda:InvokeFunction"
      function_name:                        "cleanUntaggedInstances"
      principal:                            "events.amazonaws.com"
      source_arn:                           "${aws_cloudwatch_event_rule.clean_untagged_instances.arn}"
      statement_id:                         "AllowExecutionFromCloudWatch"

  + aws_lambda_permission.allow_cloudwatch_instance_usage
      id:                                   <computed>
      action:                               "lambda:InvokeFunction"
      function_name:                        "notifySlackInstanceUsage"
      principal:                            "events.amazonaws.com"
      source_arn:                           "${aws_cloudwatch_event_rule.notify_slack_running_instances.arn}"
      statement_id:                         "AllowExecutionFromCloudWatch"

  + aws_lambda_permission.allow_cloudwatch_untagged_instances
      id:                                   <computed>
      action:                               "lambda:InvokeFunction"
      function_name:                        "notifySlackUntaggedInstances"
      principal:                            "events.amazonaws.com"
      source_arn:                           "${aws_cloudwatch_event_rule.notify_slack_untagged_instances.arn}"
      statement_id:                         "AllowExecutionFromCloudWatch"


Plan: 25 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_cloudwatch_event_rule.clean_untagged_instances: Creating...
  arn:                 "" => "<computed>"
  description:         "" => "Check untagged instances and stop/terminate old ones"
  is_enabled:          "" => "true"
  name:                "" => "clean_untagged_instances"
  schedule_expression: "" => "cron(0 8 * * ? *)"
aws_iam_role.lambda_notify_slack: Creating...
  arn:                   "" => "<computed>"
  assume_role_policy:    "" => "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Effect\": \"Allow\",\n      \"Action\": \"sts:AssumeRole\",\n      \"Principal\": {\n        \"Service\": \"lambda.amazonaws.com\"\n      }\n    }\n  ]\n}\n"
  create_date:           "" => "<computed>"
  force_detach_policies: "" => "false"
  name:                  "" => "lambda_notify_slack"
  path:                  "" => "/"
  unique_id:             "" => "<computed>"
aws_iam_role.lambda_stop_and_terminate_instances: Creating...
  arn:                   "" => "<computed>"
  assume_role_policy:    "" => "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Effect\": \"Allow\",\n      \"Action\": \"sts:AssumeRole\",\n      \"Principal\": {\n        \"Service\": \"lambda.amazonaws.com\"\n      }\n    }\n  ]\n}\n"
  create_date:           "" => "<computed>"
  force_detach_policies: "" => "false"
  name:                  "" => "lambda_stop_and_terminate_instances"
  path:                  "" => "/"
  unique_id:             "" => "<computed>"
aws_cloudwatch_event_rule.check_instance_ttls: Creating...
  arn:                 "" => "<computed>"
  description:         "" => "Check instance TTLs to see if they are expired"
  is_enabled:          "" => "true"
  name:                "" => "check_instance_ttls"
  schedule_expression: "" => "cron(0 8 * * ? *)"
aws_iam_role.lambda_read_instances: Creating...
  arn:                   "" => "<computed>"
  assume_role_policy:    "" => "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Effect\": \"Allow\",\n      \"Action\": \"sts:AssumeRole\",\n      \"Principal\": {\n        \"Service\": \"lambda.amazonaws.com\"\n      }\n    }\n  ]\n}\n"
  create_date:           "" => "<computed>"
  force_detach_policies: "" => "false"
  name:                  "" => "lambda_read_instances"
  path:                  "" => "/"
  unique_id:             "" => "<computed>"
aws_cloudwatch_event_rule.notify_slack_untagged_instances: Creating...
  arn:                 "" => "<computed>"
  description:         "" => "Notify users about their untagged AWS instances via Slack"
  is_enabled:          "" => "true"
  name:                "" => "notify_slack_untagged_instances"
  schedule_expression: "" => "cron(0 6 * * ? *)"
aws_cloudwatch_event_rule.notify_slack_running_instances: Creating...
  arn:                 "" => "<computed>"
  description:         "" => "Notify users about their running AWS instances via Slack"
  is_enabled:          "" => "true"
  name:                "" => "notify_slack_running_instances"
  schedule_expression: "" => "cron(0 8 * * ? *)"
aws_iam_role.lambda_notify_slack: Creation complete after 2s (ID: lambda_notify_slack)
aws_iam_role_policy.lambda_notify_slack_policy: Creating...
  name:   "" => "lambda_notify_slack_policy"
  policy: "" => "{\n    \"Version\": \"2012-10-17\",\n    \"Statement\": [\n        {\n            \"Effect\": \"Allow\",\n            \"Action\": \"logs:CreateLogGroup\",\n            \"Resource\": \"arn:aws:logs:us-west-2:867530986753:*\"\n        },\n        {\n            \"Effect\": \"Allow\",\n            \"Action\": [\n                \"logs:CreateLogStream\",\n                \"logs:PutLogEvents\"\n            ],\n            \"Resource\": [\n                \"arn:aws:logs:us-west-2:867530986753:*\"\n            ]\n        },\n        {\n            \"Effect\": \"Allow\",\n            \"Action\": \"lambda:InvokeFunction\",\n            \"Resource\": \"*\"\n        }\n    ]\n}"
  role:   "" => "lambda_notify_slack"
aws_lambda_function.notifySlackInstanceUsage: Creating...
  arn:                                  "" => "<computed>"
  description:                          "" => "Sends a notification message to slack with info about number of running instances by type."
  environment.#:                        "" => "1"
  environment.0.variables.%:            "" => "2"
  environment.0.variables.slackChannel: "" => "#aws-hc-se-demos"
  environment.0.variables.slackHookUrl: "" => "https://hooks.slack.com/services/REPLACE/WITH/YOURWEBHOOK"
  filename:                             "" => "./files/notifySlackInstanceUsage.zip"
  function_name:                        "" => "notifySlackInstanceUsage"
  handler:                              "" => "notifySlackInstanceUsage.lambda_handler"
  invoke_arn:                           "" => "<computed>"
  last_modified:                        "" => "<computed>"
  memory_size:                          "" => "128"
  publish:                              "" => "false"
  qualified_arn:                        "" => "<computed>"
  role:                                 "" => "arn:aws:iam::867530986753:role/lambda_notify_slack"
  runtime:                              "" => "python3.6"
  source_code_hash:                     "" => "Cvf18Bppw9lDmFHUJQz5ZU1t0TyZC8dIW9Sr1RCUh9c="
  timeout:                              "" => "120"
  tracing_config.#:                     "" => "<computed>"
  version:                              "" => "<computed>"
aws_lambda_function.notifySlackUntaggedInstances: Creating...
  arn:                                  "" => "<computed>"
  description:                          "" => "Sends a notification message to slack with info about untagged instances."
  environment.#:                        "" => "1"
  environment.0.variables.%:            "" => "2"
  environment.0.variables.slackChannel: "" => "#aws-hc-se-demos"
  environment.0.variables.slackHookUrl: "" => "https://hooks.slack.com/services/REPLACE/WITH/YOURWEBHOOK"
  filename:                             "" => "./files/notifySlackUntaggedInstances.zip"
  function_name:                        "" => "notifySlackUntaggedInstances"
  handler:                              "" => "notifySlackUntaggedInstances.lambda_handler"
  invoke_arn:                           "" => "<computed>"
  last_modified:                        "" => "<computed>"
  memory_size:                          "" => "128"
  publish:                              "" => "false"
  qualified_arn:                        "" => "<computed>"
  role:                                 "" => "arn:aws:iam::867530986753:role/lambda_notify_slack"
  runtime:                              "" => "python3.6"
  source_code_hash:                     "" => "7mQyGa4tF+a6Pj+5n+vHYiAuuKGNLm2FRti8/ZCb1nk="
  timeout:                              "" => "120"
  tracing_config.#:                     "" => "<computed>"
  version:                              "" => "<computed>"
aws_iam_role.lambda_stop_and_terminate_instances: Creation complete after 2s (ID: lambda_stop_and_terminate_instances)
aws_iam_role_policy.lambda_stop_and_terminate_instances: Creating...
  name:   "" => "lambda_stop_and_terminate_instances"
  policy: "" => "{\n    \"Version\": \"2012-10-17\",\n    \"Statement\": [\n        {\n            \"Effect\": \"Allow\",\n            \"Action\": \"logs:CreateLogGroup\",\n            \"Resource\": \"arn:aws:logs:us-west-2:867530986753:*\"\n        },\n        {\n            \"Effect\": \"Allow\",\n            \"Action\": [\n                \"logs:CreateLogStream\",\n                \"logs:PutLogEvents\"\n            ],\n            \"Resource\": [\n                \"arn:aws:logs:us-west-2:867530986753:*\"\n            ]\n        },\n        {\n            \"Effect\": \"Allow\",\n            \"Action\": \"lambda:InvokeFunction\",\n            \"Resource\": \"*\"\n        },\n        {\n            \"Effect\": \"Allow\",\n            \"Action\": \"ec2:*\",\n            \"Resource\": \"*\"\n        }\n    ]\n}"
  role:   "" => "lambda_stop_and_terminate_instances"
aws_iam_role.lambda_read_instances: Creation complete after 2s (ID: lambda_read_instances)
aws_lambda_function.checkInstanceTTLs: Creating...
  arn:                                  "" => "<computed>"
  description:                          "" => "Checks instance TTLs for expiration and deals with them accordingly."
  environment.#:                        "" => "1"
  environment.0.variables.%:            "" => "2"
  environment.0.variables.slackChannel: "" => "#aws-hc-se-demos"
  environment.0.variables.slackHookUrl: "" => "https://hooks.slack.com/services/REPLACE/WITH/YOURWEBHOOK"
  filename:                             "" => "./files/checkInstanceTTLs.zip"
  function_name:                        "" => "checkInstanceTTLs"
  handler:                              "" => "checkInstanceTTLs.lambda_handler"
  invoke_arn:                           "" => "<computed>"
  last_modified:                        "" => "<computed>"
  memory_size:                          "" => "128"
  publish:                              "" => "false"
  qualified_arn:                        "" => "<computed>"
  role:                                 "" => "arn:aws:iam::867530986753:role/lambda_stop_and_terminate_instances"
  runtime:                              "" => "python3.6"
  source_code_hash:                     "" => "sSzROEXCA3CwFxxvh0ja1+jLGegjec3/FLTtlHZUoVo="
  timeout:                              "" => "120"
  tracing_config.#:                     "" => "<computed>"
  version:                              "" => "<computed>"
aws_lambda_function.cleanUntaggedInstances: Creating...
  arn:                                  "" => "<computed>"
  description:                          "" => "Checks instance TTLs for expiration and deals with them accordingly."
  environment.#:                        "" => "1"
  environment.0.variables.%:            "" => "4"
  environment.0.variables.reapDays:     "" => "90"
  environment.0.variables.slackChannel: "" => "#aws-hc-se-demos"
  environment.0.variables.slackHookUrl: "" => "https://hooks.slack.com/services/REPLACE/WITH/YOURWEBHOOK"
  environment.0.variables.sleepDays:    "" => "14"
  filename:                             "" => "./files/cleanUntaggedInstances.zip"
  function_name:                        "" => "cleanUntaggedInstances"
  handler:                              "" => "cleanUntaggedInstances.lambda_handler"
  invoke_arn:                           "" => "<computed>"
  last_modified:                        "" => "<computed>"
  memory_size:                          "" => "128"
  publish:                              "" => "false"
  qualified_arn:                        "" => "<computed>"
  role:                                 "" => "arn:aws:iam::867530986753:role/lambda_stop_and_terminate_instances"
  runtime:                              "" => "python3.6"
  source_code_hash:                     "" => "UAtooFP4yd/p1/5pk1yN9yqZ9KWATkbbeZbN/GemX8A="
  timeout:                              "" => "120"
  tracing_config.#:                     "" => "<computed>"
  version:                              "" => "<computed>"
aws_cloudwatch_event_rule.notify_slack_untagged_instances: Creation complete after 2s (ID: notify_slack_untagged_instances)
aws_cloudwatch_event_rule.check_instance_ttls: Creation complete after 2s (ID: check_instance_ttls)
aws_cloudwatch_event_rule.clean_untagged_instances: Creation complete after 2s (ID: clean_untagged_instances)
aws_cloudwatch_event_rule.notify_slack_running_instances: Creation complete after 2s (ID: notify_slack_running_instances)
aws_iam_role_policy.lambda_notify_slack_policy: Creation complete after 0s (ID: lambda_notify_slack:lambda_notify_slack_policy)
aws_iam_role_policy.lambda_stop_and_terminate_instances: Creation complete after 0s (ID: lambda_stop_and_terminate_instances:lambda_stop_and_terminate_instances)
aws_iam_role_policy.lambda_read_instances_policy: Creating...
  name:   "" => "lambda_read_instances_policy"
  policy: "" => "{\n    \"Version\": \"2012-10-17\",\n    \"Statement\": [\n        {\n            \"Effect\": \"Allow\",\n            \"Action\": \"logs:CreateLogGroup\",\n            \"Resource\": \"arn:aws:logs:us-west-2:867530986753:*\"\n        },\n        {\n            \"Effect\": \"Allow\",\n            \"Action\": [\n                \"logs:CreateLogStream\",\n                \"logs:PutLogEvents\"\n            ],\n            \"Resource\": [\n                \"arn:aws:logs:us-west-2:867530986753:*\"\n            ]\n        },\n        {\n            \"Effect\": \"Allow\",\n            \"Action\": \"ec2:Describe*\",\n            \"Resource\": \"*\"\n        },\n        {\n            \"Effect\": \"Allow\",\n            \"Action\": \"elasticloadbalancing:Describe*\",\n            \"Resource\": \"*\"\n        },\n        {\n
 \"Effect\": \"Allow\",\n            \"Action\": [\n                \"cloudwatch:ListMetrics\",\n                \"cloudwatch:GetMetricStatistics\",\n                \"cloudwatch:Describe*\"\n            ],\n            \"Resource\": \"*\"\n        },\n        {\n            \"Effect\": \"Allow\",\n            \"Action\": \"autoscaling:Describe*\",\n            \"Resource\": \"*\"\n        }\n    ]\n}"
  role:   "" => "lambda_read_instances"
aws_lambda_function.getRunningInstances: Creating...
  arn:              "" => "<computed>"
  description:      "" => "Gathers a list of running instances."
  filename:         "" => "./files/getRunningInstances.zip"
  function_name:    "" => "getRunningInstances"
  handler:          "" => "getRunningInstances.lambda_handler"
  invoke_arn:       "" => "<computed>"
  last_modified:    "" => "<computed>"
  memory_size:      "" => "128"
  publish:          "" => "false"
  qualified_arn:    "" => "<computed>"
  role:             "" => "arn:aws:iam::867530986753:role/lambda_read_instances"
  runtime:          "" => "python3.6"
  source_code_hash: "" => "iUEHHBeeBnXfmJn9dUMFvrTzlmDdItZZDhIVDlsTTzM="
  timeout:          "" => "120"
  tracing_config.#: "" => "<computed>"
  version:          "" => "<computed>"
aws_lambda_function.getUntaggedInstances: Creating...
  arn:                             "" => "<computed>"
  description:                     "" => "Gathers a list of untagged or improperly tagged instances."
  environment.#:                   "" => "1"
  environment.0.variables.%:       "" => "1"
  environment.0.variables.REQTAGS: "" => "TTL,owner"
  filename:                        "" => "./files/getUntaggedInstances.zip"
  function_name:                   "" => "getUntaggedInstances"
  handler:                         "" => "getUntaggedInstances.lambda_handler"
  invoke_arn:                      "" => "<computed>"
  last_modified:                   "" => "<computed>"
  memory_size:                     "" => "128"
  publish:                         "" => "false"
  qualified_arn:                   "" => "<computed>"
  role:                            "" => "arn:aws:iam::867530986753:role/lambda_read_instances"
  runtime:                         "" => "python3.6"
  source_code_hash:                "" => "AqaC9D61lTcN+0cxJaKSvPuaSEK5/RwzIOsj5+Hug60="
  timeout:                         "" => "120"
  tracing_config.#:                "" => "<computed>"
  version:                         "" => "<computed>"
aws_lambda_function.getTaggedInstances: Creating...
  arn:                             "" => "<computed>"
  description:                     "" => "Gathers a list of correctly tagged instances."
  environment.#:                   "" => "1"
  environment.0.variables.%:       "" => "1"
  environment.0.variables.REQTAGS: "" => "TTL,owner"
  filename:                        "" => "./files/getTaggedInstances.zip"
  function_name:                   "" => "getTaggedInstances"
  handler:                         "" => "getTaggedInstances.lambda_handler"
  invoke_arn:                      "" => "<computed>"
  last_modified:                   "" => "<computed>"
  memory_size:                     "" => "128"
  publish:                         "" => "false"
  qualified_arn:                   "" => "<computed>"
  role:                            "" => "arn:aws:iam::867530986753:role/lambda_read_instances"
  runtime:                         "" => "python3.6"
  source_code_hash:                "" => "HIHlffjNm8J7bPxg88vsTPP60trn4jPy+848YfuADlc="
  timeout:                         "" => "120"
  tracing_config.#:                "" => "<computed>"
  version:                         "" => "<computed>"
aws_iam_role_policy.lambda_read_instances_policy: Creation complete after 0s (ID: lambda_read_instances:lambda_read_instances_policy)
aws_lambda_function.notifySlackUntaggedInstances: Still creating... (10s elapsed)
aws_lambda_function.notifySlackInstanceUsage: Still creating... (10s elapsed)
aws_lambda_function.checkInstanceTTLs: Still creating... (10s elapsed)
aws_lambda_function.cleanUntaggedInstances: Still creating... (10s elapsed)
aws_lambda_function.getRunningInstances: Still creating... (10s elapsed)
aws_lambda_function.getUntaggedInstances: Still creating... (10s elapsed)
aws_lambda_function.getTaggedInstances: Still creating... (10s elapsed)
aws_lambda_function.notifySlackInstanceUsage: Creation complete after 18s (ID: notifySlackInstanceUsage)
aws_cloudwatch_event_target.daily_running_report: Creating...
  arn:       "" => "arn:aws:lambda:us-west-2:867530986753:function:notifySlackInstanceUsage"
  rule:      "" => "notify_slack_running_instances"
  target_id: "" => "notifySlackInstanceUsage"
aws_lambda_permission.allow_cloudwatch_instance_usage: Creating...
  action:        "" => "lambda:InvokeFunction"
  function_name: "" => "notifySlackInstanceUsage"
  principal:     "" => "events.amazonaws.com"
  source_arn:    "" => "arn:aws:events:us-west-2:867530986753:rule/notify_slack_running_instances"
  statement_id:  "" => "AllowExecutionFromCloudWatch"
aws_lambda_permission.allow_cloudwatch_instance_usage: Creation complete after 0s (ID: AllowExecutionFromCloudWatch)
aws_cloudwatch_event_target.daily_running_report: Creation complete after 0s (ID: notify_slack_running_instances-notifySlackInstanceUsage)
aws_lambda_function.notifySlackUntaggedInstances: Creation complete after 19s (ID: notifySlackUntaggedInstances)
aws_cloudwatch_event_target.daily_untagged_report: Creating...
  arn:       "" => "arn:aws:lambda:us-west-2:867530986753:function:notifySlackUntaggedInstances"
  rule:      "" => "notify_slack_untagged_instances"
  target_id: "" => "notifySlackUntaggedInstances"
aws_lambda_permission.allow_cloudwatch_untagged_instances: Creating...
  action:        "" => "lambda:InvokeFunction"
  function_name: "" => "notifySlackUntaggedInstances"
  principal:     "" => "events.amazonaws.com"
  source_arn:    "" => "arn:aws:events:us-west-2:867530986753:rule/notify_slack_untagged_instances"
  statement_id:  "" => "AllowExecutionFromCloudWatch"
aws_lambda_permission.allow_cloudwatch_untagged_instances: Creation complete after 0s (ID: AllowExecutionFromCloudWatch)
aws_cloudwatch_event_target.daily_untagged_report: Creation complete after 1s (ID: notify_slack_untagged_instances-notifySlackUntaggedInstances)
aws_lambda_function.checkInstanceTTLs: Still creating... (20s elapsed)
aws_lambda_function.checkInstanceTTLs: Creation complete after 20s (ID: checkInstanceTTLs)
aws_lambda_permission.allow_cloudwatch_check_ttls: Creating...
  action:        "" => "lambda:InvokeFunction"
  function_name: "" => "checkInstanceTTLs"
  principal:     "" => "events.amazonaws.com"
  source_arn:    "" => "arn:aws:events:us-west-2:867530986753:rule/check_instance_ttls"
  statement_id:  "" => "AllowExecutionFromCloudWatch"
aws_cloudwatch_event_target.reaper_report: Creating...
  arn:       "" => "arn:aws:lambda:us-west-2:867530986753:function:checkInstanceTTLs"
  rule:      "" => "check_instance_ttls"
  target_id: "" => "checkInstanceTTLs"
aws_lambda_function.cleanUntaggedInstances: Still creating... (20s elapsed)
aws_lambda_function.getRunningInstances: Still creating... (20s elapsed)
aws_lambda_permission.allow_cloudwatch_check_ttls: Creation complete after 0s (ID: AllowExecutionFromCloudWatch)
aws_lambda_function.getUntaggedInstances: Still creating... (20s elapsed)
aws_lambda_function.getTaggedInstances: Still creating... (20s elapsed)
aws_cloudwatch_event_target.reaper_report: Creation complete after 1s (ID: check_instance_ttls-checkInstanceTTLs)
aws_lambda_function.cleanUntaggedInstances: Creation complete after 21s (ID: cleanUntaggedInstances)
aws_lambda_permission.allow_cloudwatch_clean_untagged_instances: Creating...
  action:        "" => "lambda:InvokeFunction"
  function_name: "" => "cleanUntaggedInstances"
  principal:     "" => "events.amazonaws.com"
  source_arn:    "" => "arn:aws:events:us-west-2:867530986753:rule/clean_untagged_instances"
  statement_id:  "" => "AllowExecutionFromCloudWatch"
aws_cloudwatch_event_target.untagged_instance_cleanup: Creating...
  arn:       "" => "arn:aws:lambda:us-west-2:867530986753:function:cleanUntaggedInstances"
  rule:      "" => "clean_untagged_instances"
  target_id: "" => "cleanUntaggedInstances"
aws_lambda_permission.allow_cloudwatch_clean_untagged_instances: Creation complete after 1s (ID: AllowExecutionFromCloudWatch)
aws_cloudwatch_event_target.untagged_instance_cleanup: Creation complete after 1s (ID: clean_untagged_instances-cleanUntaggedInstances)
aws_lambda_function.getRunningInstances: Creation complete after 22s (ID: getRunningInstances)
aws_lambda_function.getUntaggedInstances: Creation complete after 22s (ID: getUntaggedInstances)
aws_lambda_function.getTaggedInstances: Creation complete after 23s (ID: getTaggedInstances)

Apply complete! Resources: 25 added, 0 changed, 0 destroyed.
```

### Step 4: Test your Lambda functions
Now you can test your new lambda functions. Use the test button at the top of the page to ensure they are working correctly. For your test event you can simply create a dummy event with the default JSON payload:

![Configure test event](./assets/dummy_event.png)

Check your slack channel to see the messages posted from your bot.

### Step 5: Adjust Schedule
By default the reporting lambdas are set to run once per day. You can customize the schedule by adjusting the `aws_cloudwatch_event_rule` resources. The schedule follows a Unix cron-style format: `cron(0 8 * * ? *)`. The instance_reaper will be most effective if it is run every hour.

### Step 6: Go live
_IMPORTANT_: If you want to actually stop and terminate instances in a live environment, you must uncomment/edit the code inside of `cleanUntaggedInstances.py` and `checkInstanceTTLs.py`. We have commented out the lines that do these actions so you can test before going live. See below for the lines that handle `stop()` and `terminate()` actions:

```
def sleep_instance(instance_id,region):
    """Stops instances that have gone beyond their TTL"""
    # Uncomment to make this live!
    #ec2 = boto3.resource('ec2', region_name=region)
    #ec2.instances.filter(InstanceIds=instance_id).stop()
    logger.info("I would have stopped "+instance_id+" in "+region)

def terminate_instance(instance_id,region):
    """Stops instances that have gone beyond their TTL"""
    # Uncomment to make this live!
    #ec2 = boto3.resource('ec2', region_name=region)
    #ec2.instances.filter(InstanceIds=instance_id).terminate()
    logger.info("I would have terminated "+instance_id+" in "+region)
```

## Next Steps 

### Optional - Enable KMS encryption
You can optionally encrypt the Slack Webhook URL so that it cannot be viewed in plaintext in the AWS console. This also allows you to commit your webhook URL to source code without worrying about it getting into the wrong hands. This also provides some extra security if you are working with a shared AWS account. Here are the additional steps you need to follow to enable encryption:

1. Uncomment the lines in `notifySlackUntaggedInstances.py` and `notifySlackInstanceUsage.py` (or other lambdas) that enable encryption. These are the lines you'll need to uncomment. Note how we are using the b64decode Python module to decrypt the encrypted Slack Webhook:
```
# from base64 import b64decode
# ENCRYPTED_HOOK_URL = os.environ['slackHookUrl']
# HOOK_URL = boto3.client('kms').decrypt(CiphertextBlob=b64decode(os.environ['slackHookUrl']))['Plaintext'].decode('utf-8')
```
2. Rename the `encryption.tf.disabled` file to `encryption.tf`. Terraform reads any file that ends with the *.tf extension.
3. Run `terraform apply` to generate a new AWS KMS key called `notify_slack`.
4. Log onto the AWS console and switch into the region where you deployed your Lambdas. Navigate to the AWS Lambda section of the dashboard.
5. Find the `notifySlackInstanceUsage` Lambda and click on it.
6. Scroll down to the Environment Variables section. Click the little arrow to expand the Encryption configuration options.
7. Check the box under "Enable helpers for encryption in transit". This will enable a new menu that says "KMS key to encrypt in transit". From that pull-down menu select the `notify_slack` key. This is the KMS key that Terraform created in step #3.
8. Click on the `Encrypt` button next to the webhook URL. This will encrypt your webhook URL. Now click on `Save` at the top right. If you don't save here the settings won't stick.
9. Navigate back to the AWS Lambda functions and repeat steps #1-8 for any other functions where you want to configure the encrypted URL.
10. If you want to make this configuration permanent, comment out the `aws_kms_key` and `aws_kms_alias` resources in encryption.tf. Then use the `terraform state rm` command to remove both of them from your state file. The key you created will now be persistent, and allow you to save your encrypted Slack Webhook URL in your variables file.  You can fetch the encrypted URL by running `terraform show` command.

### Clean up
Cleanup is simple, just run `terraform destroy` in your workspace and all resources will be cleaned up.