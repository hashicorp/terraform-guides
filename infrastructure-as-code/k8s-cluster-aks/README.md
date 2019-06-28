# Kubernetes Cluster in Azure Kubernetes Service (AKS)
The Terraform configuration in this directory can be used to deploy a Kubernetes cluster in the  [Azure Kubernetes Service (AKS)](https://azure.microsoft.com/en-us/services/kubernetes-service).

## Introduction
This Terraform configuration deploys a Kubernetes cluster into Azure's managed Kubernetes service, AKS. It replicates what an Azure customer could do with the `az aks create` CLI [command](https://docs.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az-aks-create). These instructions assume that you are using Terraform Enterprise (TFE) rather than the open source version of Terraform.

It uses the Azure provider's azurerm_kubernetes_cluster resource to create an entire Kubernetes cluster in AKS including required VMs, networks, and other Azure constructs. Note that this creates an AKS service which only includes the agent node VMs onto which customers deploy their containerized applications. Microsoft runs multi-tenant master nodes outside of the customer's Azure account.

This Terraform configuration gets the Azure credentials from a [Vault](https://www.vaultproject.io/) server.

This configuration is intended to be used with two other configurations, [k8s-vault-config](../k8s-vault-config) and [k8s-services](../../self-serve-infrastructure/k8s-services). The first provisions an instance of the Vault Kubernetes authentication method against the cluster while the second provisions some pods, services, and other Kubernetes contstructs.

## Deployment Prerequisites

1. Sign up for a free [Azure account](https://azure.microsoft.com/en-us/free/) if you do not already have one.
1. Create an Azure Service Principal for Terraform and Kubernetes to use when interacting with the Azure Resource Manager. See these [instructions](https://www.terraform.io/docs/providers/azurerm/authenticating_via_service_principal.html).
1. Set up a Vault server if you do not already have access to one and determine your username, password, and associated Vault token.
1. We assume that the [Userpass auth method](https://www.vaultproject.io/docs/auth/userpass.html) is enabled on your Vault server.  If not, that is ok.  You will login to the Vault UI with your Vault token instead of with your username. Wherever the Terraform-specific instructions below ask you to specify your Vault username, just make one up for yourself.
1. Your Vault username and token will need to have a Vault policy like [sample-policy.hcl](./sample-policy.hcl) associated with them. You could use this one after changing "roger" to your username and renaming the file to \<username\>-policy.hcl.  Run `vault policy write <username> <username>-policy.hcl` to import the policy to your Vault server. Then run `vault write auth/userpass/users/<username> policies="<username>"` to associate the policy with your username. (If you already have other policies associated with the user, then be sure to include those policies in the list of policies with commas between them.) To create a new token and associate the policy with it, run `vault token create -display-name="<username>-token" -policy="<username>"`.
1. Login to the UI of your Vault server or use the Vault CLI to add your Azure client_id, client_secret, subscription_id, and tenant_id with those names in secret/<vault_username>/azure/credentials. Note that this is the path to the secret and that the 4 Azure credentials will be 4 keys underneath this single secret.  If using the vault CLI, you would use `vault write secret/<vault_username>/azure/credentials client_id=<client_id> client_secret=<client_secret> subscription_id=<subscription_id> tenant_id=<tenant_id>`, providing the actual values for your Azure service principal.
1. If you do not already have a Terraform Enterprise (TFE) account, request one from sales@hashicorp.com.
1. After getting access to your TFE account, create an organization in it. Click the Cancel button when prompted to create a new workspace.
1. Configure your TFE organization to connect to GitHub. See this [doc](https://www.terraform.io/docs/enterprise/vcs/github.html).

## Deployment Steps
Execute the following commands to deploy your Kubernetes cluster to AKS.

1. Fork this repository by clicking the Fork button in the upper right corner of the screen and selecting your own personal GitHub account or organization.
1. Clone the fork to your laptop by running `git clone https://github.com/<your_github_account>/terraform-guides.git`.
1. Create a workspace in your TFE organization called k8s-cluster-aks.
1. Configure the k8s-cluster-aks workspace to connect to the fork of this repository in your own GitHub account.
1. Click the "More options" link, set the Terraform Working Directory to "infrastructure-as-code/k8s-cluster-aks".
1. On the Variables tab of your workspace, add the following variables to the Terraform variables: resource_group_name, dns_prefix, vm_size, vault_addr, and vault_user. We recommend using "<your_name>-k8s" for dns_prefix. Note that the dns_prefix must be unique within Azure. If you see errors when provisioning your AKS cluster, please pick a different value. vm_size should be a valid Azure [vm size](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/sizes-general); the default of "Standard_D2" should be fine for demo purposes. Be sure to set vault_addr to the address of your Vault server including the port (e.g., "http://<your_vault_dns>:8200") and vault_user to your username on your Vault server.
1. You can optionally set other variables including azure_location, k8s_version, admin_user, agent_pool_name, agent_count, os_type, os_disk_size, and environment. See [variables.tf](./variables.tf) for descriptions. Note that we default to using Kubernetes 1.12.7 with Linux VMs. The environment and vault_user variables determine the name of the Vault Kubernetes authentication method provisioned in the k8s-vault-configuration workspace.
1. Set the VAULT_TOKEN environment variable to your Vault token. Be sure to mark the VAULT_TOKEN variable as sensitive so that other people cannot read it.
1. Click the "Queue Plan" button in the upper right corner of your workspace.
1. On the Latest Run tab, you should see a new run. If the plan succeeds, you can view the plan and verify that the AKS cluster will be created when you apply your plan.
1. Click the "Confirm and Apply" button to actually provision your AKS dev cluster.

You will see outputs representing the URL to access your AKS cluster in the Azure Portal, your private key PEM, the FQDN of your cluster, TLS certs/keys for your cluster, the Vault address, and your Vault username.  You will need these when using Terraform's Kubernetes Provider to provision Kubernetes pods and services in other workspaces that use your dev cluster. However, if you configure the Vault Kubernetes authentication method in a workspace that uses the Terraform code in the [k8s-vault-config](../k8s-vault-config) directory of this repository and deploy your pods and services against the Terraform code in the [k8s-services](../../self-serve-infrastructure/k8s-services) directory of this repository, the outputs will automatically be used by those workspaces.

You can also validate that the cluster was created in the Azure Portal.

## Next Steps
1. Provision an instance of the Vault Kubernetes authentication method against your cluster using the [k8s-vault-config](../k8s-vault-config) configuration in this repository.
1. Provision some Kubernetes pods and services using the [k8s-services](../../self-serve-infrastructure/k8s-services) configuration in this repository.

## Cleanup
Execute the following steps for your workspace to delete your Kubernetes cluster and associated resources from Azure.

1. On the Variables tab of your workspace, add the environment variable CONFIRM_DESTROY with value 1.
1. At the bottom of the Settings tab of your workspace, click the "Queue destroy plan" button to make TFE do a destroy run.
1. On the Latest Run tab of your workspace, make sure that the Plan was successful and then click the "Confirm and Apply" button to actually destroy your AKS cluster and other resources that were provisioned by Terraform.
1. If for any reason, you do not see the "Confirm and Apply" button even though the Plan was successful, please delete your resource group from inside the [Azure Portal](https://portal.azure.com). Doing that will destroy all the resources that Terraform provisioned since they are all created inside the resource group.
