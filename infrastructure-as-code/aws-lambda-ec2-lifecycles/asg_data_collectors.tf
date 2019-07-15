# These lambda functions return dictionaries of instances. 
# Use them with other functions to take action on tagged, untagged
# or running instances.

resource "aws_lambda_function" "getUntaggedASGs" {
  filename         = "./files/getUntaggedASGs.zip"
  function_name    = "getUntaggedASGs"
  role             = "${aws_iam_role.lambda_read_instances.arn}"
  handler          = "getUntaggedASGs.lambda_handler"
  source_code_hash = "${base64sha256(file("./files/getUntaggedASGs.zip"))}"
  runtime          = "python3.6"
  timeout          = "120"
  description      = "Gathers a list of untagged or improperly tagged instances."

  environment {
    variables = {
      "REQTAGS" = "${var.mandatory_tags}"
    }
  }
}

resource "aws_lambda_function" "getTaggedASGs" {
  filename         = "./files/getTaggedASGs.zip"
  function_name    = "getTaggedASGs"
  role             = "${aws_iam_role.lambda_read_instances.arn}"
  handler          = "getTaggedASGs.lambda_handler"
  source_code_hash = "${base64sha256(file("./files/getTaggedASGs.zip"))}"
  runtime          = "python3.6"
  timeout          = "120"
  description      = "Gathers a list of correctly tagged instances."

  environment {
    variables = {
      "REQTAGS" = "${var.mandatory_tags}"
    }
  }
}