terraform {
  required_version = ">= 0.11.5"
}


# Set VAULT_TOKEN environment variable
provider "vault" {
  address = "${var.vault_addr}"
}

# AWS credentials from Vault
# Must set up AWS backend in Vault on path aws with role deploy
data "vault_aws_access_credentials" "aws_creds" {
  backend = "aws-tf"
  role = "deploy"
}

data "external" "region" {
  # Delay so that new keys are available across AWS
  program = ["./delay-vault-aws"]
}

# Vault Kubernetes Auth Backend
resource "vault_auth_backend" "k8s" {
  type = "kubernetes"
  path = "${var.vault_k8s_auth_path}"
  description = "Vault Auth Backend for OpenShift"
}

#  Setup the core provider information.
provider "aws" {
  access_key = "${data.vault_aws_access_credentials.aws_creds.access_key}"
  secret_key = "${data.vault_aws_access_credentials.aws_creds.secret_key}"
  region  = "${data.external.region.result["region"]}"
}

#  Create the OpenShift cluster using our module.
module "openshift" {
  source          = "./modules/openshift"
  region          = "${var.region}"
  amisize         = "t2.large" //  Smallest that meets OS specs
  vpc_cidr        = "10.0.0.0/16"
  subnetaz        = "${var.subnetaz}"
  subnet_cidr     = "10.0.1.0/24"
  key_name        = "${var.key_name}"
  private_key_data = "${var.private_key_data}"
}

resource "null_resource" "post-install-master" {
  provisioner "remote-exec" {
    script = "${path.root}/scripts/postinstall-master.sh"
    connection {
      host = "${module.openshift.master_public_dns}"
      type = "ssh"
      agent = false
      user = "ec2-user"
      private_key = "${var.private_key_data}"
      bastion_host = "${module.openshift.bastion_public_dns}"
    }
  }
}

resource "null_resource" "post-install-node1" {
  provisioner "remote-exec" {
    script = "${path.root}/scripts/postinstall-node.sh"
    connection {
      host = "${module.openshift.node1_public_dns}"
      type = "ssh"
      agent = false
      user = "ec2-user"
      private_key = "${var.private_key_data}"
      bastion_host = "${module.openshift.bastion_public_dns}"
    }
  }
}

resource "null_resource" "get_config" {
  provisioner "remote-exec" {
    inline = [
      "scp -o StrictHostKeyChecking=no -i ~/.ssh/private-key.pem ec2-user@${module.openshift.master_public_dns}:~/.kube/config ~/config"
    ]

    connection {
      host = "${module.openshift.bastion_public_dns}"
      type = "ssh"
      agent = false
      user = "ec2-user"
      private_key = "${var.private_key_data}"
    }
  }

  provisioner "local-exec" {
    command = "echo \"${var.private_key_data}\" > private-key.pem"
  }

  provisioner "local-exec" {
    command = "chmod 400 private-key.pem"
  }

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -i private-key.pem  ec2-user@${module.openshift.bastion_public_dns}:~/config config"
  }
  provisioner "local-exec" {
    command = "sed -n 4,4p config | cut -d ':' -f 2 | sed 's/ //' > ca_certificate"
  }
  provisioner "local-exec" {
    command = "sed -n 28,28p config | cut -d ':' -f 2 | sed 's/ //' > client_certificate"
  }
  provisioner "local-exec" {
    command = "sed -n 29,29p config | cut -d ':' -f 2 | sed 's/ //' > client_key"
  }

  depends_on = ["null_resource.post-install-master"]
}

resource "null_resource" "configure_k8s" {
  provisioner "file" {
    source = "vault-reviewer.yaml"
    destination = "~/vault-reviewer.yaml"
  }

  provisioner "file" {
    source = "vault-reviewer-rbac.yaml"
    destination = "~/vault-reviewer-rbac.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "kubectl create -f vault-reviewer.yaml",
      "kubectl create -f vault-reviewer-rbac.yaml",
      "kubectl get serviceaccount vault-reviewer -o yaml > vault-reviewer-service.yaml",
      "kubectl get secret $(grep \"vault-reviewer-token\" vault-reviewer-service.yaml | cut -d ':' -f 2 | sed 's/ //') -o yaml > vault-reviewer-secret.yaml",
      "sed -n 6,6p vault-reviewer-secret.yaml | cut -d ':' -f 2 | sed 's/ //' | base64 -d > vault-reviewer-token"
    ]
  }

  connection {
    host = "${module.openshift.master_public_dns}"
    type = "ssh"
    agent = false
    user = "ec2-user"
    private_key = "${var.private_key_data}"
    bastion_host = "${module.openshift.bastion_public_dns}"
  }

  depends_on = ["null_resource.get_config"]

}

