#!/usr/bin/env bash

set -x
exec > /home/ec2-user/install-openshift.log 2>&1

# Install dev tools and Ansible 2.2
sudo yum install -y "@Development Tools" python2-pip openssl-devel python-devel gcc libffi-devel
sudo pip install -Iv ansible==2.6.5

# Clone the openshift-ansible repo, which contains the installer.
#git clone -b release-3.11 https://github.com/openshift/openshift-ansible

# Using specific commit since later one made it illegal to use the openshift_hostname variable
git clone -n https://github.com/openshift/openshift-ansible
cd openshift-ansible
git checkout 7c8b4f07a46089640bc61b8a9b35fd8b5ed86245
cd ..


# Set up bastion to SSH to other servers
echo "${private_key}" > /home/ec2-user/.ssh/private-key.pem
chmod 400 /home/ec2-user/.ssh/private-key.pem
#chown ec2-user:ec2-user /home/ec2-user/.ssh/private-key.pem
eval $(ssh-agent)
ssh-add /home/ec2-user/.ssh/private-key.pem
#ssh-keyscan -t rsa -H master.${name_tag_prefix}-openshift.local >> /home/ec2-user/.ssh/known_hosts
#ssh-keyscan -t rsa -H node1.${name_tag_prefix}-openshift.local >> /home/ec2-user/.ssh/known_hosts

# Create inventory.cfg file
#cat > /home/inventory.cfg << EOF
cat > /home/ec2-user/inventory.cfg << EOF
# Waited: ${wait} seconds before generating from template
# Create an OSEv3 group that contains the masters and nodes groups
[OSEv3:children]
masters
nodes
etcd

# Set variables common for all OSEv3 hosts
[OSEv3:vars]

# Enable use of testing repos so that 3.7 will be used
#openshift_repos_enable_testing=true

# SSH user, this user should allow ssh based auth without requiring a password
ansible_ssh_user=ec2-user

# If ansible_ssh_user is not root, ansible_become must be set to true
ansible_become=true

# Deploy OpenShift origin.
openshift_deployment_type=origin

# OpenShift Release
openshift_release=v3.11

# We need a wildcard DNS setup for our public access to services, fortunately
# we can use the superb xip.io to get one for free.
# ${master_ip}
openshift_public_hostname=${master_ip}.xip.io
openshift_master_default_subdomain=${master_ip}.xip.io

# Use an htpasswd file as the indentity provider.
openshift_master_identity_providers=[{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider'}]
#, 'filename': '/etc/origin/master/htpasswd'

# Uncomment the line below to enable metrics for the cluster.
# openshift_hosted_metrics_deploy=true

# Set the cluster_id.
openshift_clusterid="openshift-cluster-${region}"

# Define the standard set of node groups, as per:
#   https://github.com/openshift/openshift-ansible#node-group-definition-and-mapping
openshift_node_groups=[{'name': 'node-config-master', 'labels': ['node-role.kubernetes.io/master=true']}, {'name': 'node-config-infra', 'labels': ['node-role.kubernetes.io/infra=true']}, {'name': 'node-config-compute', 'labels': ['node-role.kubernetes.io/compute=true']}, {'name': 'node-config-master-infra', 'labels': ['node-role.kubernetes.io/infra=true,node-role.kubernetes.io/master=true']}, {'name': 'node-config-all-in-one', 'labels': ['node-role.kubernetes.io/infra=true,node-role.kubernetes.io/master=true,node-role.kubernetes.io/compute=true']}]


#openshift_enable_service_catalog=false
#template_service_broker_install=false

#openshift_template_service_broker_namespaces=['openshift']

#openshift_master_api_port=8443
#openshift_master_console_port=8443

# Create the masters host group. Be explicit with the openshift_hostname,
# otherwise it will resolve to something like ip-10-0-1-98.ec2.internal and use
# that as the node name.
[masters]
master.${name_tag_prefix}-openshift.local openshift_hostname=master.${name_tag_prefix}-openshift.local

# host group for etcd
[etcd]
master.${name_tag_prefix}-openshift.local openshift_hostname=master.${name_tag_prefix}-openshift.local

# host group for nodes, includes region info
[nodes]
master.${name_tag_prefix}-openshift.local openshift_hostname=master.${name_tag_prefix}-openshift.local openshift_node_group_name='node-config-master-infra' openshift_schedulable=true
node1.${name_tag_prefix}-openshift.local openshift_hostname=node1.${name_tag_prefix}-openshift.local openshift_node_group_name='node-config-compute'
EOF

# Change ownership of file to ec2-user
#sudo chown ec2-user:ec2-user /home/ec2-user/inventory.cfg

# Run the playbook.
#ANSIBLE_HOST_KEY_CHECKING=False /usr/local/bin/ansible-playbook -i ~/inventory.cfg ~/openshift-ansible/playbooks/byo/config.yml

ANSIBLE_HOST_KEY_CHECKING=False /usr/local/bin/ansible-playbook -i ~/inventory.cfg ./openshift-ansible/playbooks/prerequisites.yml
ANSIBLE_HOST_KEY_CHECKING=False /usr/local/bin/ansible-playbook -i ~/inventory.cfg ./openshift-ansible/playbooks/deploy_cluster.yml

# uncomment for verbose! -vvv

# If needed, uninstall with the below:
# ansible-playbook playbooks/adhoc/uninstall.yml
