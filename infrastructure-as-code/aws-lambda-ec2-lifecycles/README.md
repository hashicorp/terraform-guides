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

1. Set up your Slack incoming webhook: https://my.slack.com/services/new/incoming-webhook/. Feel free to give your new bot a unique name, icon and description. Make note of the Webhook URL. This is a specially coded URL that allows remote applications to post data into your Slack channels. Do not share this link publicly or commit it to your source code repo. Choose the channel you want your bot to post messages to.

![Slack Webhook Config Page](./assets/aws_bot.png)

2. Edit the `variables.tf` file and choose which region you want to run your Lambda functions in. These functions can be run from any region and manage instances in any other region.

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

3. Set the `slack_hook_url` variable to the URL you generated in step #1.
4. Set any tags that you want to be considered mandatory in the `mandatory_tags` variable. This is a comma separated list, with no spaces between items.
5. Set the `reap_days` and `sleep_days` to your liking. These represent the number of days after launch that an untagged instance will be stopped and terminated respectively.
6. Save the `variables.tf` file and run `terraform plan`. Make sure that the command exits cleanly.
7. Run `terraform apply` to build out all the resources listed in `main.tf`.
8. Now you can test your new lambda functions. Use the test button at the top of the page to ensure they are working correctly. For your test event you can simply create a dummy event with the default JSON payload.

![Configure test event](./assets/dummy_event.png)

9. Check your slack channel to see the messages posted from your bot.
10. By default the reporting lambdas are set to run once per day. You can customize the schedule by adjusting the `aws_cloudwatch_event_rule` resources. The schedule follows a Unix cron-style format: `cron(0 8 * * ? *)`. The instance_reaper will be most effective if it is run every hour.
11. IMPORTANT: If you want to actually stop and terminate instances in a live environment, you must uncomment/edit the code inside of `cleanUntaggedInstances.py` and `checkInstanceTTLs.py`. We have commented out the lines that do these actions so you can test before going live. See below for the lines that handle stop() and terminate() actions:

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