resource "null_resource" "get_vault_reviewer_token" {
  provisioner "remote-exec" {
    inline = [
      "scp -o StrictHostKeyChecking=no -i ~/.ssh/private-key.pem ec2-user@${module.openshift.master_public_dns}:~/vault-reviewer-token vault-reviewer-token"
    ]

    connection {
      host = "${module.openshift.bastion_public_dns}"
      type = "ssh"
      agent = false
      user = "ec2-user"
      private_key = "${var.private_key_data}"
    }
  }

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -i private-key.pem  ec2-user@${module.openshift.bastion_public_dns}:~/vault-reviewer-token vault-reviewer-token"
  }

  depends_on = ["null_resource.configure_k8s"]
}

data "null_data_source" "get_certs" {
  inputs = {
    client_certificate = "${file("client_certificate")}"
    client_key = "${file("client_key")}"
    ca_certificate = "${file("ca_certificate")}"
    vault_reviewer_token = "${file("vault-reviewer-token")}"
  }
  depends_on = ["null_resource.get_vault_reviewer_token"]
}

resource "null_resource" "auth_config" {
  provisioner "local-exec" {
    command = "curl --header \"X-Vault-Token: $VAULT_TOKEN\" --header \"Content-Type: application/json\" --request POST --data '{ \"kubernetes_host\": \"https://${module.openshift.master_public_ip}.xip.io:8443\", \"kubernetes_ca_cert\": \"${chomp(replace(base64decode(data.null_data_source.get_certs.outputs["ca_certificate"]), "\n", "\\n"))}\", \"token_reviewer_jwt\": \"${data.null_data_source.get_certs.outputs["vault_reviewer_token"]}\" }' ${var.vault_addr}/v1/auth/${vault_auth_backend.k8s.path}config"
  }
}

resource "vault_generic_secret" "role" {
  path = "auth/${vault_auth_backend.k8s.path}role/demo"
  data_json = <<EOT
  {
    "bound_service_account_names": "cats-and-dogs",
    "bound_service_account_namespaces": "default, cats-and-dogs",
    "policies": "${var.vault_user}",
    "ttl": "24h"
  }
  EOT
}

//  Output some useful variables for quick SSH access etc.
output "master_url" {
  value = "https://${module.openshift.master_public_ip}.xip.io:8443"
}
output "master_public_dns" {
  value = "${module.openshift.master_public_dns}"
}
output "master_public_ip" {
  value = "${module.openshift.master_public_ip}"
}
output "bastion_public_dns" {
  value = "${module.openshift.bastion_public_dns}"
}
output "bastion_public_ip" {
  value = "${module.openshift.bastion_public_ip}"
}

output "k8s_endpoint" {
  value = "https://${module.openshift.master_public_ip}.xip.io:8443"
}

output "k8s_master_auth_client_certificate" {
  value = "${data.null_data_source.get_certs.outputs["client_certificate"]}"
}

output "k8s_master_auth_client_key" {
  value = "${data.null_data_source.get_certs.outputs["client_key"]}"
}

output "k8s_master_auth_cluster_ca_certificate" {
  value = "${data.null_data_source.get_certs.outputs["ca_certificate"]}"
}

output "vault_reviewer_token" {
  value = "${data.null_data_source.get_certs.outputs["vault_reviewer_token"]}"
}

output "vault_k8s_auth_backend" {
  value = "${vault_auth_backend.k8s.path}"
}

output "vault_user" {
  value = "${var.vault_user}"
}

output "vault_addr" {
  value = "${var.vault_addr}"
}
