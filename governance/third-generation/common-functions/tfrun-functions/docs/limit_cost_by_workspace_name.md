# limit_cost_by_workspace_name
This function validates that the proposed monthly cost from the [cost estimates](https://www.terraform.io/docs/cloud/cost-estimation/index.html) of a plan done against a workspace is less than a given limit (given in US dollars). The limit is determined from a map that associates workspace names with different limits using regex matching.

The idea is that you might set different limits for Dev, QA, and Production workspaces.

## Sentinel Module
This function is contained in the [tfrun-functions.sentinel](../tfrun-functions.sentinel) module.

## Declaration
`limit_cost_by_workspace_name = func(limits)`

## Arguments
* **limits**: a map associating strings (the keys of the map) with different upper limits (the values of the map) for the allowed estimated monthly costs (in US dollars) for the resources provisioned in the workspace. The strings are treated as workspace name prefixes and suffixes. In other words, the limit associated with the string "dev" will be applied to workspaces whose names start with "dev-" or end with "-dev". The limits assigned to each string in the map must be given as [decimals](https://docs.hashicorp.com/sentinel/imports/decimal/). Of course, you must coordinate the naming of your workspaces with the keys of the `limits` map.

## Common Functions Used
None

## What It Returns
This function returns `true` if the estimated monthly cost of the workspace is under the limit in the `limits` map that corresponds to the workspace name or if no cost estimates were available. Otherwise, it returns `false`. Note that if a workspace name does not match any of the keys in the `limits` map, the function will return `false` and probably cause the policy that called it to fail.

## What It Prints
This function prints messages indicating whether or not the estimated monthly costs are under the limit in the `limits` map that corresponds to the workspace name. Additionally, if no cost estimates are available or if the `limits` map does not contain a key that matches the workspace name, it prints a message to indicate that.

## Examples
Here is an example of calling this function, assuming that the tfrun-functions.sentinel file that contains it has been imported with the alias `run`:
```
limits = {
  "dev": decimal.new(200),
  "qa": decimal.new(500),
  "prod": decimal.new(1000),
}
cost_validated = run.limit_cost_by_workspace_name(limits)
```
Note that any policy calling this function must also import the standard decimal import with `import "decimal"`.

This function is used by the cloud agnostic policy [limit-cost-by-workspace-name.sentinel](../../../cloud-agnostic/limit-cost-by-workspace-name.sentinel).
