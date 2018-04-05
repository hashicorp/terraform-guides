# IAM roles to allow Lambda functions to access different AWS resources.

# Fetch our own account id and region. Used in our IAM policy templates.
data "aws_caller_identity" "current" {}

# Template for our 'notify' lambda IAM policy
data "template_file" "iam_lambda_notify" {
  template = "${file("./files/iam_lambda_notify.tpl")}"

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

# Role for our 'notify' lambda to assume
# This role is allowed to use the data collector lambda functions.
resource "aws_iam_role" "lambda_notify" {
  name = "lambda_notify"
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
# Used by data collectors to gather ec2 instance data.
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

# Role for our 'stop_and_terminate_instances' lambda to assume.
# This is used by lambdas that manage instance lifecycles.
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

# Here we ingest the template and create the role policies
resource "aws_iam_role_policy" "lambda_notify_policy" {
	name = "lambda_notify_policy"
	policy = "${data.template_file.iam_lambda_notify.rendered}"
  role = "${aws_iam_role.lambda_notify.id}"
}

resource "aws_iam_role_policy" "lambda_read_instances_policy" {
	name = "lambda_read_instances_policy"
	policy = "${data.template_file.iam_lambda_read_instances.rendered}"
  role = "${aws_iam_role.lambda_read_instances.id}"
}

resource "aws_iam_role_policy" "lambda_stop_and_terminate_instances" {
	name = "lambda_stop_and_terminate_instances"
	policy = "${data.template_file.iam_lambda_stop_and_terminate_instances.rendered}"
  role = "${aws_iam_role.lambda_stop_and_terminate_instances.id}"
}