#
# Outputs
#

locals {
  config-map-aws-auth = <<CONFIGMAPAWSAUTH


apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.demo-node.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH

  kubeconfig = <<KUBECONFIG


apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.demo.endpoint}
    certificate-authority-data: ${aws_eks_cluster.demo.certificate_authority.0.data}
  name: ${var.cluster}
contexts:
- context:
    cluster: ${var.cluster}
    user: ${var.user}
  name: ${var.user}
current-context: ${var.user}
kind: Config
preferences: {}
users:
- name: ${var.user}
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: heptio-authenticator-aws
      args:
        - "token"
        - "-i"
        - "${var.cluster-name}"
KUBECONFIG
}

output "config-map-aws-auth" {
  value = "${local.config-map-aws-auth}"
}

output "kubeconfig" {
  value = "${local.kubeconfig}"
}

output "cluster-name" {
  value = "${var.cluster-name}"
}

output "cluster" {
  value = "${var.cluster}"
}

output "user" {
  value = "${var.user}"
}

output "endpoint" {
  value = "${aws_eks_cluster.demo.endpoint}"
}

output "ca-cert" {
  value = "${aws_eks_cluster.demo.certificate_authority.0.data}"
}

output "iam-role-arn" {
  value = "${aws_iam_role.demo-node.arn}"
}

output "zREADME" {
  value = <<README

# In order to connect to the Kubernetes cluster using kubectl (the Kubernetes command line tool),
# a configuration file is required. This can be generated using the command below.
$ sudo mkdir ~/.kube # If not already created
$ terraform output kubeconfig > ~/.kube/${var.cluster-name}-config

# Set the KUBECONFIG environment variable to the allow kubectl to use the configuration created above.
$ export KUBECONFIG=~/.kube/${var.cluster-name}-config

# View resources
$ kubectl get componentstatus
$ kubectl cluster-info
$ kubectl get namespaces
$ kubectl get configmaps --all-namespaces
$ kubectl get services --all-namespaces
$ kubectl get nodes --watch
README
}
