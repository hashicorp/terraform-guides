# Openshift/Kubernetes Cluster in AWS
This guide provisions an OpenShift 3.7 cluster in AWS with 1 master node, 1 client node, and 1 bastion host. It uses ansible-playbook to deploy OpenShift after using Terraform to provision the AWS infrastructure. It is based on a [terraform-aws-openshift](https://github.com/dwmkerr/terraform-aws-openshift) repository created by Dave Kerr.

## Introduction
While the original repository required the user to manually run ansible-playbook after provisioning the AWS infrastructure with Terraform, this guide uses a Terraform remote-exec provisioner to do that. It also uses several additional remote-exec and local-exec provisioners to automate the rest of the deployment, retrieve the OpenShift cluster keys, and write them to outputs. This is important since it allows workspaces that deploy pods and services to the cluster do that via workspace state sharing without any manual copying of the cluster keys.

This guide retrieves dynamically generated AWS keys from a Vault server using Vault's [AWS Secrets Engine](https://www.vaultproject.io/docs/secrets/aws/index.html). Additionally, it provisions and configures an instance of Vault's [Kubernetes Auth Method](https://www.vaultproject.io/docs/auth/kubernetes.html) so that pods provisioned by other workspaces can authenticate themselves against it. A vault-reviewer service account is provisioned for use by the Kubernetes auth method.

## Deployment Prerequisites
1. Sign up for a free [AWS](https://aws.amazon.com/free/) account.
1. Create AWS access keys for your account. See the [Managing Access Keys for Your AWS Account](https://docs.aws.amazon.com/general/latest/gr/managing-aws-access-keys.html).
1. Create an AWS key pair for your AWS account. See [Amazon EC2 Key Pairs](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html).
1. Set up a Vault server if you do not already have access to one and determine your username, password, and associated Vault token.
1. We assume that the [Userpass auth method](https://www.vaultproject.io/docs/auth/userpass.html) is enabled on your Vault server.  If not, that is ok.  You will login to the Vault UI with your Vault token instead of with your username. Wherever the Terraform-specific instructions below ask you to specify your Vault username, just make one up for yourself.
1. Your Vault username and token will need to have a Vault policy like [sample-policy.hcl](./sample-policy.hcl) associated with them. You could use this one after changing "roger" to your username and renaming the file to \<username\>-policy.hcl.  Run `vault write sys/policy/<username> policy=@<username>-policy.hcl` to import the policy to your Vault server. Then run `vault write auth/userpass/users/<username> policies="<username>"` to associate the policy with your username. (If you already have other policies associated with the user, then be sure to include those policies in the list of policies with commas between them.) To create a new token valid for 30 days and associate the policy with it, run `vault token create -display-name="<username>-token" -policy="<username>" -ttl=720h`.
1. Set up the Vault AWS Secrets Engine following these commands:
```
vault secrets enable -path=aws-tf aws
vault write aws-tf/config/root \
  access_key=<your_aws_access_key>
  secret_key=<your_aws_secret_key>
  region=us-east-1
vault write aws-tf/roles/deploy policy=-<<EOF
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
1. If you do not already have a Terraform Enterprise (TFE) account, request one from sales@hashicorp.com.
1. After getting access to your TFE account, create an organization in it. Click the Cancel button when prompted to create a new workspace.
1. Configure your TFE organization to connect to GitHub. See this [doc](https://www.terraform.io/docs/enterprise/vcs/github.html).

## Deployment Steps
Execute the following commands to deploy your OpenShift cluster to AWS.

1. Fork this repository by clicking the Fork button in the upper right corner of the screen and selecting your own personal GitHub account or organization.
1. Clone the fork to your laptop by running `git clone https://github.com/<your_github_account>/terraform-guides.git`.
1. Create a workspace in your TFE organization called k8s-cluster-openshift.
1. Configure the workspace to connect to the fork of this repository in your own Github account.
1. Set the Terraform Working Directory to "infrastructure-as-code/k8s-cluster-openshift-aws".
1. On the Variables tab of your workspace, add the following variables to the Terraform variables: key_name, private_key_data, vault_addr, vault_user, and vault_k8s_auth_path. The first of these must be the name of the key pair you created above. The second must be the actual contents of the private key you downloaded as a pem file.  Be sure to mark this variable as sensitive so that it will not be visible after you save your variables. Set vault_addr to the address of your Vault server (e.g., "http://<your_vault_dns>:8200") and vault_user to your username on your Vault server. Finally, set vault_k8s_auth_path to something like "<your username>-openshift".
1. Set the VAULT_TOKEN environment variable to your Vault token. Be sure to mark the VAULT_TOKEN variable as sensitive so that other people cannot read it.
1. Click the "Queue Plan" button in the upper right corner of your workspace.
1. On the Latest Run tab, you should see a new run. If the plan succeeds, you can view the plan and verify that the AWS infrastructure will be created and that various remote-exec and local-exec provisioners will run when you apply your plan.
1. Click the "Confirm and Apply" button to actually provision your OpenShift cluster.

You will see outputs providing the IPs and DNS addresses needed to access your OpenShift cluster in the AWS Console, TLS certs/keys for your cluster, the Vault Kubernetes auth method path, the Vault server address, and your Vault username. You will need these when using Terraform's Kubernetes Provider to provision Kubernetes pods and services in other workspaces that use your OpenShift cluster. However, if you configure a workspace against the Terraform code in the [k8s-services-openshift-aws](../../self-serve-infrastructure/k8s-services-openshift-aws) directory of this repository to provision your pods and services, the outputs will automatically be used by that workspace through Terraform state sharing.

You can also validate that the cluster was created in the AWS Console.

## Cleanup
Execute the following steps for your workspaces to delete your OpenShift cluster and associated resources from AWS.

1. On the Variables tab of your workspace, add the environment variable CONFIRM_DESTROY with value 1.
1. At the bottom of the Settings tab of your workspace, click the "Queue destroy plan" button to make TFE do a destroy run.
1. On the Latest Run tab of your workspace, make sure that the Plan was successful and then click the "Confirm and Apply" button to actually destroy your OpenShift cluster and other resources that were provisioned by Terraform.
