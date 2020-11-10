# filter_attribute_matches_regex
This function filters a collection of items such as resources, data sources, or blocks to those with an attribute that matches a given regular expression (regex). A policy would call it when it wants the attribute to not match that regex. The attribute must either be a top-level attribute or an attribute directly under "config".

It uses the Sentinel [matches](https://docs.hashicorp.com/sentinel/language/spec/#matches-operator) operator which uses [RE2](https://github.com/google/re2/wiki/Syntax) regex.

## Sentinel Module
This function is contained in the [tfconfig-functions.sentinel](../tfconfig-functions.sentinel) module.

## Declaration
`filter_attribute_matches_regex = func(items, attr, expr, prtmsg)`

## Arguments
* **items**: a map of items such as providers, provisioners, resources, data sources, variables, outputs, or module calls.
* **attr**: the name of a top-level attribute or an attribute directly under "config". In the fist case, give the attribute as a string. In the second case, give it as "config.x" where "x" is the attribute you're trying to restrict.
* **expr**: the regex expression that should be matched. Note that any occurrences of `\` need to be escaped with `\` itself since Sentinel allows certain special characters to be escaped with `\`. For example, if you did not want to match sub-domains of ".acme.com", you would set `expr` to `(.+)\\.acme\\.com$` instead of the more usual `(.+)\.acme\.com$`. If you want to match null, set expr to "null".
* **prtmsg**: a boolean indicating whether violation messages should be printed (if `true`) or not (if `false`).

## Common Functions Used
This function calls the [evaluate_attribute](./evaluate_attribute.md) and the [to_string](./to_string.md) functions.

## What It Returns
This function returns a map with two maps, `items` and `messages`, both of which are indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the items that meet the condition of the filter function. The `items` map contains the actual resources for which the attribute (`attr`) matches the given regex, `expr`, while the `messages` map contains the violation messages associated with those instances.

## What It Prints
This function prints the violation messages if the parameter, `prtmsg`, was set to `true`. Otherwise, it does not print anything.

## Examples
Here is an example of calling this function, assuming that the tfconfig-functions.sentinel file that contains it has been imported with the alias `config`:
```
violatingEC2Instances = config.filter_attribute_matches_regex(allEC2Instances,
                        "config.ami", "^data\\.aws_ami\\.(.*)$", true)
```
