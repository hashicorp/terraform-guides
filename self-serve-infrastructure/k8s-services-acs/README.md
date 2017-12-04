# Kubernetes Pods and Services
Terraform configuration for deploying Kubernetes pods and services to existing Kubernetes clusters in several public clouds.

## Introduction
This Terraform configuration deploys two pods exposed as services. It is meant to be used in Terraform Enterprise (TFE). The first runs a python application called "cats-and-dogs" that lets users vote for their favorite type of pet. It stores data in the second which runs a redis database. The Terraform configuration replicates what a user could do with the [Kubernetes CLI](https://kubernetes.io/docs/tasks/tools/install-kubectl/), `kubectl`.

It uses the kubernetes_pod and kubernetes_service resources of Terraform's Kubernetes Provider to deploy the pods and services into a Kubernetes cluster previously provisioned by Terraform. It also uses the terraform_remote_state data source to copy the outputs of the targeted cluster's TFE workspace directly into the Kubernetes Provider block, avoiding the need to manually copy the outputs into variables of the TFE services workspace. It also uses the vault_user output from the cluster's workspace outputs. Note that it also creates a Kubernetes service account called "cats-and-dogs" which the pods use.

Another important aspect of this configuration is that both the frontend application and the redis database get the redis password from a Vault server after using the JWT token of the cats-and-dogs service account to authenticate against Vault's Kubernetes Auth Backend. This has the benefits that the redis password is not stored in the Terraform code and that neither the application developers nor the DBAs managing Redis will actually know what the redis password is. Only the security team that stores the password in Vault will know. The redis_db password will be stored in the Vault server under "secret/<vault_user>/kubernetes/cats-and-dogs".

## Deployment Prerequisites

1. First deploy a Kubernetes cluster with Terraform by using one of these Terraform repositories and pointing a TFE workspace against it:
    - [tfe-k8s-cluster-gke](https://github.com/hashicorp/terraform-guides/tree/master/infrastructure-as-code/k8s-cluster-gke)
    - [tfe-k8s-cluster-acs](https://github.com/hashicorp/terraform-guides/tree/master/infrastructure-as-code/k8s-cluster-acs).
1. Set the tfe-organization variable in your workspace to the name of the TFE organization containing your Kubernetes cluster workspace.
1. Set the k8s-cluster-workspace variable in your workspace to the name of the workspace you used to deploy your k8s cluster.

## Deployment Steps
Execute the following commands to deploy the pods and services to GKE:

1. Queue a plan for the services workspace in TFE.
1. Confirm that you want to apply the plan.
1. Finally, enter the cats_and_dogs_ip output in a browser. You should see the "Pets Voting App" page.
1. Vote for your favorite pets.

## Cleanup

1. Queue a Destroy plan in TFE from the Settings tab of your services workspace.  Note that you must first define a Terraform variable CONFIRM_DESTROY with value 1 on the Variables tab.
