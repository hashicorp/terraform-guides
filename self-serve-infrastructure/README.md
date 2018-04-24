# Self Service Infrastructure
The examples in this directory illustrate how Terraform can be used to support self service Infrastructure.

## getting-started
This directory includes some examples of provisioning networking infrastructure in AWS, Azure, and Google.

## k8s-services
This Terraform example can be used to provision a web application and redis database as Kubernetes pods to a Kubernetes cluster.  It is intended to be used with the [k8s-cluster-acs](../infrastructure-as-code/k8s-cluster-acs) and [k8s-cluster-gke](../infrastructure-as-code/k8s-cluster-gke) examples which provision Kubernetes clusters into Azure Container Service and Google Kubernetes Engine. But it could be used with other Kubernetes clusters too.

## k8s-services-openshift
This Terraform example can be used to provision a web application and redis database as Kubernetes pods to an OpenShift cluster.  It differs slightly from the k8s-services example because OpenShift service accounts each have two secrets, preventing the service_account resource of the Kubernetes provider from being used. It is intended to be used with the [k8s-cluster-openshift-aws](../infrastructure-as-code/k8s-cluster-openshift-aws) example which provisions an OpenShift 3.7 cluster into AWS.

## cats-and-dogs
This directory contains the source code and docker files for the cats-and-dogs frontend and backend pods provisioned by the k8s-services and k8s-services-openshift Terraform code.  
