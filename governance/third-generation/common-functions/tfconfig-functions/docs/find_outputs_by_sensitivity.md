# find_outputs_by_sensitivity
This function finds all outputs of a specific sensitivity (`true` or `false`) in the Terraform configuration of the current plan's workspace using the [tfconfig/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html) import.

## Sentinel Module
This function is contained in the [tfconfig-functions.sentinel](../../tfconfig-functions.sentinel) module.

## Declaration
`find_outputs_by_sensitivity = func(sensitive)`

## Arguments
* **sensitive**: the desired sensitivity of outputs which can be `true` or `false` (without quotes).

## Common Functions Used
None

## What It Returns
This function returns a single flat map of outputs indexed by the address of the module and the name of the output. The map is actually a filtered sub-collection of the [`tfconfig.outputs`](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html#the-outputs-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfconfig-functions.sentinel file that contains it has been imported with the alias `config`:
```
sensitiveOutputs = config.find_outputs_by_sensitivity(true)

nonSensitiveOutputs = config.find_outputs_by_sensitivity(false)
```
