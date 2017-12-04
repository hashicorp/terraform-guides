# Kubernetes in Google Container Engine (GKE)
Terraform configuration for deploying Kubernetes in [GKE](https://cloud.google.com/container-engine/).

## Introduction
This Terraform configuration will deploy a Kubernetes cluster into Google's managed Kubernetes service, Google Container Engine (GKE). (The acronym GKE is used because GCE is used for Google Compute Engine, Google's IaaS service.) It will use the google_container_cluster resource to create an entire Kubernetes cluster in GKE.

## Deployment Prerequisites

1. Sign up for a free [Google Cloud Platform](https://cloud.google.com) account. But if you're a HashiCorp employee, you should login to the Google Cloud using your HashiCorp account.
1. Visit the [Container Engine page](https://console.cloud.google.com/projectselector/kubernetes?_ga=2.262292879.-2027610234.1509054055) in the Google Cloud Platform to enable the Google Container Engine API in your project.
1. Create or select a project.
1. Enable billing for your project if it is not already enabled.
1. Install and configure the Google [Cloud SDK](https://cloud.google.com/sdk). In addition to downloading and extracting it, be sure to run the `google-cloud-sdk/install.sh` script and restart your Terminal. Also run `gcloud init` and follow the prompts to initialize the SDK.
1. Follow these [instructions](https://www.terraform.io/docs/providers/google/index.html#authentication-json-file) to download an authentication JSON file for your project.
1. You should probably also run `gcloud config set compute/zone <zone>` and `gcloud config set project <project>` to set your default compute zone and project.
1. Create a copy of k8s.tfvars.example called k8s.tfvars and set the correct value for gcp_project.  You can also change the values for gcp_region and gcp_zone in k8s.tfvars if you want.


## Deployment Steps
Execute the following commands to deploy your Kubernetes cluster to GKE:

1. Run `terraform init` to initialize your terraform-gke configuration.
1. Run `terraform plan -var-file="k8s.tfvars"` to do a Terraform plan.
1. Run `terraform apply -var-file="k8s.tfvars"` to do a Terraform apply.

## Cleanup
Execute the following command to delete your Kubernetes cluster and associated resources from GKE.

1. Run `terraform destroy -var-file="k8s.tfvars"` to destroy the GKE cluster and other resources that were provisioned by Terraform.
