# Sentinel Policies for Azure
The sample Sentinel policy files in this directory can be used with Terraform Enterprise to ensure that provisioned Azure security groups, VMs, and ACS clusters comply with your organization's provisioning rules.

The restrict-current-azure-vms.sentinel policy is interesting because it actually checks VMs that have already been provisioned using the tfstate import and because it only prints the VMs that are not from an allowed publisher. It achieves the latter by using double negation (two nots) and "any" instead of "all".  (For those familiar with logic, we are using one of De Morgan's laws: `not(P or Q) <-> (not P) and (not Q)`.)
