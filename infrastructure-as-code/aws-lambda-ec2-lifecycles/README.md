# Terraforming EC2 lifecycles with AWS Lambda
Terraform configuration for lifecycle management of AWS instances and other resources.

## Introduction
Spending too much on your AWS instances every month?  Maybe developers create instances and forget to turn them off? Perhaps you struggle with identifying who created AWS resources? This guide is for you!

This Terraform configuration deploys AWS Lambda functions that can do the following:

 - Check for mandatory tags on AWS instances and notify via Slack if untagged instances are found.
 - Notify on how many of each instance type are currently running across all regions.
 - Shutdown untagged instances after X days. (COMING SOON)
 - Delete untagged instances after Y days. (COMING SOON)
 - Delete machines whose TTL (time to live) has expired. (COMING SOON)

## Prerequisites
1. Admin level access to your AWS account via API. If admin access is not available you must have the ability to create, describe, and delete the following types of resources in AWS. Fine-grained configuration of IAM policies is beyond the scope of this guide. We will assume you have API keys and appropriate permissions that allow you to create the following resources using Terraform:

    aws\_cloudwatch\_event\_rule  
    aws\_cloudwatch\_event\_target  
    aws\_iam\_role  
    aws\_iam\_role\_policy  
    aws\_kms\_alias  
    aws\_kms\_key  
    aws\_lambda\_function  
    aws\_lambda\_permission  

2. Properly configured workstation or server for running Terraform commands. New to Terraform? Try our [Getting Started Guide](https://www.terraform.io/intro/getting-started/install.html)

3. An [incoming webhook integration](https://api.slack.com/incoming-webhooks) in your Slack account. If you want to receive notifications about instance usage and tags you'll need to be able to create a webhook or ask your administrator to help you create one.

## Deployment steps
1. Set up your Slack incoming webhook: https://my.slack.com/services/new/incoming-webhook/. Feel free to give your new bot a unique name, icon and description. Make note of the Webhook URL. This is a specially coded URL that allows remote applications to post data into your Slack channels. Do not share this link publicly or commit it to your source code repo. Choose the channel you want your bot to post messages to.
2. Edit the variables.tf file and choose which region you want to run your Lambda functions in. These functions can be run from any region and manage instances in any other region.
3. Leave the `slack_hook_url` variable alone for now. We're going to encrypt the URL you created in step #1 in a moment.
4. Set any tags that you want to be considered mandatory in the `mandatory_tags` variable. This is a comma separated list, with no spaces between items. 
5. Save the variables.tf file and run `terraform plan`. Make sure that the command exits cleanly.
6. Run `terraform apply` to build out all the resources listed in main.tf.
7. Log onto the AWS console and switch into the region where you deployed your Lambdas. Navigate to the AWS Lambda section of the dashboard.
8. Find the notifySlackInstanceUsage Lambda and click on it.
9. Scroll down to the Environment Variables section. Click the little arrow to expand the Encryption configuration options.
10. Check the box under "Enable helpers for encryption in transit". This will enable a new menu that says "KMS key to encrypt in transit". From that pull-down menu select the `notify_slack` key. This is the KMS key that Terraform created in step #6.
11. Copy and paste your Slack Webhook URL into the slackHookUrl field, replacing the default value: `https://hooks.slack.com/services/REPLACE/WITH/YOUR/WEBHOOK`
12. Click on the `Encrypt` button next to the webhook URL. This will encrypt your webhook URL. Now click on `Save` at the top right. If you don't save here the settings won't stick.
13. Navigate back to the AWS Lambda functions list and click on notifySlackUntaggedInstances. Repeat steps #9-#12.
14. Now you can test your new lambda functions. Use the test button at the top of the page to ensure they are working correctly. For your Test Event you can simply create a dummy event with the default JSON payload.
15. Check your slack channel to see the messages posted from your bot.
16. By default these lambdas are set to run once per day. You can customize the schedule by adjusting the `aws_cloudwatch_event_rule` resources in main.tf. The schedule follows a Unix cron-style format: `cron(0 8 * * ? *)`.

## Cleanup
Cleanup is easy, simply run `terraform destroy` and all of the resources you created above will be destroyed. 

## Further steps
If you want a fully automated solution you can create a persistent KMS key that you can use for encrypting and decrypting the Slack Webhook URL. You'll need to use the UI to manually encrypt your Slack Webhook URL, but this step only needs to be done once. After you have the encrypted data you can copy it into your variables file.

Or even better, you could store this encrypted key in [HashiCorp Vault](https://www.hashicorp.com/vault)!