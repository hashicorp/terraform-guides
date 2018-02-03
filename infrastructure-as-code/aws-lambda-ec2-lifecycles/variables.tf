variable "region" {
  default     = "us-west-2"
  description = "AWS Region"
}

# Unfortunately we don't have a way to auto-encrypt this (yet).  
# See here for details: https://github.com/hashicorp/terraform/issues/12225
variable "slack_hook_url" {
  #default = "https://hooks.slack.com/services/REPLACE/WITH/YOUR/WEBHOOK"
  default = "AQICAHiRUoAhWhaHkfqa38jo4jGLH7pq88YLbrpuA92B3MBd3gFcZUwDysCjH8f5TbsDNa5hAAAArzCBrAYJKoZIhvcNAQcGoIGeMIGbAgEAMIGVBgkqhkiG9w0BBwEwHgYJYIZIAWUDBAEuMBEEDMY2vqQS5XdvYQ1W6AIBEIBoedeF34vA8LOW7Rm9CJxM/2pZ1Xv1MoqTV81rJtpqph/XJbvoDKDCSGJ+iSrsTSVl8BGYoZZNgIycIE56NjAa4WMA3GRe5c1wW6RlsRfGsM/8uqC4BF0d3tvp8D2dyh6k1GgjtGUzYyk="
  description = "Slack incoming webhook URL, get this from the slack management page."
}

variable "mandatory_tags" {
  default = "TTL,owner"
  description = "Comma separated string mandatory tag values."
}