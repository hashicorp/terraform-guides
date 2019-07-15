terraform {
  required_version = ">= 0.12.0"
}

variable "names" {
  description = "list of names"
  default = ["Peter", "Paul", "Mary"]
}

variable "voter" {
  description = "name of voter"
  default = "Roger"
}

variable "candidate" {
  description = "name of candidate voter is voting for"
  default = "Dan McCready"
}

data "template_file" "actual_vote" {
  template = file("actual_vote.txt")

  vars = {
    voter = var.voter
    candidate = var.candidate
  }
}

# This works with Template Provider 2.0
data "template_file" "rigged_vote" {
  template = file("rigged_vote.txt")

  vars = {
    voter = var.voter
    candidate = var.candidate
  }
}

# Note that the blank line is intentional
# so that first name goes on its own line
# Also note use of ~ to suppress newlines
output all_names {
  value = <<EOT

%{ for name in var.names ~}
${name}
%{ endfor ~}
EOT
}

# No blank line this time
# since we want Mary's name output on same line
# as "just_mary ="
output "just_mary" {
  value = <<EOT
%{ for name in var.names ~}
%{ if name == "Mary" }${name}%{ endif ~}
%{ endfor ~}
EOT
}

# This gives the rendered actual_vote.txt
output "actual_vote" {
  value = data.template_file.actual_vote.rendered
}

# This gives the rendered rigged_vote.txt
output "rigged_vote" {
  value = data.template_file.rigged_vote.rendered
}
