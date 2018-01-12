# Infrastructure as Code Examples
The Terraform code in the directories under this one provide examples for provisioning infrastructure into AWS, Azure, and Google Cloud Platform (GCP).

## aws-ec2-instance
This example provides a simple example to provision an EC2 instance running Ubuntu in AWS.

## azure-vm
This example provides a simple example to provision an Azure Windows VM and required resources in Azure. Note that it uses a module from the public [Terraform Module Registry](https://registry.terraform.io/).

## gcp-compute-instance
This example provides a simple example to provision a Google compute instance in GCP.

## k8s-cluster-acs
This example illustrates how you can provision an Azure Container Service (ACS) cluster. If you use this, also check out the [k8s-services](../self-serve-infrastructure) directory which lets you provision a web app and redis database as Kubernetes pods to the cluster.

## k8s-cluster-gke
This example illustrates how you can provision a Google Kubernetes Engine (GKE) cluster. If you use this, also check out the [k8s-services](../self-serve-infrastructure) directory which lets you provision a web app and redis database as Kubernetes pods to the cluster.
