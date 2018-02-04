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
  }
}

# Template for our 'read_instances' lambda IAM policy
data "template_file" "iam_lambda_read_instances" {
  template = "${file("./files/iam_lambda_read_instances.tpl")}"

  vars {
    kmskey = "${aws_kms_key.notify_slack.arn}"
    account_id = "${data.aws_caller_identity.current.account_id}"
    region = "${var.region}"
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

# Role for our 'read_instances' lambda to assume
resource "aws_iam_role" "lambda_read_instances" {
  name = "lambda_read_instances"
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
resource "aws_iam_role_policy" "lambda_read_instances_policy" {
	name = "lambda_read_instances_policy"
	policy = "${data.template_file.iam_lambda_read_instances.rendered}"
  role = "${aws_iam_role.lambda_read_instances.id}"
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

resource "aws_lambda_function" "notifySlackInstanceUsage" {
  filename         = "./files/notifySlackInstanceUsage.zip"
  function_name    = "notifySlackInstanceUsage"
  role             = "${aws_iam_role.lambda_notify_slack.arn}"
  handler          = "notifySlackInstanceUsage.lambda_handler"
  source_code_hash = "${base64sha256(file("./files/notifySlackInstanceUsage.zip"))}"
  runtime          = "python3.6"
  timeout          = "120"
  description      = "Sends a notification message to slack with info about number of running instances by type."

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
  role             = "${aws_iam_role.lambda_read_instances.arn}"
  handler          = "getUntaggedInstances.lambda_handler"
  source_code_hash = "${base64sha256(file("./files/getUntaggedInstances.zip"))}"
  runtime          = "python3.6"
  timeout          = "120"
  description      = "Gathers a list of untagged or improperly tagged instances."

  environment {
    variables = {
      "REQTAGS" = "${var.mandatory_tags}"
    }
  }
}

resource "aws_lambda_function" "getTaggedInstances" {
  filename         = "./files/getTaggedInstances.zip"
  function_name    = "getTaggedInstances"
  role             = "${aws_iam_role.lambda_read_instances.arn}"
  handler          = "getTaggedInstances.lambda_handler"
  source_code_hash = "${base64sha256(file("./files/getTaggedInstances.zip"))}"
  runtime          = "python3.6"
  timeout          = "120"
  description      = "Gathers a list of correctly tagged instances."

  environment {
    variables = {
      "REQTAGS" = "${var.mandatory_tags}"
    }
  }
}

resource "aws_lambda_function" "getRunningInstances" {
  filename         = "./files/getRunningInstances.zip"
  function_name    = "getRunningInstances"
  role             = "${aws_iam_role.lambda_read_instances.arn}"
  handler          = "getRunningInstances.lambda_handler"
  source_code_hash = "${base64sha256(file("./files/getRunningInstances.zip"))}"
  runtime          = "python3.6"
  timeout          = "120"
  description      = "Gathers a list of running instances."

  environment {
    variables = {
      "REQTAGS" = "${var.mandatory_tags}"
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

# This resource was added due to this possible bug.  It works now.
# https://github.com/terraform-providers/terraform-provider-aws/issues/756
resource "aws_lambda_permission" "allow_cloudwatch_untagged_instances" {
  statement_id   = "AllowExecutionFromCloudWatch"
  action         = "lambda:InvokeFunction"
  function_name  = "${aws_lambda_function.notifySlackUntaggedInstances.function_name}"
  principal      = "events.amazonaws.com"
  # source_account = "${data.aws_caller_identity.current.account_id}"
  source_arn     = "${aws_cloudwatch_event_rule.notify_slack_untagged_instances.arn}"
  depends_on = [
    "aws_lambda_function.notifySlackUntaggedInstances"
  ]
}

resource "aws_cloudwatch_event_rule" "notify_slack_running_instances" {
  name = "notify_slack_running_instances"
  description = "Notify users about their running AWS instances via Slack"
  schedule_expression = "cron(0 8 * * ? *)"
}

resource "aws_cloudwatch_event_target" "daily_running_report" {
  rule      = "${aws_cloudwatch_event_rule.notify_slack_running_instances.name}"
  target_id = "${aws_lambda_function.notifySlackInstanceUsage.function_name}"
  arn = "${aws_lambda_function.notifySlackInstanceUsage.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_instance_usage" {
  statement_id   = "AllowExecutionFromCloudWatch"
  action         = "lambda:InvokeFunction"
  function_name  = "${aws_lambda_function.notifySlackInstanceUsage.function_name}"
  principal      = "events.amazonaws.com"
  # source_account = "${data.aws_caller_identity.current.account_id}"
  source_arn     = "${aws_cloudwatch_event_rule.notify_slack_running_instances.arn}"
  depends_on = [
    "aws_lambda_function.notifySlackInstanceUsage"
  ]
}