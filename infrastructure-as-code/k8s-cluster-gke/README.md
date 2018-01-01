# Kubernetes Cluster in Google Kubernetes Engine (GKE)
Terraform configuration for deploying a Kubernetes cluster in the [Google Kubernetes Engine (GKE)](https://cloud.google.com/kubernetes-engine/) in the Google Cloud Platform (GCP).

## Introduction
This Terraform configuration deploys a Kubernetes cluster into Google's managed Kubernetes service, Google Kubernetes Engine (GKE). It replicates what a GCP customer could do with the `gcloud container clusters create` CLI [command](https://cloud.google.com/sdk/gcloud/reference/container/clusters/create).

It uses Google Cloud Provider's google_container_cluster resource to create an entire Kubernetes cluster in GKE including required VMs, networks, and other GCP constructs.

This Terraform configuration gets the GCP credentials from a [Vault](https://www.vaultproject.io/) server.

## Deployment Prerequisites

1. Sign up for a free [Google Cloud Platform](https://cloud.google.com) account.
1. Follow the instructions on Google's [Kubernetes Engine Quickstart](https://cloud.google.com/kubernetes-engine/docs/quickstart) page to create or select a project in your account, enable the Google Kubernetes Engine API in your project, and enable billing for your project.
1. Follow these [instructions](https://www.terraform.io/docs/providers/google/index.html#authentication-json-file) to download an authentication JSON file for your project which Terraform will use when provisioning resources to your GCP project.
1. Set up a Vault server if you do not already have access to one and determine your username, password, and associated Vault token.
1. Login to the UI of your Vault server or use the Vault CLI to paste the contents of your GCP authentication JSON file into secret/<vault_username>/gcp/credentials. Note that this is the path to the secret and that the entire contents of the file will be be added to a single key with the same name as your GCP project underneath this single secret.  If using the vault CLI, you would use `vault write secret/<vault_username>/gcp/credentials <project>=<project_auth_json_contents>`, providing the actual contents of the JSON file for value of the key.
1. If you do not already have a Terraform Enterprise (TFE) account, request one from sales@hashicorp.com.
1. After getting access to your TFE account, create an organization in it. Click the Cancel button when prompted to create a new workspace.
1. Configure your TFE organization to connect to GitHub. See this [doc](https://www.terraform.io/docs/enterprise/vcs/github.html).

## Deployment Steps
Execute the following commands to deploy your Kubernetes cluster to GKE.

1. Fork this repository by clicking the Fork button in the upper right corner of the screen and selecting your own personal GitHub account or organization.
1. Clone the fork to your laptop by running `git clone https://github.com/<your_github_account>/terraform-guides.git`.
1. Run `git checkout dev` to put yourself on the dev branch of your fork.
1. Create a workspace in your TFE organization called k8s-cluster-gke-dev.
1. Configure the k8s-cluster-gke-dev workspace to connect to the fork of this repository in your own GitHub account.
1. Click the "More options" link, set the Terraform Working Directory to "infrastructure-as-code/k8s-cluster-gke" and the VCS Branch to "dev".
1. On the Variables tab of your workspace, add the following variables to the Terraform variables: gcp_project, gcp_region, gcp_zone, initial_node_count, node_machine_type, environment, and vault_user. The first of these must be the name of the GCP project you are using. The next two should be a valid GCP region and zone inside it (such as "us-east1" and "us-east1-b"). initial_node_count can be 1 while node_machine_type can be n1-standard-1. environment should be "dev". Be sure to set vault_user to your username on the Vault server you are using.
1. Set the following Environment Variables: VAULT_ADDR to the address of your Vault server including the port (e.g., "http://<your_vault_dns>:8200"), VAULT_TOKEN to your Vault token, and VAULT_SKIP_VERIFY to true (if you have not enabled TLS on your Vault server). Be sure to mark the VAULT_TOKEN variable as sensitive so that other people cannot read it.
1. Click the "Queue Plan" button in the upper right corner of your workspace. (Alternatively, you could make some minor change to your dev branch, run `git commit -m "<change_description>"`, and then run `git push origin dev` to push the change you made to GitHub. This will trigger a Terraform run in your workspace.)
1. On the Latest Run tab, you should see a new run. If the plan succeeds, you can view the plan and verify that the GKE cluster will be created when you apply your plan.
1. Click the "Confirm and Apply" button to actually provision your GKE dev cluster.

You will see outputs representing the URLs to access your GKE dev cluster in the Google Console, the FQDN of your cluster, TLS certs/keys for your cluster, the Vault Kubernetes authentication backend, and your Vault username.  You will need these when using Terraform's Kubernetes Provider to provision Kubernetes pods and services in other workspaces that use your dev cluster.

You can also validate that the cluster was created in the Google Console.

## Adding a Prod Environment
You can execute the following steps if you want to create a production GKE cluster and walk through the process of promoting Terraform code from a dev environent to a production environment in TFE.

1. Create a second Google project and configure it as instructed in the Deployment Prerequisites section above.
1. Create a workspace in your TFE organization called k8s-cluster-gke-prod.
1. Configure the k8s-cluster-gke-prod workspace to connect to the fork of this repository in your own GitHub account.
1. Click the "More options" link, set the Terraform Working Directory to "infrastructure-as-code/k8s-cluster-gke" and the VCS Branch to "prod".
1. On the Variables tab of your workspace, add the following variables to the Terraform variables: gcp_project, gcp_region, gcp_zone, initial_node_count, node_machine_type, environment, and vault_user. The first of these must be the name of the second GCP project you are using. The next two should be a valid GCP region and zone inside it (such as "us-east1" and "us-east1-b"). initial_node_count can be 1 while node_machine_type can be n1-standard-1. environment should be "prod". Be sure to set vault_user to your username on the Vault server you are using.
1. Set the same Vault environment variables that you set for your k8s-cluster-gke-dev workspace.
1. In GitHub, do a pull request to merge your dev branch into your prod branch within your fork. (You might need to make some small change in your dev branch so that the two branches differ before doing this.)
1. On the Latest Run tab, you should see a new run. If the plan succeeds, you can view the plan and verify that the GKE cluster will be created when you apply your plan.
1. However, you will not yet see the "Confirm and Apply" button. To see it, you must first go back to GitHub and merge the pull request. At that point, a new run will be triggered within TFE which will allow you to apply the plan if you want.
1. Click the "Confirm and Apply" button to actually provision your GKE production cluster.

You will see outputs representing the URLs to access your GKE prod cluster in the Google Console, the FQDN of your cluster, TLS certs/keys for your cluster, the Vault Kubernetes authentication backend, and your Vault username.  You will need these when using Terraform's Kubernetes Provider to provision Kubernetes pods and services in other workspaces that use your prod GKE cluster.

You can also validate that the cluster was created in the Google Console.

## Cleanup
Execute the following steps to delete your Kubernetes clusters and associated resources from GKE.

1. On the Variables tab of your k8s-cluster-gke-dev workspace, add the environment variable CONFIRM_DESTROY with value 1.
1. At the bottom of the Settings tab of your k8s-cluster-gke-dev workspace, click the "Queue destroy plan" button to make TFE do a destroy run.
1. On the Latest Run tab of your k8s-cluster-gke-dev workspace, make sure that the Plan was successful and then click the "Confirm and Apply" button to actually destroy your GKE cluster and other resources that were provisioned by Terraform.
1. If for any reason, you do not see the "Confirm and Apply" button even though the Plan was successful, please delete your cluster from inside the [Google Console](https://portal.azure.com). Doing that will destroy all the resources that Terraform provisioned.
1. Repeat the previous steps for your k8s-cluster-gke-prod workspace.
