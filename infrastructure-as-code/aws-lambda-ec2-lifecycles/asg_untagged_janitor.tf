# This lambda is intended to deal with untagged Auto Scaling Groups.
resource "aws_lambda_function" "ASGJanitor" {
  filename         = "./files/ASGJanitor.zip"
  function_name    = "ASGJanitor"
  role             = "${aws_iam_role.lambda_terminate_asgs.arn}"
  handler          = "ASGJanitor.lambda_handler"
  source_code_hash = "${base64sha256(file("./files/ASGJanitor.zip"))}"
  runtime          = "python3.6"
  timeout          = "120"
  description      = "Terminates untagged ASGs after a pre-set number of days."
  environment {
    variables = {
      slackChannel = "${var.slack_channel}"
      slackHookUrl = "${var.slack_hook_url}"
      asgReapDays = "${var.asg_reap_days}"
      isActive = "${var.is_active}"
    }
  }
}

# Here we create a cloudwatch event rule, essentially a cron job that
# will call our lambda function every day.  Adjust to your schedule.
resource "aws_cloudwatch_event_rule" "clean_untagged_asgs" {
  name = "clean_untagged_asgs"
  description = "Check untagged asgs and delete old ones"
  schedule_expression = "cron(0 8 * * ? *)"
}

resource "aws_cloudwatch_event_target" "untagged_asg_cleanup" {
  rule      = "${aws_cloudwatch_event_rule.clean_untagged_asgs.name}"
  target_id = "${aws_lambda_function.ASGJanitor.function_name}"
  arn = "${aws_lambda_function.ASGJanitor.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_clean_untagged_asgs" {
  statement_id   = "AllowExecutionFromCloudWatch"
  action         = "lambda:InvokeFunction"
  function_name  = "${aws_lambda_function.ASGJanitor.function_name}"
  principal      = "events.amazonaws.com"
  source_arn     = "${aws_cloudwatch_event_rule.clean_untagged_asgs.arn}"
  depends_on = [
    "aws_lambda_function.ASGJanitor"
  ]
}