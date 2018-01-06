# Example For Using the Azure Compute Module
This Terraform configuration provides an example for using the [Azure compute module](https://registry.terraform.io/modules/Azure/compute/azurerm/1.1.0) from the public Terraform Registry. It is configured for use with Terraform Enterprise (TFE).

## Introduction
This Terraform configuration will create an Azure resource group, virtual network (with subnets), security groups, and a Windows VM. It will also create disks, network interfaces, and Azure availability sets for the VM.

## Instructions
You can use the original GitHub repository, rberlind/azure-modules-test or create a fork of it. You do not actually need to clone the repository (or any fork of it) to your local machine since the Terraform code will be running on the Terraform Enterprise server after TFE downloads the code from GitHub.

1. Create a workspace on your TFE Enterprise Server (which could be the SaaS TFE server running at https://atlas.hashicorp.com).
1. Point your workspace at this repository or a fork of it.
1. On the Variables tab of your workspace, add a windows_dns_prefix Terraform variable and set it to a string which will be used as the initial segment of the DNS name for the Windows VM that will be provisioned in Azure. This must be globally unique. Additionally, certain values might give warnings about trademarks being used.
1. Click the Save button to save your Terraform variable.
1. On the Variables tab of your workspace, add environment variables ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_SUBSCRIPTION_ID, and ARM_TENANT_ID and set them to the  credentials of an Azure service principal as described [here](https://www.terraform.io/docs/providers/azurerm/authenticating_via_service_principal.html).
1. Also add an environment variable TF_WARN_OUTPUT_ERRORS with value of 1 to avoid halting execution when the Azure compute module gives an expected error.
1. Click the Save button to save your environment variables.
1. Click the "Queue Plan" button in the upper right corner of the workspace page.
1. After the Plan successfully completes, click the "Confirm and Apply" button at the bottom of the page.

Note that if you did not set the TF_WARN_OUTPUT_ERRORS environment variable, you will see an error from inside the Azure compute module at the end of the apply indicating that the resource azurerm_public_ip.vm does not have an ip_address. This is because the public IP address is not ready when the module writes its outputs. But the VM will be correctly provisioned. You can run apply a second time to generate the windows_vm_public_name output without any error.

## Destroying
Do the following to destroy the Azure infrastructure provisioned by this configuration.

1. On the Variables tab of your workspace, add an environment variable, CONFIRM_DESTROY, with value 1.
1. On the Settings tab of your workspace, click the "Queue destroy plan" button.
1. After the plan for the destroy completes, click the "Confirm and Apply" button at the bottom of the page to destroy the Azure infrastructure.
