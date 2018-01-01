# Kubernetes Cluster in Legacy Azure Container Service (ACS)
Terraform configuration for deploying a Kubernetes cluster in the legacy [Azure Container Service (ACS)](https://docs.microsoft.com/en-us/azure/container-service/kubernetes/).

## Introduction
This Terraform configuration deploys a Kubernetes cluster into Azure's legacy managed Kubernetes service (ACS). It replicates what an Azure customer could do with the `az acs create` CLI [command](https://docs.microsoft.com/en-us/cli/azure/acs?view=azure-cli-latest#az_acs_create). These instructions assume that you are using Terraform Enterprise (TFE) rather than the open source version of Terraform.

It uses the Azure provider's azurerm_container_service resource to create an entire Kubernetes cluster in ACS including required VMs, networks, and other Azure constructs. Note that this creates a legacy ACS service which includes both the master node VMs that run the Kubernetes control plane and the agent node VMs onto which customers deploy their containerized applications. This differs from the new [Azure Container Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/) which excludes the master node VMs since Microsoft runs those outside the customer's Azure account.

This Terraform configuration gets the Azure credentials from a [Vault](https://www.vaultproject.io/) server.

## Deployment Prerequisites

1. Sign up for a free [Azure account](https://azure.microsoft.com/en-us/free/) if you do not already have one.
1. Create an Azure Service Principal for Terraform and Kubernetes to use when interacting with the Azure Resource Manager. See these [instructions](https://www.terraform.io/docs/providers/azurerm/authenticating_via_service_principal.html).
1. Set up a Vault server if you do not already have access to one and determine your username, password, and associated Vault token.
1. Login to the UI of your Vault server or use the Vault CLI to add your Azure client_id, client_secret, subscription_id, and tenant_id with those names in secret/<vault_username>/azure/credentials. Note that this is the path to the secret and that the 4 Azure credentials will be 4 keys underneath this single secret.  If using the vault CLI, you would use `vault write secret/<vault_username>/azure/credentials client_id=<client_id> client_secret=<client_secret> subscription_id=<subscription_id> tenant_id=<tenant_id>`, providing the actual values for your Azure service principal.
1. If you do not already have a Terraform Enterprise (TFE) account, request one from sales@hashicorp.com.
1. After getting access to your TFE account, create an organization in it. Click the Cancel button when prompted to create a new workspace.
1. Configure your TFE organization to connect to GitHub. See this [doc](https://www.terraform.io/docs/enterprise/vcs/github.html).

## Deployment Steps
Execute the following commands to deploy your Kubernetes cluster to ACS.

1. Fork this repository by clicking the Fork button in the upper right corner of the screen and selecting your own personal GitHub account or organization.
1. Clone the fork to your laptop by running `git clone https://github.com/<your_github_account>/terraform-guides.git`.
1. Run `git checkout dev` to put yourself on the dev branch of your fork.
1. Create a workspace in your TFE organization called k8s-cluster-acs-dev.
1. Configure the k8s-cluster-acs-dev workspace to connect to the fork of this repository in your own GitHub account.
1. Click the "More options" link, set the Terraform Working Directory to "infrastructure-as-code/k8s-cluster-acs" and the VCS Branch to "dev".
1. On the Variables tab of your workspace, add the following variables to the Terraform variables: dns_agent_pool_prefix, dns_master_prefix, environment, resource_group_name, and vault_user. We recommend values for the first four of these like "<user>-k8s-agentpool-dev", "<user>-k8s-master-dev", "dev", and "<user>-k8s-example-dev". Be sure to set vault_user to your username on the Vault server you are using. Note that the dns_agent_pool_prefix and dns_master_prefix values must be unique within Azure. If you see errors related to these when provisioning your ACS cluster, please pick different values.
1. Set the following Environment Variables: VAULT_ADDR to the address of your Vault server including the port (e.g., "http://<your_vault_dns>:8200"), VAULT_TOKEN to your Vault token, and VAULT_SKIP_VERIFY to true (if you have not enabled TLS on your Vault server). Be sure to mark the VAULT_TOKEN variable as sensitive so that other people cannot read it.
1. Click the "Queue Plan" button in the upper right corner of your workspace. (Alternatively, you could make some minor change to your dev branch, run `git commit -m "<change_description>"`, and then run `git push origin dev` to push the change you made to GitHub. This will trigger a Terraform run in your workspace.)
1. On the Latest Run tab, you should see a new run. If the plan succeeds, you can view the plan and verify that the ACS cluster will be created when you apply your plan.
1. Click the "Confirm and Apply" button to actually provision your ACS dev cluster.

You will see outputs representing the URL to access your ACS dev cluster in the Azure Portal, your private key PEM, the FQDN of your cluster, TLS certs/keys for your cluster, the Vault Kubernetes authentication backend, and your Vault username.  You will need these when using Terraform's Kubernetes Provider to provision Kubernetes pods and services in other workspaces that use your dev cluster.

You can also validate that the cluster was created in the Azure Portal.

## Adding a Prod Environment
You can execute the following steps if you want to create a production ACS cluster and walk through the process of promoting Terraform code from a dev environent to a production environment in TFE.

1. Create a workspace in your TFE organization called k8s-cluster-acs-prod.
1. Configure the k8s-cluster-acs-prod workspace to connect to the fork of this repository in your own GitHub account.
1. Click the "More options" link, set the Terraform Working Directory to "infrastructure-as-code/k8s-cluster-acs" and the VCS Branch to "prod".
1. On the Variables tab of your workspace, add the following variables to the Terraform variables: dns_agent_pool_prefix, dns_master_prefix, environment, resource_group_name, and vault_user. We recommend values for the first four of these like "<user>-k8s-agentpool-prod", "<user>-k8s-master-prod", "prod", and "<user>-k8s-example-prod". Be sure to set vault_user to your username on the Vault server you are using.
1. Set the same Vault environment variables that you set for your k8s-cluster-acs-dev workspace.
1. In GitHub, do a pull request to merge your dev branch into your prod branch within your fork. (You might need to make some small change in your dev branch so that the two branches differ before doing this.)
1. On the Latest Run tab, you should see a new run. If the plan succeeds, you can view the plan and verify that the ACS cluster will be created when you apply your plan.
1. However, you will not yet see the "Confirm and Apply" button. To see it, you must first go back to GitHub and merge the pull request. At that point, a new run will be triggered within TFE which will allow you to apply the plan if you want.
1. Click the "Confirm and Apply" button to actually provision your ACS production cluster.

You will see outputs representing the URL to access your ACS dev cluster in the Azure Portal, your private key PEM, the FQDN of your cluster, TLS certs/keys for your cluster, the Vault Kubernetes authentication backend, and your Vault username.  You will need these when using Terraform's Kubernetes Provider to provision Kubernetes pods and services in other workspaces that use your dev ACS cluster.

You can also validate that the cluster was created in the Azure Portal.

## Cleanup
Execute the following steps to delete your Kubernetes clusters and associated resources from ACS.

1. On the Variables tab of your k8s-cluster-acs-dev workspace, add the environment variable CONFIRM_DESTROY with value 1.
1. At the bottom of the Settings tab of your k8s-cluster-acs-dev workspace, click the "Queue destroy plan" button to make TFE do a destroy run.
1. On the Latest Run tab of your k8s-cluster-acs-dev workspace, make sure that the Plan was successful and then click the "Confirm and Apply" button to actually destroy your ACS cluster and other resources that were provisioned by Terraform.
1. If for any reason, you do not see the "Confirm and Apply" button even though the Plan was successful, please delete your resource group from inside the [Azure Portal](https://portal.azure.com). Doing that will destroy all the resources that Terraform provisioned since they are all created inside the resource group.
1. Repeat the previous steps for your k8s-cluster-acs-prod workspace.
