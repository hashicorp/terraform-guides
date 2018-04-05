# Notify about untagged instances and their key names.                           
resource "aws_lambda_function" "notifyUntaggedInstances" {
  filename         = "./files/notifyUntaggedInstances.zip"
  function_name    = "notifyUntaggedInstances"
  role             = "${aws_iam_role.lambda_notify.arn}"
  handler          = "notifyUntaggedInstances.lambda_handler"
  source_code_hash = "${base64sha256(file("./files/notifyUntaggedInstances.zip"))}"
  runtime          = "python3.6"
  timeout          = "120"
  description      = "Sends a notification message with info about untagged instances."

  environment {
    variables = {
      slackChannel = "${var.slack_channel}"
      slackHookUrl = "${var.slack_hook_url}"
    }
  }
}

# Here we create a cloudwatch event rule, essentially a cron job that
# will call our lambda function every day.  Adjust to your schedule.
resource "aws_cloudwatch_event_rule" "notify_untagged_instances" {
  name = "notify_untagged_instances"
  description = "Notify users about their untagged AWS instances"
  schedule_expression = "cron(0 6 * * ? *)"
}

resource "aws_cloudwatch_event_target" "daily_untagged_report" {
  rule      = "${aws_cloudwatch_event_rule.notify_untagged_instances.name}"
  target_id = "${aws_lambda_function.notifyUntaggedInstances.function_name}"
  arn = "${aws_lambda_function.notifyUntaggedInstances.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_untagged_instances" {
  statement_id   = "AllowExecutionFromCloudWatch"
  action         = "lambda:InvokeFunction"
  function_name  = "${aws_lambda_function.notifyUntaggedInstances.function_name}"
  principal      = "events.amazonaws.com"
  source_arn     = "${aws_cloudwatch_event_rule.notify_untagged_instances.arn}"
  depends_on = [
    "aws_lambda_function.notifyUntaggedInstances"
  ]
}