# Openshift Cluster in AWS
This guide provisions an OpenShift Origin 3.11 cluster in AWS with 1 master node, 1 client node, and 1 bastion host. It uses Terraform's [AWS Provider](https://www.terraform.io/docs/providers/aws/index.html) to provision AWS infrastructure. It then uses ansible-playbook to deploy OpenShift to the master and client nodes from the bastion host after using Terraform to provision the AWS infrastructure. It is based on a [terraform-aws-openshift](https://github.com/dwmkerr/terraform-aws-openshift) repository created by Dave Kerr.

It was written for use with Terraform 0.11.x.

While the original repository required the user to manually run ansible-playbook after provisioning the AWS infrastructure with Terraform, this guide uses a Terraform [remote-exec provisioner](https://www.terraform.io/docs/provisioners/remote-exec.html) to do that. It also uses several additional remote-exec and local-exec provisioners to automate the rest of the deployment, retrieve the OpenShift cluster keys, and write them to outputs. This is important since it allows workspaces that deploy pods and services to the cluster do that via workspace state sharing without any manual copying of the cluster keys.

## Reference Material
* [OpenShift Origin](https://www.openshift.org/): the open source version of OpenShift, Red Hat's commercial implementation of Kubernetes.
* [Kubernetes](https://kubernetes.io/): the open source system for automating deployment and management of containerized applications.
* [openshift-ansible](https://github.com/openshift/openshift-ansible/tree/release-3.11): Ansible roles and playbooks for installing and managing OpenShift 3.11 clusters with Ansible.
* [ansible-playbook](https://docs.ansible.com/ansible/2.4/ansible-playbook.html): the actual ansible tool used to deploy the OpenShift cluster. This is used in the install-from-bastion.sh script.

## Estimated Time to Complete
120 minutes

## Personas
Our target persona is a developer or operations engineer who wants to provision an OpenShift cluster into AWS.

## Challenge
The [installation method](https://docs.openshift.com/container-platform/3.11/install/index.html) for OpenShift uses ansible-playbook to deploy OpenShift. Before doing that, the deployer must first provision some infrastructure and then configure an Ansible inventory file with suitable settings. Typically, ansible-playbook would be manually run on a bastion host even if a tool like Terraform had been used to provision the infrastructure.

## Solution
This guide combines and completely automates the two steps mentioned above:
1. Provisioning the AWS infrastructure.
1. Deploying OpenShift with Ansible
Additionally, it retrieves dynamically generated AWS keys from a [Vault](https://www.vaultproject.io/) server using Vault's [AWS Secrets Engine](https://www.vaultproject.io/docs/secrets/aws/index.html) and provisions and configures an instance of Vault's [Kubernetes Auth Method](https://www.vaultproject.io/docs/auth/kubernetes.html) so that pods provisioned by other workspaces can authenticate themselves against it. A vault-reviewer service account is provisioned for use by the Kubernetes auth method using a remote-exec provisioner.

Note that this guide is intended for demo and development usage. You would probably want to make modifications to the Terraform code for production usage including provisioning additional nodes.

## Prerequisites
1. Sign up for a free [AWS](https://aws.amazon.com/free/) account.
1. Create AWS access keys for your account. See the [Managing Access Keys for Your AWS Account](https://docs.aws.amazon.com/general/latest/gr/managing-aws-access-keys.html).
1. Create an AWS key pair for your AWS account. See [Amazon EC2 Key Pairs](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html).
1. Use a Vault server with version 1.2 or higher.

## Steps
Execute the following commands to deploy your OpenShift cluster to AWS.

### Step 1: Set Up and Configure a Vault Server
1. Set up a Vault server if you do not already have access to one and determine your username, password, and associated Vault token. See the [Vault Provisioning Guide](https://github.com/hashicorp/vault-guides/tree/master/operations/provision-vault) for a options for setting up Vault servers.
1. We assume that the [Userpass auth method](https://www.vaultproject.io/docs/auth/userpass.html) is enabled on your Vault server.  If not, that is ok.  You can login to the Vault UI with your Vault token instead of your username. Wherever the Terraform-specific instructions below ask you to specify your Vault username, just make one up for yourself.
1. Your Vault username and token will need to have a Vault policy like [sample-policy.hcl](./sample-policy.hcl) associated with them. You could use this one after changing "roger" to your username and renaming the file to \<username\>-policy.hcl.  Run `vault write sys/policy/<username> policy=@<username>-policy.hcl` to import the policy to your Vault server. Then run `vault write auth/userpass/users/<username> policies="<username>"` to associate the policy with your username. (If you already have other policies associated with the user, then be sure to include those policies in the list of policies with commas between them.)
1. To create a new token valid for 30 days and associate the policy with it, run `vault token create -display-name=<username>-token -policy=<username> -ttl=720h`.
1. Set up the Vault AWS Secrets Engine following these commands:
```
vault secrets enable -path=aws-tf aws

vault write aws-tf/config/root \
  access_key=<your_aws_access_key> \
  secret_key=<your_aws_secret_key> \
  region=us-east-1

vault write aws-tf/roles/deploy policy_document=-<<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["ec2:*","iam:*","route53:*"],
      "Resource": "*"
    }
  ]
}
EOF
```

### Step 2: Set Up and Configure Terraform Enterprise

1. If you do not already have a Terraform Enterprise (TFE) account, self-register for an evaluation at https://app.terraform.io/account/new.
1. After getting access to your TFE account, create an organization for yourself. You might also want to review the [Getting Started](https://www.terraform.io/docs/enterprise/getting-started/index.html) documentation.
1. Connect your TFE organization to GitHub. See the [Configuring GitHub Access](https://www.terraform.io/docs/enterprise/vcs/github.html) documentation.

If you want to use open source Terraform instead of TFE, you can create a copy of the included openshift.tfvars.example file, calling it openshift.auto.tfvars, set values for the variables in it, run `terraform init`, and then run `terraform apply`.

### Step 3: Configure a Terraform Enterprise Workspace
1. Fork this repository by clicking the Fork button in the upper right corner of the screen and selecting your own personal GitHub account or organization.
1. Create a workspace in your TFE organization called k8s-cluster-openshift.
1. Configure the workspace to connect to the fork of this repository in your own GitHub account.
1. Set the Terraform Working Directory to "infrastructure-as-code/k8s-cluster-openshift-aws".
1. On the Variables tab of your workspace, add the following variables to the Terraform variables: **key_name**, **private_key_data**, **vault_addr**, **vault_user**, and **vault_k8s_auth_path**. The first of these must be the name of the key pair you created above. The second must be the actual contents of the private key you downloaded as a pem file.  Be sure to mark this variable as sensitive so that it will not be visible after you save your variables. Set vault_addr to the address of your Vault server (e.g., "http://<your_vault_dns>:8200") and vault_user to your username on your Vault server. Finally, set vault_k8s_auth_path to something like "\<your username\>-openshift".
1. HashiCorp SEs should also set the owner and ttl variables which are used by the AWS Lambda reaper function that terminates old EC2 instances.
1. Set the **VAULT_TOKEN** environment variable to your Vault token. Be sure to mark the VAULT_TOKEN variable as sensitive so that other people cannot read it.

### Step 4: Provision Your OpenShift Cluster
1. Click the "Queue Plan" button in the upper right corner of your workspace.
1. On the Latest Run tab, you should see a new run. If the plan succeeds, you can view the plan and verify that the AWS infrastructure will be created and that various remote-exec and local-exec provisioners will run when you apply your plan.
1. Click the "Confirm and Apply" button to actually provision your OpenShift cluster.

Unfortunately, the Ansible playbook that provisions the OpenShift cluster takes 80-90 minutes to do it.  To accomodate this, we have set the `max_lease_ttl_seconds` attribute on the Vault provider to 7200 seconds (2 hours).

When the Ansible playbook finally deploys the OpenShift cluster and a few other null resources are run by Terraform, you will see outputs providing the IPs and DNS addresses needed to access your OpenShift cluster in the AWS Console, TLS certs/keys for your cluster, the Vault Kubernetes auth method path, the Vault server address, and your Vault username. You will need these when using Terraform's Kubernetes Provider to provision Kubernetes pods and services in other workspaces that use your OpenShift cluster. You can also validate that the cluster was created in the AWS Console.

You will be able to login to the OpenShift Console with username "admin" and password "123" at the URL contained in the k8s_endpoint output of the apply.log. To use the OpenShift `oc` CLI utility, you may SSH into the bastion host using `bastion_public_ip` output, then to the OpenShift master server using `master_private_ip` output from the apply log.

## Next Steps
You can now use the guide in the [k8s-services-openshift](../../self-serve-infrastructure/k8s-services-openshift) directory of this repository to provision some pods and services against your OpenShift cluster. The workspace you configure in that guide will automatically use the outputs generated in the state of the k8s-cluster-openshift workspace through Terraform's workspace state sharing.

## Cleanup
Execute the following steps to delete your OpenShift cluster and associated resources from AWS.

1. On the Variables tab of your k8s-cluster-openshift workspace, add the environment variable CONFIRM_DESTROY with value 1.
1. At the bottom of the Settings tab of your workspace, click the "Queue destroy plan" button to make TFE do a destroy run.
1. On the Latest Run tab of your workspace, make sure that the Plan was successful and then click the "Confirm and Apply" button to actually destroy your OpenShift cluster and other resources that were provisioned by Terraform.
