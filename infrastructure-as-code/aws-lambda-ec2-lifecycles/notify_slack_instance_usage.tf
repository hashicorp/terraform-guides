# Notify slack about the # of each instance type you have running.
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

# Here we create a cloudwatch event rule, essentially a cron job that
# will call our lambda function every day.  Adjust to your schedule.
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
