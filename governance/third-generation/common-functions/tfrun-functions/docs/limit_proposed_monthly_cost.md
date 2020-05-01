# limit_proposed_monthly_cost
This function validates that the proposed monthly cost from the [cost estimates](https://www.terraform.io/docs/cloud/cost-estimation/index.html) of a plan done against a workspace is less than a given limit which is given in US dollars.

## Sentinel Module
This function is contained in the [tfrun-functions.sentinel](../tfrun-functions.sentinel) module.

## Declaration
`limit_proposed_monthly_cost = func(limit)`

## Arguments
* **limit**: the upper limit on the allowed estimated monthly cost (in US dollars) for the resources provisioned in the workspace, given as a [decimal](https://docs.hashicorp.com/sentinel/imports/decimal/).

## Common Functions Used
None

## What It Returns
This function returns `true` if the estimated monthly cost of the workspace is less than or equal to `limit` or if no cost estimates were available. Otherwise, it returns `false`.

## What It Prints
This function prints messages indicating whether or not the estimated monthly cost is less than or equal to the limit. Additionally, if no cost estimates are available, it prints a message to indicate that.

## Examples
Here is an example of calling this function, assuming that the tfrun-functions.sentinel file that contains it has been imported with the alias `run`:
```
limit = decimal.new(1000)
cost_validated = run.limit_proposed_monthly_cost(limit)
```
Note that any policy calling this function must also import the standard decimal import with `import "decimal"`.

This function is used by the cloud agnostic policy [limit-proposed-monthly-cost.sentinel](../../../cloud-agnostic/limit-proposed-monthly-cost.sentinel).
