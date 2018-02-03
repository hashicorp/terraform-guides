variable "region" {
  default     = "us-west-2"
  description = "AWS Region"
}

# Unfortunately we don't have a way to auto-encrypt this (yet).  
# See here for details: https://github.com/hashicorp/terraform/issues/12225
# So we have to do one manual step to encrypt the URL in the GUI.
variable "slack_hook_url" {
  default = "https://hooks.slack.com/services/REPLACE/WITH/YOUR/WEBHOOK"
  description = "Slack incoming webhook URL, get this from the slack management page."
}

variable "mandatory_tags" {
  default = "TTL,owner"
  description = "Comma separated string mandatory tag values."
}