# print_violations
This function prints the violation messages that were previously returned by one of the filter functions of the tfconfig-functions.sentinel module. While those filter functions can print the violations messages themselves (if their `prtmsg` parameter is set to `true`), it is sometimes preferable to delay printing of the messages until later in the policy, typically after printing one or more messages giving the address of the resource that violated it.

## Sentinel Module
This function is contained in the [tfconfig-functions.sentinel](../../tfconfig-functions.sentinel) module.

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
Here are some examples of calling this function, assuming that the tfconfig-functions.sentinel file that contains it has been imported with the alias `config`:
```
config.print_violations(violatingDatasources["messages"], "Blacklisted data source:")

config.print_violations(violatingProviders["messages"], "Blacklisted provider:")
```

This function is used by many of the cloud agnostic policies including [prohibited-datasources.sentinel](../../../cloud-agnostic/prohibited-datasources.sentinel) and [prohibited-providers.sentinel](../../../cloud-agnostic/prohibited-providers.sentinel).
