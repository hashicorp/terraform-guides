# Terraform Guides
This repository contains sample Terraform configurations, Sentinel policies, and automation scripts that can be used with Terraform Enterprise.

## infrastructure-as-code
This directory contains sample Terraform configurations to provision VMs into AWS, Azure, and Google Cloud Platoform (GCP) as well as Kubernetes clusters into Azure Container Service (ACS) and Google Kubernetes Engine (GKE).

## self-serve-infrastructure
This directory contains sample Terraform configurations to enable self service infrastructure. In particular, it illustrates how developers can deploy applications to Kubernetes clusters provisioned by an operations team.

## governance
This directory contains some sample Sentinel policies for several clouds which ensure that all infrastructure provisioned with Terraform Enterprise complies with an organization's provisioning rules.

## operations
This directory provides artifacts that can be used by operations teams using Terraform Enterprise. In particular, it includes a scripy that shows how the Terraform Enterprise REST API can be used to automate interactions with Terraform Enterprise.

## cloud-management-platform
This directory provides samples of how Terraform can be used to support cloud management platforms.

## `gitignore.tf` Files

You may notice some [`gitignore.tf`](operations/provision-consul/best-practices/terraform-aws/gitignore.tf) files in certain directories. `.tf` files that contain the word "gitignore" are ignored by git in the [`.gitignore`](./.gitignore) file.

If you have local Terraform configuration that you want ignored (like Terraform backend configuration), create a new file in the directory (separate from `gitignore.tf`) that contains the word "gitignore" (e.g. `backend.gitignore.tf`) and it won't be picked up as a change.
