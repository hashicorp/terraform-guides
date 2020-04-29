# OpenShift Pods and Services
This guide gives an example of deploying OpenShift pods and services to an existing OpenShift cluster with Terraform Enterprise (TFE). It deploys two pods exposed as services:  The first runs a python application called "cats-and-dogs-frontend" that lets users vote for their favorite type of pet. It stores data in the second, "cats-and-dogs-backend", which runs a redis database. Before provisioning the pods, it provisions an OpenShift project (namespace) called "cats-and-dogs" and a Kubernetes service account called "cats-and-dogs" which the pods use. The two pods retrieve a shared database password from Vault.

It was written for use with Terraform 0.11.x.

The source code and docker files for the applications is in the [cats-and-dogs](../cats-and-dogs) directory of this repository.

## Reference Material
* [OpenShift Origin](https://www.openshift.org/): the open source version of OpenShift, Red Hat's commercial implementation of Kubernetes.
* [Kubernetes](https://kubernetes.io/): the open source system for automating deployment and management of containerized applications.
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/): the Kubernetes CLI.
* [Kubernetes Pods](https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/): Docker containers are deployed in Kubernetes pods.
* [Kubernetes Services](https://kubernetes.io/docs/concepts/services-networking/service/): Pods are exposed as services.
* [Vault](https://www.vaultproject.io/): HashiCorp's secrets management solution.


## Estimated Time to Complete
20 minutes

## Personas
Our target persona is a developer who wants to provision containerized applications to an OpenShift cluster.

## Challenge
You would like to deploy some applications to an existing cluster that was already provisioned with Kubernetes, but you would rather not have to copy the cluster's URL, keys, and certificates to the Terraform workspace you will be using. Additionally, you need your Kubernetes applications to authenticate themselves to Vault and retrieve a shared secret.

## Solution
Terraform's [Kubernetes Provider](https://www.terraform.io/docs/providers/kubernetes/index.html), the  [terraform_remote_state](https://www.terraform.io/docs/providers/terraform/d/remote_state.html) data source, and the [Vault Kubernetes auth method](https://www.vaultproject.io/docs/auth/kubernetes.html) save you a lot of time and trouble.

This guide uses the kubernetes_pod and kubernetes_service resources of Terraform's Kubernetes Provider to deploy the pods and services into an OpenShift cluster previously provisioned by Terraform.

It also uses the terraform_remote_state data source to copy the outputs of the targeted cluster's TFE workspace directly into the Kubernetes Provider block, avoiding the need to manually copy the outputs into variables of the TFE services workspace. It also uses the vault_addr, vault_user, and vault_k8s_auth_backend outputs from the cluster workspace.

The guide also uses a remote-exec provisioner to create an OpenShift project and a Kubernetes service account (both called "cats-and-dogs") which the pods use. It then uses additional provisioners to retrieve the JWT token of the cats-and-dogs service account from OpenShift and to expose the cats-and-dogs-frontend service via an OpenShift route.

The frontend application and the redis database both get the redis password from a Vault server after using the Kubernetes JWT token of the cats-and-dogs service account to authenticate against Vault's Kubernetes Auth Method. This has the benefits that the redis password is not stored in any of the code (Terraform, application, or database) and that none of the application developers or DBAs will know it. Only the security team that stores the password in Vault will know. The redis_db password is stored in the Vault server under "secret/<vault_user>/kubernetes/cats-and-dogs" where \<vault_user\> is the Vault username.

## Prerequisites

1. First deploy an OpenShift cluster with Terraform by using the Terraform code in the [k8s-cluster-openshift-aws](../../infrastructure-as-code/k8s-cluster-openshift-aws) directory of this repository and pointing a TFE workspace against it.
1. We assume you have already fulfilled all the prerequisites of that guide including configuration of your Vault server and creation of the redis_pwd key under the path "secret/\<user\>/kubernetes/cats-and-dogs".
1. Use a Vault server with version 1.2 or higher.


## Steps
Execute the following commands to deploy the pods and services to your OpenShift cluster.

If you want to use open source Terraform instead of TFE, you can create a copy of the included openshift.tfvars.example file, calling it openshift.auto.tfvars, set values for the variables in it, run `terraform init`, and then run `terraform apply`.

### Step 1: Create and Configure a Workspace
1. Create a new TFE workspace called k8s-services-openshift.
1. Configure your workspace to connect to the fork of this repository in your own GitHub account.
1. Set the Terraform Working Directory to "self-serve-infrastructure/k8s-services-openshift"
1. Set the **tfe_organization** Terraform variable in your workspace to the name of the TFE organization containing your OpenShift cluster workspace.
1. Set the **k8s_cluster_workspace** Terraform variable in your workspace to the name of the workspace you used to deploy your OpenShift cluster.
1. Set the **private_key_data** Terraform variable in your workspace to include the contents of the private key file you used when provisioning the cluster.  This is needed since the Terraform code uses a remote-exec provisioner to create the project and service account with the `oc` and `kubectl` CLIs respectively. (The service_account resource of the Kubernetes provider cannot be used in this case because OpenShift creates service accounts with two secrets while the resource expects each service account to only have one secret.)

### Step 2: Change the Redis Password
1. Login to the Vault UI using your username and password (or token if the userpass authentication method is not enabled).
1. Change the value of the redis_pwd key under the path "secret/\<user\>/kubernetes/cats-and-dogs" to some arbitrary string containing letters and numbers.

### Step 3: Plan and Apply the Deployment of the Pods and Services
1. Queue a plan for the k8s-services-openshift workspace in TFE.
1. Confirm that you want to apply the plan.

### Step 4: Run the Cats-and-Dogs Application
1. Enter the cats_and_dogs_dns output in a browser. You should see the "Pets Voting App" page.
1. Vote for your favorite pets.

### Step 5: (Optional) Check the OpenShift Pod Logs
1. If you wish, you can examine the logs of the the two pods in the OpenShift Console.
1. Point your browser to the k8s_endpoint output of your cluster workspace.
1. Login with username "admin" and password "123".
1. Select the cats-and-dogs project.
1. Select Pods from the Applications tab on the left-side menu.
1. Select Logs for the cats-and-dogs-frontend pod and verify that the redis password is the one you set in Vault.
1. Select Logs for the cats-and-dogs-backend pod and verify that the redis password is the one you set in Vault.

## Next Steps
You can now examine the code of the [cats-and-dogs-frontend](../cats-and-dogs/frontend/azure-vote/main.py) and [cats-and-dogs-backend](../cats-and-dogs/backend/vote-db/start_redis.sh) applications to understand how they authenticate themselves to Vault and read the redis_pwd secret.

## Cleanup
Execute the following steps to delete the cats-and-dogs pods and services from your OpenShift cluster.

1. Define an environment variable CONFIRM_DESTROY with value 1 on the Variables tab of your k8s-services-openshift workspace.
1. Queue a Destroy plan in TFE from the Settings tab of your workspace.
1. On the Latest Run tab of your workspace, make sure that the Plan was successful and then click the "Confirm and Apply" button to actually remove the cats-and-dogs pods, and services.
1. Additionally, you should manually delete the cats-and-dogs project in the OpenShift Application Console. This was created with the `oc` CLI using a remote-exec provisioner on a null resource and is not deleted by the destroy plan.
