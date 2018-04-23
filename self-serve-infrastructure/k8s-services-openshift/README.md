# OpenShift Pods and Services
Terraform configuration for deploying OpenShift pods and services to existing OpenShift clusters.

## Introduction
This Terraform configuration deploys two pods exposed as services. It is meant to be used in Terraform Enterprise (TFE). The first runs a python application called "cats-and-dogs-frontend" that lets users vote for their favorite type of pet. It stores data in the second, "cats-and-dogs-backend", which runs a redis database. The Terraform configuration replicates what a user could do with the [Kubernetes CLI](https://kubernetes.io/docs/tasks/tools/install-kubectl/), `kubectl`.

It uses the kubernetes_pod and kubernetes_service resources of Terraform's Kubernetes Provider to deploy the pods and services into an OpenShift cluster previously provisioned by Terraform. It also uses the terraform_remote_state data source to copy the outputs of the targeted cluster's TFE workspace directly into the Kubernetes Provider block, avoiding the need to manually copy the outputs into variables of the TFE services workspace. It also uses the vault_addr, vault_user, and vault_k8s_auth_backend outputs from the cluster workspace. Note that it also uses a remote-exec provisioner to create an OpenShift project (namespace) called "cats-and-dogs" and a Kubernetes service account called "cats-and-dogs" which the pods use. After doing that, it uses additional provisioners to retrieve the JWT token of the cats-and-dogs service account from OpenShift.

Another important aspect of this configuration is that both the frontend application and the redis database get the redis password from a Vault server after using the Kubernetes JWT token of the cats-and-dogs service account to authenticate against Vault's [Kubernetes Auth Method](https://www.vaultproject.io/docs/auth/kubernetes.html). This has the benefits that the redis password is not stored in the Terraform code and that neither the application developers nor the DBAs managing Redis will actually know what the redis password is. Only the security team that stores the password in Vault will know. The redis_db password is stored in the Vault server under "secret/<vault_user>/kubernetes/cats-and-dogs" where \<vault_user\> is the Vault username.

## Deployment Prerequisites

1. First deploy an OpenShift cluster with Terraform by using the Terraform code in the [k8s-cluster-openshift-aws](../../infrastructure-as-code/k8s-cluster-openshift-aws) directory of this repository and pointing a TFE workspace against it.  
1. We assume that you have already satisfied all the prerequisites for deploying an OpenShift cluster described by the above link.
1. We also assume that you have already forked this repository and cloned your fork to your laptop.

## Deployment Steps
Execute the following commands to deploy the pods and services to your OpenShift cluster:

1. Create a new TFE workspace called k8s-services-openshift.
1. Configure your workspace to connect to the fork of this repository in your own GitHub account.
1. Set the Terraform Working Directory to "self-serve-infrastructure/k8s-services-openshift"
1. Set the tfe-organization variable in your workspace to the name of the TFE organization containing your OpenShift cluster workspace.
1. Set the k8s-cluster-workspace variable in your workspace to the name of the workspace you used to deploy your OpenShift cluster.
1. Queue a plan for the services workspace in TFE.
1. Confirm that you want to apply the plan.
1. Finally, enter the cats_and_dogs_dns output in a browser. You should see the "Pets Voting App" page.
1. Vote for your favorite pets.

## Cleanup
Execute the following steps to delete the cats-and-dogs pods and services from your OpenShift cluster.

1. Define an environment variable CONFIRM_DESTROY with value 1 on the Variables tab of your services workspace.
1. Queue a Destroy plan in T:FE from the Settings tab of your services workspace.
1. On the Latest Run tab of your services workspace, make sure that the Plan was successful and then click the "Confirm and Apply" button to actually remove the cats-and-dogs pods and services.
