terraform {
  required_version = ">= 0.12.0"
}

# List of letters
variable "letters" {
  description = "a list of letters"
  default = ["a", "b", "c"]
}

# Convert letters to upper-case as list
output "upper-case-list" {
  value = [for l in var.letters: upper(l)]
}

# Convert letters to upper-case as map
output "upper-case-map" {
  value = {for l in var.letters: l => upper(l)}
}
