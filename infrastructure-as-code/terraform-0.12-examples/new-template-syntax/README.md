# New Template Syntax Example
This example illustrates how the new [Template Syntax](https://www.hashicorp.com/blog/terraform-0-12-template-syntax) can be used to support **if** conditionals and **for** expressions inside `%{}` template strings which are also referred to as directives.

The new template syntax can be used inside Terraform code just like the older `${}` interpolations. It can also be used inside template files loaded with the template_file data source provided that you use version 2.0 or higher of the Template Provider.

The code in main.tf creates a variable called names with a list of 3 names and uses the code below to show all of them on their own rows in an output called all_names:
```
output all_names {
  value = <<EOT

%{ for name in var.names ~}
${name}
%{ endfor ~}
EOT
}
```

Note the use of `%{ for name in var.names ~}` to iterate through the names in the names variable, the injection of each name with `${name}`, and the end of the for loop with `%{ endfor ~}`.

The strip markers (`~`) in this example prevent excessive newlines and other whitespaces from being output. We include a blank line before the new template to make sure the first name appears on a new line.

Note that we don't do either of the following which you might have expected:
```
%{ for name in var.names
name
endfor ~}
EOT
}
```
or
```
%{ for name in var.names ~}
%{ name }
%{ endfor ~}
```

Here is a second example, in which we just output one of the 3 names:
```
output "just_mary" {
  value = <<EOT
%{ for name in var.names ~}
%{ if name == "Mary" }${name}%{ endif ~}
%{ endfor ~}
EOT
}
```

As mentioned above, you can also use the new template syntax inside template files if you use version 2.0 or newer of the Template Provider.

We include two templates here:
1. actual_vote.txt that uses the old template syntax with expressions like `${voter}` and `${candidate}`
1. rigged_vote.txt that uses the new template syntax `%{ if candidate == "Dan McCready" }Mark Harris%{ else }${candidate}%{ endif }`.

In the latter, a vote for "Dan McCready" is awarded to "Mark Harris". Votes for other candidates are processed as voted.

For more on the new string templates, see [String Templates](https://www.terraform.io/docs/configuration/expressions.html#string-templates).
