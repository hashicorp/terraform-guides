#!/usr/bin/env bash

# Note: This script runs after the ansible install, use it to make configuration
# changes which would otherwise be overwritten by ansible.

sleep 120

# Create an htpasswd file, we'll use htpasswd auth for OpenShift.
sudo htpasswd -cb /etc/origin/master/htpasswd admin 123
oc adm policy add-cluster-role-to-user cluster-admin admin

# Update the docker config to allow OpenShift's local insecure registry. Also
# use json-file for logging, so our Splunk forwarder can eat the container logs.
# json-file for logging
sudo sed -i '/OPTIONS=.*/c\OPTIONS="--selinux-enabled --insecure-registry 172.30.0.0/16 --log-driver=json-file --log-opt max-size=1M --log-opt max-file=3"' /etc/sysconfig/docker
sudo systemctl restart docker
