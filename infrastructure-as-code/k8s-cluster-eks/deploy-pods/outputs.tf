locals {
  config-map-aws-auth = <<CONFIGMAPAWSAUTH


apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${data.terraform_remote_state.cluster.iam-role-arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH
}

output "config-map-aws-auth" {
  value = "${local.config-map-aws-auth}"
}

output "zREADME" {
  value = <<README

Run the below commands to view the provisioned resources.

$ kubectl get namespaces
$ kubectl get configmaps --all-namespaces
$ kubectl -n kube-system describe configMap ${var.config_map_name}
$ kubectl get services --all-namespaces
$ kubectl -n ${var.namespace_name} get services
$ kubectl get pods --all-namespaces
$ kubectl -n ${var.namespace_name} get pods
$ kubectl -n ${var.namespace_name} describe pods ${var.nginx_pod_name}
$ kubectl get nodes --all-namespaces
$ kubectl describe nodes <NODE>

# Log into dashboard
$ kubectl proxy
$ kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')

Visit: http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
README
}
