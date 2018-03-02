# Checks the TTL of your instances, if expired can stop or terminate them.                         
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
      isActive = "${var.is_active}"
    }
  }
}

# Here we create a cloudwatch event rule, essentially a cron job that
# will call our lambda function every hour.  Adjust to your schedule.
resource "aws_cloudwatch_event_rule" "check_instance_ttls" {
  name = "check_instance_ttls"
  description = "Check instance TTLs to see if they are expired"
  schedule_expression = "cron(0 * * * ? *)"
}

resource "aws_cloudwatch_event_target" "reaper_report" {
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