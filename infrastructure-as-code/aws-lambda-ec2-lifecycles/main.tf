# Terraform configuraiton for creating a Slack 'bot' that can notify your 
# team when it finds untagged or improperly tagged instances.

provider "aws" {                                             
  region     = "${var.region}"                                    
}

# We use this to be able to fetch our own account id and region and use them
# in our IAM policy resources.
data "aws_caller_identity" "current" {}                           

# Template for our 'notify_slack' lambda IAM policy
data "template_file" "iam_lambda_notify_slack" {
  template = "${file("./files/iam_lambda_notify_slack.tpl")}"

  vars {
    account_id = "${data.aws_caller_identity.current.account_id}"
    region = "${var.region}"
  }
}

# Template for our 'read_instances' lambda IAM policy
data "template_file" "iam_lambda_read_instances" {
  template = "${file("./files/iam_lambda_read_instances.tpl")}"

  vars {
    account_id = "${data.aws_caller_identity.current.account_id}"
    region = "${var.region}"
  }
}

# Template for our 'stop_and_terminate_instances' lambda IAM policy
data "template_file" "iam_lambda_stop_and_terminate_instances" {
  template = "${file("./files/iam_lambda_stop_and_terminate_instances.tpl")}"

  vars {
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

# Role for our 'stop_and_terminate_instances' lambda to assume
resource "aws_iam_role" "lambda_stop_and_terminate_instances" {
  name = "lambda_stop_and_terminate_instances"
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

# Here we ingest the template and create the role policy
resource "aws_iam_role_policy" "lambda_stop_and_terminate_instances" {
	name = "lambda_stop_and_terminate_instances"
	policy = "${data.template_file.iam_lambda_stop_and_terminate_instances.rendered}"
  role = "${aws_iam_role.lambda_stop_and_terminate_instances.id}"
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
      slackChannel = "${var.slack_channel}"
      slackHookUrl = "${var.slack_hook_url}"
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
      slackChannel = "${var.slack_channel}"
      slackHookUrl = "${var.slack_hook_url}"
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
}

resource "aws_lambda_function" "checkInstanceTTLs" {
  filename         = "./files/checkInstanceTTLs.zip"
  function_name    = "checkInstanceTTLs"
  role             = "${aws_iam_role.lambda_stop_and_terminate_instances.arn}"
  handler          = "checkInstanceTTLs.lambda_handler"
  source_code_hash = "${base64sha256(file("./files/checkInstanceTTLs.zip"))}"
  runtime          = "python3.6"
  timeout          = "120"
  description      = "Checks instance TTLs for expiration and deals with them accordingly."
  environment {
    variables = {
      slackChannel = "${var.slack_channel}"
      slackHookUrl = "${var.slack_hook_url}"
    }
  }
}

resource "aws_lambda_function" "cleanUntaggedInstances" {
  filename         = "./files/cleanUntaggedInstances.zip"
  function_name    = "cleanUntaggedInstances"
  role             = "${aws_iam_role.lambda_stop_and_terminate_instances.arn}"
  handler          = "cleanUntaggedInstances.lambda_handler"
  source_code_hash = "${base64sha256(file("./files/cleanUntaggedInstances.zip"))}"
  runtime          = "python3.6"
  timeout          = "120"
  description      = "Checks instance TTLs for expiration and deals with them accordingly."
  environment {
    variables = {
      slackChannel = "${var.slack_channel}"
      slackHookUrl = "${var.slack_hook_url}"
      sleepDays = "${var.sleep_days}"
      reapDays = "${var.reap_days}"
    }
  }
}

# And finally, we create a cloudwatch event rule, essentially a cron job that
# will call our lambda function every day.  Adjust to your schedule.

# Notify Slack about untagged instances (the Wall of Shame)
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

resource "aws_lambda_permission" "allow_cloudwatch_untagged_instances" {
  statement_id   = "AllowExecutionFromCloudWatch"
  action         = "lambda:InvokeFunction"
  function_name  = "${aws_lambda_function.notifySlackUntaggedInstances.function_name}"
  principal      = "events.amazonaws.com"
  source_arn     = "${aws_cloudwatch_event_rule.notify_slack_untagged_instances.arn}"
  depends_on = [
    "aws_lambda_function.notifySlackUntaggedInstances"
  ]
}

# Notify slack about how many of each instance type is currently running
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
  source_arn     = "${aws_cloudwatch_event_rule.notify_slack_running_instances.arn}"
  depends_on = [
    "aws_lambda_function.notifySlackInstanceUsage"
  ]
}

# Check TTLS, take appropriate action on expired ones. Notify slack.
resource "aws_cloudwatch_event_rule" "check_instance_ttls" {
  name = "check_instance_ttls"
  description = "Check instance TTLs to see if they are expired"
  schedule_expression = "cron(0 8 * * ? *)"
}

resource "aws_cloudwatch_event_target" "daily_reaper_report" {
  rule      = "${aws_cloudwatch_event_rule.check_instance_ttls.name}"
  target_id = "${aws_lambda_function.checkInstanceTTLs.function_name}"
  arn = "${aws_lambda_function.checkInstanceTTLs.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_check_ttls" {
  statement_id   = "AllowExecutionFromCloudWatch"
  action         = "lambda:InvokeFunction"
  function_name  = "${aws_lambda_function.checkInstanceTTLs.function_name}"
  principal      = "events.amazonaws.com"
  source_arn     = "${aws_cloudwatch_event_rule.check_instance_ttls.arn}"
  depends_on = [
    "aws_lambda_function.checkInstanceTTLs"
  ]
}

# Check TTLS, take appropriate action on expired ones. Notify slack.
resource "aws_cloudwatch_event_rule" "clean_untagged_instances" {
  name = "clean_untagged_instances"
  description = "Check untagged instances and stop/terminate old ones"
  schedule_expression = "cron(0 8 * * ? *)"
}

resource "aws_cloudwatch_event_target" "untagged_instance_cleanup" {
  rule      = "${aws_cloudwatch_event_rule.clean_untagged_instances.name}"
  target_id = "${aws_lambda_function.cleanUntaggedInstances.function_name}"
  arn = "${aws_lambda_function.cleanUntaggedInstances.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_clean_untagged_instances" {
  statement_id   = "AllowExecutionFromCloudWatch"
  action         = "lambda:InvokeFunction"
  function_name  = "${aws_lambda_function.cleanUntaggedInstances.function_name}"
  principal      = "events.amazonaws.com"
  source_arn     = "${aws_cloudwatch_event_rule.clean_untagged_instances.arn}"
  depends_on = [
    "aws_lambda_function.cleanUntaggedInstances"
  ]
}