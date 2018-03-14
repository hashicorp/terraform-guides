{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                        "logs:CreateLogGroup",
                        "logs:CreateLogStream",
                        "logs:PutLogEvents"
                      ],
            "Resource": "arn:aws:logs:${region}:${account_id}:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "lambda:InvokeFunction",
                "ses:SendEmail",
                "ses:SendRawEmail"
            ],
            "Resource": "*"
        }
    ]
}