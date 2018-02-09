variable "region" {
  default     = "us-west-2"
  description = "AWS Region"
}

# Set your Slack Webhook URL here.  For extra security you can use AWS KMS to 
# encrypt this data in the AWS console.
variable "slack_hook_url" {
  default = "https://hooks.slack.com/services/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"
  description = "Slack incoming webhook URL, get this from the slack management page."
}

variable "mandatory_tags" {
  default = "TTL,owner"
  description = "Comma separated string mandatory tag values."
}