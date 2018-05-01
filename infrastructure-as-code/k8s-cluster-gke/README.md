# Kubernetes Cluster in Google Kubernetes Engine (GKE)
Terraform configuration for deploying a Kubernetes cluster in the [Google Kubernetes Engine (GKE)](https://cloud.google.com/kubernetes-engine/) in the Google Cloud Platform (GCP).

## Introduction
This Terraform configuration deploys a Kubernetes cluster into Google's managed Kubernetes service, Google Kubernetes Engine (GKE). It replicates what a GCP customer could do with the `gcloud container clusters create` CLI [command](https://cloud.google.com/sdk/gcloud/reference/container/clusters/create).

It uses Google Cloud Provider's google_container_cluster resource to create an entire Kubernetes cluster in GKE including required VMs, networks, and other GCP constructs.

This Terraform configuration gets the GCP credentials from a [Vault](https://www.vaultproject.io/) server.

## Deployment Prerequisites

1. Sign up for a free [Google Cloud Platform](https://cloud.google.com) account.
1. Follow the instructions on Google's [Kubernetes Engine Quickstart](https://cloud.google.com/kubernetes-engine/docs/quickstart) page to create or select a project in your account, enable the Google Kubernetes Engine API in your project, and enable billing for your project. When creating your project, we recommend using a globally unique project name so that your project name and project ID will be identical. This will avoid confusion when adding your GCP credentials file to Vault.
1. Follow these [instructions](https://www.terraform.io/docs/providers/google/index.html#authentication-json-file) to download an authentication JSON file for your project which Terraform will use when provisioning resources to your GCP project.
1. Set up a Vault server if you do not already have access to one and determine your username, password, and associated Vault token.
1. We assume that the [Userpass auth method](https://www.vaultproject.io/docs/auth/userpass.html) is enabled on your Vault server.  If not, that is ok.  You will login to the Vault UI with your Vault token instead of with your username. Wherever the Terraform-specific instructions below ask you to specify your Vault username, just make one up for yourself.
1. Your Vault username and token will need to have a Vault policy like [sample-policy.hcl](./sample-policy.hcl) associated with them. You could use this one after changing "roger" to your username and renaming the file to \<username\>-policy.hcl.  Run `vault write sys/policy/<username> policy=@<username>-policy.hcl` to import the policy to your Vault server. Then run `vault write auth/userpass/users/<username> policies="<username>"` to associate the policy with your username. (If you already have other policies associated with the user, then be sure to include those policies in the list of policies with commas between them.) To create a new token and associate the policy with it, run `vault token-create -display-name="<username>-token" -policy="<username>"`.
1. Login to the UI of your Vault server or use the Vault CLI to paste the contents of your GCP authentication JSON file into secret/<vault_username>/gcp/credentials. Note that this is the path to the secret and that the entire contents of the file will be be added to a single key equal to your GCP project ID underneath this single secret.  If using the vault CLI, you would use `vault write secret/<vault_username>/gcp/credentials <project_id>=<project_auth_json_contents>`, providing the actual contents of the JSON file for value of the key. Ideally, you will have created a GCP project with a globally unique name so that the project name and the project ID are identical.  If they differ, be sure to use the project ID, not the project Name.
1. If you do not already have a Terraform Enterprise (TFE) account, request one from sales@hashicorp.com.
1. After getting access to your TFE account, create an organization in it. Click the Cancel button when prompted to create a new workspace.
1. Configure your TFE organization to connect to GitHub. See this [doc](https://www.terraform.io/docs/enterprise/vcs/github.html).

## Deployment Steps
Execute the following commands to deploy your Kubernetes cluster to GKE.

1. Fork this repository by clicking the Fork button in the upper right corner of the screen and selecting your own personal GitHub account or organization.
1. Clone the fork to your laptop by running `git clone https://github.com/<your_github_account>/terraform-guides.git`.
1. Create a workspace in your TFE organization called k8s-cluster-gke.
1. Configure the k8s-cluster-gke workspace to connect to the fork of this repository in your own GitHub account.
1. Click the "More options" link, set the Terraform Working Directory to "infrastructure-as-code/k8s-cluster-gke".
1. On the Variables tab of your workspace, add the following variables to the Terraform variables: gcp_project, gcp_region, gcp_zone, initial_node_count, node_machine_type, environment, vault_addr, and vault_user. The first of these must be the name of the GCP project you are using. The next two should be a valid GCP region and zone inside it (such as "us-east1" and "us-east1-b"). initial_node_count can be 1 while node_machine_type can be n1-standard-1. environment should be "dev". Be sure to set vault_addr to the address of your Vault server including the port (e.g., "http://<your_vault_dns>:8200") and vault_user to your username on your Vault server.
1. Set the VAULT_TOKEN environment variable to your Vault token. Be sure to mark the VAULT_TOKEN variable as sensitive so that other people cannot read it.
1. Click the "Queue Plan" button in the upper right corner of your workspace.
1. On the Latest Run tab, you should see a new run. If the plan succeeds, you can view the plan and verify that the GKE cluster will be created when you apply your plan.
1. Click the "Confirm and Apply" button to actually provision your GKE cluster.

You will see outputs representing the URLs to access your GKE cluster in the Google Console, the FQDN of your cluster, TLS certs/keys for your cluster, the Vault Kubernetes authentication backend, the Vault address, and your Vault username. You will need these when using Terraform's Kubernetes Provider to provision Kubernetes pods and services in other workspaces that use your cluster. However, if you configure a workspace against the Terraform code in the [k8s-services](../../self-serve-infrastructure/k8s-services) directory of this repository to provision your pods and services, the outputs will automatically be used by that workspace.

You can also validate that the cluster was created in the Google Console.

## Cleanup
Execute the following steps for your workspaces to delete your Kubernetes cluster and associated resources from GKE.

1. On the Variables tab of your workspace, add the environment variable CONFIRM_DESTROY with value 1.
1. At the bottom of the Settings tab of your workspace, click the "Queue destroy plan" button to make TFE do a destroy run.
1. On the Latest Run tab of your workspace, make sure that the Plan was successful and then click the "Confirm and Apply" button to actually destroy your GKE cluster and other resources that were provisioned by Terraform.
1. If for any reason, you do not see the "Confirm and Apply" button even though the Plan was successful, please delete your cluster from inside the [Google Console](https://console.cloud.google.com). Doing that will destroy all the resources that Terraform provisioned.
