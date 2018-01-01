# Source Code for Cats-and-Dogs Applications
The source code for the Cats-and-Dogs applications deployed to Kubernetes pods and services using the Terraform [k8s-services](../k8s-services) configuration.

## Backend
The cats-and-dogs-backend application runs a redis database that stores votes recorded by users of the cats-and-dogs-frontend web application. It authenticates itself to a Vault server with the Kubernetes JWT service account token, reads the redis_pwd from Vault, and then starts the redis database with that password.

## Frontend
The cats-and-dogs-frontend application is a simple Python web application that lets users vote for their favorite pets.  It authenticates itself to a Vault server with the Kubernetes JWT service account token, reads the redis_pwd from Vault, and then connects to the redis database running in the cats-and-dogs-backend pod with that password.
