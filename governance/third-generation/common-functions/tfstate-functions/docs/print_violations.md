# print_violations
This function prints the violation messages that were previously returned by one of the filter functions of the tfstate-functions.sentinel module. While those filter functions can print the violations messages themselves (if their `prtmsg` parameter is set to `true`), it is sometimes preferable to delay printing of the messages until later in the policy, typically after printing one or more messages giving the address of the resource that violated it.

## Sentinel Module
This function is contained in the [tfstate-functions.sentinel](../tfstate-functions.sentinel) module.

## Declaration
`print_violations = func(messages, prefix)`

## Arguments
* **messages**: a map of messages returned by one of the filter functions.
* **prefix**: a string that should be printed before each message.

## Common Functions Used
None

## What It Returns
This function always returns `true`.

## What It Prints
This function prints the messages in the `messages` map prefixed with the `prefix` string.

## Examples
Here are some examples of calling this function, assuming that the tfstate-functions.sentinel file that contains it has been imported with the alias `state`:
```
if length(violatingIRs["messages"]) > 0 {
  violatingSGsCount += 1
  print("SG Ingress Violation:", address, "has at least one ingress rule",
        "with forbidden cidr blocks")
  state.print_violations(violatingIRs["messages"], "Ingress Rule")
}

if length(violatingDisks["messages"]) > 0 {
  disksValidated = false
  print(address, "has at least one disk with size greater than", maxDiskSize)
  state.print_violations(violatingDisks["messages"], "Disk")
}
```
