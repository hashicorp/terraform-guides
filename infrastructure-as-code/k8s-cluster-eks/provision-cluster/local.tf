resource "null_resource" "env" {
  provisioner "local-exec" {
    command = <<EOF
mkdir ~/.kube
cat <<CONFIG | tee ~/.kube/${var.cluster-name}-config
${local.kubeconfig}
CONFIG

export KUBECONFIG=~/.kube/${var.cluster-name}-config

# Set up Kubernetes for the Terraform Kubernetes provider
kubectl config set-context default-system \
  --cluster=${var.cluster} \
  --user=${var.user}

kubectl config use-context default-system

kubectl create clusterrolebinding cluster-system-anonymous --clusterrole=cluster-admin --user=system:anonymous
EOF

    environment {
      KUBECONFIG = "~/.kube/${var.cluster-name}-config"
    }
  }
}

resource "null_resource" "dashboard" {
  provisioner "local-exec" {
    command = <<EOF
mkdir ~/.kube
cat <<CONFIG | tee ~/.kube/${var.cluster-name}-config
${local.kubeconfig}
CONFIG

export KUBECONFIG=~/.kube/${var.cluster-name}-config

# Setup dashboard: https://docs.aws.amazon.com/eks/latest/userguide/dashboard-tutorial.html
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/heapster.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/influxdb.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/rbac/heapster-rbac.yaml

kubectl apply -f config/eks-admin-service-account.yaml
kubectl apply -f config/eks-admin-cluster-role-binding.yaml
EOF

    environment {
      KUBECONFIG = "~/.kube/${var.cluster-name}-config"
    }
  }

  depends_on = [
    "null_resource.env"
  ]
}
