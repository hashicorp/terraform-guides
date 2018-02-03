# Terraform configuraiton for creating a Slack 'bot' that can notify your 
# team when it finds untagged or improperly tagged instances.

provider "aws" {                                             
  region     = "${var.region}"                                    
}

# We use this to be able to fetch our own account id and region and use them
# in our IAM policy resources.
data "aws_caller_identity" "current" {}                           

# This key is used to encrypt the slack webhook URL
resource "aws_kms_key" "notify_slack" {
    description = "Key for encrypting the Slack webhook URL"
    enable_key_rotation = "false"
    is_enabled = "true"
}

# A human friendly alias so we can find it in the UI
resource "aws_kms_alias" "notify_slack" {
  name          = "alias/notify_slack"
  target_key_id = "${aws_kms_key.notify_slack.key_id}"
}

# Template for our 'notify_slack' lambda IAM policy
data "template_file" "iam_lambda_notify_slack" {
  template = "${file("./files/iam_lambda_notify_slack.tpl")}"

  vars {
    kmskey = "${aws_kms_key.notify_slack.arn}"
    account_id = "${data.aws_caller_identity.current.account_id}"
    region = "${var.region}"
    log_group = "${aws_cloudwatch_log_group.get_untagged_instances.name}"
  }
}

# Template for our 'get_untagged' lambda IAM policy
data "template_file" "iam_lambda_get_untagged_instances" {
  template = "${file("./files/iam_lambda_get_untagged_instances.tpl")}"

  vars {
    kmskey = "${aws_kms_key.notify_slack.arn}"
    account_id = "${data.aws_caller_identity.current.account_id}"
    region = "${var.region}"
    log_group = "${aws_cloudwatch_log_group.notify_slack.name}"
  }
}

# Role for our 'notify_slack' lambda to assume
resource "aws_iam_role" "lambda_notify_slack" {
  name = "lambda_notify_slack"
	assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
}
EOF
}

# Role for our 'get_untagged_instances' lambda to assume
resource "aws_iam_role" "lambda_get_untagged_instances" {
  name = "lambda_get_untagged_instances"
	assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
}
EOF
}

# Here we ingest the template and create the role policy
resource "aws_iam_role_policy" "lambda_notify_slack_policy" {
	name = "lambda_notify_slack_policy"
	policy = "${data.template_file.iam_lambda_notify_slack.rendered}"
  role = "${aws_iam_role.lambda_notify_slack.id}"
}

# Here we ingest the template and create the role policy
resource "aws_iam_role_policy" "lambda_get_untagged_instances_policy" {
	name = "lambda_get_untagged_instances_policy"
	policy = "${data.template_file.iam_lambda_get_untagged_instances.rendered}"
  role = "${aws_iam_role.lambda_get_untagged_instances.id}"
}

# A cloudwatch log group to store logs
resource "aws_cloudwatch_log_group" "notify_slack" {
  name = "/aws/lambda/notify_slack"
  retention_in_days = 30
  tags {
    Name = "notify_slack"
  }
}

# A cloudwatch log group to store logs
resource "aws_cloudwatch_log_group" "get_untagged_instances" {
  name = "/aws/lambda/get_untagged_instances"
  retention_in_days = 30
  tags {
    Name = "get_untagged_instances"
  }
}

# Finally we get to create the lambda functions themselves.  Source code
# is stored in a zip file with all of the *.py files and libraries in it.
resource "aws_lambda_function" "notifySlackUntaggedInstances" {
  filename         = "./files/notifySlackUntaggedInstances.zip"
  function_name    = "notifySlackUntaggedInstances"
  role             = "${aws_iam_role.lambda_notify_slack.arn}"
  handler          = "notifySlackUntaggedInstances.lambda_handler"
  source_code_hash = "${base64sha256(file("./files/notifySlackUntaggedInstances.zip"))}"
  runtime          = "python3.6"
  timeout          = "120"
  description      = "Sends a notification message to slack with info about untagged instances."

  environment {
    variables = {
      slackChannel = "#aws-hc-se-demos"
      kmsEncryptedHookUrl = "${var.slack_hook_url}"
    }
  }
}

resource "aws_lambda_function" "getUntaggedInstances" {
  filename         = "./files/getUntaggedInstances.zip"
  function_name    = "getUntaggedInstances"
  role             = "${aws_iam_role.lambda_get_untagged_instances.arn}"
  handler          = "getUntaggedInstances.lambda_handler"
  source_code_hash = "${base64sha256(file("./files/getUntaggedInstances.zip"))}"
  runtime          = "python3.6"
  timeout          = "120"
  description      = "Gathers a list of untagged or improperly tagged instances."

  environment {
    variables = {
      "REQTAGS" = "TTL,owner"
    }
  }
}

# And finally, we create a cloudwatch event rule, essentially a cron job that
# will call our lambda function every day.  Adjust to your schedule.
resource "aws_cloudwatch_event_rule" "notify_slack_untagged_instances" {
  name = "notify_slack_untagged_instances"
  description = "Notify users about their untagged AWS instances via Slack"
  schedule_expression = "cron(0 6 * * ? *)"
}

resource "aws_cloudwatch_event_target" "daily_untagged_report" {
  rule      = "${aws_cloudwatch_event_rule.notify_slack_untagged_instances.name}"
  target_id = "${aws_lambda_function.notifySlackUntaggedInstances.function_name}"
  arn = "${aws_lambda_function.notifySlackUntaggedInstances.arn}"
}