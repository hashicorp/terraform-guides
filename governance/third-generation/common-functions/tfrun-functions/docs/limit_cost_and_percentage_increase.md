# limit_cost_and_percentage_increase
This function validates that the proposed monthly cost from the [cost estimates](https://www.terraform.io/docs/cloud/cost-estimation/index.html) of a plan done against a workspace is less than a given limit which is given in US dollars and that the percentage increase of the monthly cost is less than a given maximum percentage.

## Sentinel Module
This function is contained in the [tfrun-functions.sentinel](../tfrun-functions.sentinel) module.

## Declaration
`limit_cost_and_percentage_increase = func(limit, max_percent)`

## Arguments
* **limit**: the upper limit on the allowed estimated monthly costs (in US dollars) for the resources provisioned in the workspace, given as a [decimal](https://docs.hashicorp.com/sentinel/imports/decimal/).
* **max_percent**: the upper limit on the percentage increase of the estimated monthly costs compared to the current monthly cost (if available), also given as a decimal.

## Common Functions Used
None

## What It Returns
This function returns `true` if the estimated monthly costs of the workspace are under `limit` and the percentage increase of those costs is less than `max_percent` or if no cost estimates were available. Otherwise, it returns `false`.

## What It Prints
This function prints messages indicating whether or not the estimated monthly costs are allowed or not. Additionally, if no cost estimates are available, it prints a message to indicate that.

## Examples
Here is an example of calling this function, assuming that the tfrun-functions.sentinel file that contains it has been imported with the alias `run`:
```
limit = decimal.new(1000)
max_percent = decimal.new(10.0)
cost_validated = run.limit_cost_and_percentage_increase(limit, max_percent)
```
Note that any policy calling this function must also import the standard decimal import with `import "decimal"`.

This function is used by the cloud agnostic policy [limit-cost-and-percentage-increase.sentinel](../../../cloud-agnostic/limit-cost-and-percentage-increase.sentinel).
