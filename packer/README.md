# Terraform Packer
This folder contains Packer files to build resources for Terraform.  Note these are NOT the old AMI releases of pTFE.

## pTFE
This Packer file builds a basic pTFE install OVF for use with VirtualBox or VMWare.  It's a quick way to do onprem evals or travelling airgapped demos.  After provisioning the OVF don't forget to set the network on a VM and also upate /etc/sysconfig/replicated IP address used for pTFE.
