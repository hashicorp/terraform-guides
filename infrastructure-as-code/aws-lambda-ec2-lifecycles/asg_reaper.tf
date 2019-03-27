# Checks the TTL of your instances, if expired can stop or terminate them.                         
resource "aws_lambda_function" "checkASGTTLs" {
  filename         = "./files/checkASGTTLs.zip"
  function_name    = "checkASGTTLs"
  role             = "${aws_iam_role.lambda_terminate_asgs.arn}"
  handler          = "checkASGTTLs.lambda_handler"
  source_code_hash = "${base64sha256(file("./files/checkASGTTLs.zip"))}"
  runtime          = "python3.6"
  timeout          = "120"
  description      = "Checks ASG TTLs for expiration and deals with them accordingly."
  environment {
    variables = {
      slackChannel = "${var.slack_channel}"
      slackHookUrl = "${var.slack_hook_url}"
      isActive = "${var.is_active}"
      asgReapDays = "${var.asg_reap_days}"
    }
  }
}

# Here we create a cloudwatch event rule, essentially a cron job that
# will call our lambda function every hour.  Adjust to your schedule.
resource "aws_cloudwatch_event_rule" "check_asg_ttls" {
  name = "check_asg_ttls"
  description = "Check ASG TTLs to see if they are expired"
  schedule_expression = "cron(0 * * * ? *)"
}

resource "aws_cloudwatch_event_target" "asg_reaper_report" {
  rule      = "${aws_cloudwatch_event_rule.check_asg_ttls.name}"
  target_id = "${aws_lambda_function.checkASGTTLs.function_name}"
  arn = "${aws_lambda_function.checkASGTTLs.arn}"
}

resource "aws_lambda_permission" "asg_allow_cloudwatch_check_ttls" {
  statement_id   = "AllowExecutionFromCloudWatch"
  action         = "lambda:InvokeFunction"
  function_name  = "${aws_lambda_function.checkASGTTLs.function_name}"
  principal      = "events.amazonaws.com"
  source_arn     = "${aws_cloudwatch_event_rule.check_asg_ttls.arn}"
  depends_on = [
    "aws_lambda_function.checkASGTTLs"
  ]
}