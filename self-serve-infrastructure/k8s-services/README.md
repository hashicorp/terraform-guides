# Kubernetes Pods and Services
The Terraform configuration in this directory can be used for deploying Kubernetes pods and services to existing Kubernetes clusters in Azure Kubernetes Service (AKS) and Google Kubernetes Engine (GKE).

## Introduction
This Terraform configuration deploys two pods exposed as services. It is meant to be used in Terraform Enterprise (TFE). The first runs a python application called "cats-and-dogs-frontend" that lets users vote for their favorite type of pet. It stores data in the second, "cats-and-dogs-backend", which runs a redis database. The Terraform configuration replicates what a user could do with the [Kubernetes CLI](https://kubernetes.io/docs/tasks/tools/install-kubectl/), `kubectl`.

This configuration is intended to be used with two other configurations, either [k8s-cluster-aks](../../infrastructure-as-code/k8s-cluster-aks) or [k8s-cluster-gke](../../infrastructure-as-code/k8s-cluster-gke), which provision Kubernetes clusters in AKS and GKE respectively, and [k8s-vault-config](../../infrastructure-as-code/k8s-vault-config), which provisions an instance of Vault's Kubernetes authentication method against the cluster.

The source code and docker files for the applications is in the [cats-and-dogs](../cats-and-dogs) directory of this repository.

It uses the kubernetes_namespace and kubernetes_service_account resources of Terraform's Kubernetes Provider to create a namespace and service account, both called "cats-and-dogs". It then uses the kubernetes_pod and kubernetes_service resources of the Kubernetes Provider to deploy the pods and services into a Kubernetes cluster previously provisioned by Terraform. The pods and services use the cats-and-dogs service account and therefore run in the cats-and-dogs namespace.

It also uses two instances of the terraform_remote_state data source to copy the outputs of the targeted cluster's workspace and the targeted vault configuration workspace. The k8s cluster connection details are copied directly into the Kubernetes Provider block, avoiding the need to manually copy the outputs into variables of the TFE services workspace. It also uses the vault_addr and vault_user outputs from the cluster workspace and the vault_k8s_auth_backend output from the vault configuration workspace.

Another important aspect of this configuration is that both the frontend application and the redis database get the redis password from a Vault server after using the Kubernetes JWT token of the cats-and-dogs service account to authenticate against Vault's Kubernetes auth method. This has the benefits that the redis password is not stored in the Terraform code and that neither the application developers nor the DBAs managing Redis need to know what the redis password is. Only the security team that stores the password in Vault know it. The redis_db password is stored in the Vault server under "secret/<vault_user>/kubernetes/cats-and-dogs" where \<vault_user\> is the Vault username.

## Deployment Prerequisites

1. First deploy a Kubernetes cluster with Terraform Enterprise (TFE) by using one of these Terraform repositories and pointing a TFE workspace against it:
    - [k8s-cluster-aks](../../infrastructure-as-code/k8s-cluster-aks)
    - [k8s-cluster-gke](../../infrastructure-as-code/k8s-cluster-gke)
1. We assume that you have already satisfied all the prerequisites for deploying a Kubernetes cluster in AKS or GKE described by the above links.
1. We also assume that you have configured the [Vault Kubernetes Authentication Method](https://www.vaultproject.io/docs/auth/kubernetes.html) against your cluster using a workspace that points against the [k8s-vault-config](../../infrastructure-as-code/k8s-vault-config) repository.
1. We also assume that you have already forked this repository and cloned your fork to your laptop.


## Deployment Steps
Execute the following commands to deploy the pods and services to your Kubernetes cluster:

1. Create a new TFE workspace called k8s-services-aks or k8s-services-gke depending on whether you are deploying to AKS or GKE. (You could also just call it k8s-services, but including "-aks" or "-gke" is helpful if you might deploy this configuration against AKS and GKE clusters.)
1. Configure your workspace to connect to the fork of this repository in your own GitHub account.
1. Click the "More options" link, set the Terraform Working Directory to "self-serve-infrastructure/k8s-services".
1. Set the **tfe_organization** Terraform variable in your new workspace to the name of the TFE organization containing your Kubernetes cluster workspace.
1. Set the **k8s_cluster_workspace** Terraform variable in your new workspace to the name of the workspace you used to deploy your Kubernetes cluster.
1. Set the **k8s_vault_config_workspace** Terraform variable in your new workspace to the name of the workspace you used to configure the Vault authentication method for your Kubernetes cluster.
1. Queue a plan for the services workspace in TFE by clicking the "Queue Plan" button in the upper right corner of your workspace.
1. On the Latest Run tab, you should see a new run. If the plan succeeds, you can view the plan and verify that the pods and services will be created when you apply your plan.
1. Click the "Confirm and Apply" button to actually deploy the pods and services.
1. Finally, enter the cats_and_dogs_ip output in a browser. You should see the "Pets Voting App" page.
1. Vote for your favorite pets.


## Cleanup
Execute the following steps to delete the cats-and-dogs pods and services from each of your Kubernetes clusters.

1. Define an environment variable CONFIRM_DESTROY with value 1 on the Variables tab of your services workspace.
1. Queue a Destroy plan in TFE from the Settings tab of your services workspace.
1. On the Latest Run tab of your services workspace, make sure that the Plan was successful and then click the "Confirm and Apply" button to actually remove the cats-and-dogs pods and services as well as the service account and namespace.
