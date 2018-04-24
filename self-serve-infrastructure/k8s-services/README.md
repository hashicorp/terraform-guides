# Kubernetes Pods and Services
Terraform configuration for deploying Kubernetes pods and services to existing Kubernetes clusters in Azure Container Service (ACS) and Google Kubernetes Engine (GKE).

## Introduction
This Terraform configuration deploys two pods exposed as services. It is meant to be used in Terraform Enterprise (TFE). The first runs a python application called "cats-and-dogs-frontend" that lets users vote for their favorite type of pet. It stores data in the second, "cats-and-dogs-backend", which runs a redis database. The Terraform configuration replicates what a user could do with the [Kubernetes CLI](https://kubernetes.io/docs/tasks/tools/install-kubectl/), `kubectl`.

It uses the kubernetes_pod and kubernetes_service resources of Terraform's Kubernetes Provider to deploy the pods and services into a Kubernetes cluster previously provisioned by Terraform. It also uses the terraform_remote_state data source to copy the outputs of the targeted cluster's TFE workspace directly into the Kubernetes Provider block, avoiding the need to manually copy the outputs into variables of the TFE services workspace. It also uses the vault_addr, vault_user, and vault_k8s_auth_backend outputs from the cluster workspace. Note that it also creates a Kubernetes service account called "cats-and-dogs" which the pods use.

Another important aspect of this configuration is that both the frontend application and the redis database get the redis password from a Vault server after using the Kubernetes JWT token of the cats-and-dogs service account to authenticate against Vault's Kubernetes auth method. This has the benefits that the redis password is not stored in the Terraform code and that neither the application developers nor the DBAs managing Redis need to know what the redis password is. Only the security team that stores the password in Vault know it. The redis_db password is stored in the Vault server under "secret/<vault_user>/kubernetes/cats-and-dogs" where \<vault_user\> is the Vault username.

## Deployment Prerequisites

1. First deploy a Kubernetes cluster with Terraform Enterprise (TFE) by using one of these Terraform repositories and pointing a TFE workspace against it:
    - [tfe-k8s-cluster-acs](../../infrastructure-as-code/k8s-cluster-acs)
    - [tfe-k8s-cluster-gke](../../infrastructure-as-code/k8s-cluster-gke)
1. We assume that you have already satisfied all the prerequisites for deploying a Kubernetes cluster in ACS or GKE described by the above links.
1. We also assume that you have already forked this repository and cloned your fork to your laptop.
1. We also assume you have created dev and prod branches on your fork if you deployed both dev and prod clusters.


## Deployment Steps
Execute the following commands to deploy the pods and services to your Kubernetes cluster:

1. Create a new TFE workspace called k8s-services-acs-dev or k8s-services-gke-dev depending on whether you are deploying to ACS or GKE.
1. Configure your workspace to connect to the fork of this repository in your own GitHub account.
1. Click the "More options" link, set the Terraform Working Directory to "self-serve-infrastructure/k8s-services" and the VCS Branch to "dev". (If you are only using one cluster and did not create a dev branch on your fork, use "master" instead or just leave the VCS Branch blank.)
1. Set the tfe-organization Terraform variable in your new workspace to the name of the TFE organization containing your Kubernetes cluster workspace.
1. Set the k8s-cluster-workspace Terraform variable in your new workspace to the name of the workspace you used to deploy your Kubernetes cluster.
1. Queue a plan for the services workspace in TFE by clicking the "Queue Plan" button in the upper right corner of your workspace.
1. On the Latest Run tab, you should see a new run. If the plan succeeds, you can view the plan and verify that the pods and services will be created when you apply your plan.
1. Click the "Confirm and Apply" button to actually deploy the pods and services.
1. Finally, enter the cats_and_dogs_ip output in a browser. You should see the "Pets Voting App" page.
1. Vote for your favorite pets.

## Adding a Prod Environment
If you deployed a production Kubernetes cluster, you can repeat the previous steps with a second services workspace and deploy the pods and services into your production cluster too. You could then walk through the process of promoting Terraform code from a dev environment to a production environment in TFE. (See the [k8s-cluster-acs README.md](../../infrastructure-as-code/k8s-cluster-acs/README.md) or [k8s-cluster-gke README.md](../../infrastructure-as-code/k8s-cluster-gke/README.md) too see how.) You would want to set the VCS Branch of the second services workspace to "prod".

## Cleanup
Execute the following steps to delete the cats-and-dogs pods and services from each of your Kubernetes clusters.

1. Define an environment variable CONFIRM_DESTROY with value 1 on the Variables tab of your services workspace.
1. Queue a Destroy plan in TFE from the Settings tab of your services workspace.
1. On the Latest Run tab of your services workspace, make sure that the Plan was successful and then click the "Confirm and Apply" button to actually remove the cats-and-dogs pods and services.
