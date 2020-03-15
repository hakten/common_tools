## Service account for tiller
resource "kubernetes_service_account" "tiller" {
  metadata {
    name      = "tiller"
    namespace = "kube-system"
  }

  automount_service_account_token = true
}

## Cluster role binding for tiller
resource "kubernetes_cluster_role_binding" "tiller-cluster-admin" {
    depends_on = ["kubernetes_service_account.tiller"]

    metadata {
        name = "tiller-cluster-admin"
    }
    role_ref {
        api_group = "rbac.authorization.k8s.io"
        kind      = "ClusterRole"
        name      = "cluster-admin"
    }
    subject {
        kind      = "ServiceAccount"
        name      = "${kubernetes_service_account.tiller.metadata.0.name}"
        namespace = "${kubernetes_service_account.tiller.metadata.0.namespace}"
    }
}

## Install Helm in the bastion

resource "null_resource" "get_helm" {
  depends_on = ["${kubernetes_cluster_role_binding.tiller-cluster-admin}"]
    provisioner "local-exec" {
      when    = "create"
      command = "curl -O https://get.helm.sh/helm-v2.16.3-linux-amd64.tar.gz"
    }
  }

resource "null_resource" "tar_helm" {
  depends_on = ["null_resource.get_helm"]
    provisioner "local-exec" {
      when    = "create"
      command = "tar -xf helm-v2.16.3-linux-amd64.tar.gz"
    }
  }

resource "null_resource" "mv_helm" {
  depends_on = ["null_resource.tar_helm"]
    provisioner "local-exec" {
      when    = "create"
      command = "mv linux-amd64/helm /usr/local/bin/helm"
    }
  }

resource "null_resource" "rm_helm" {
  depends_on = ["null_resource.mv_helm"]
    provisioner "local-exec" {
      when    = "create"
      command = "rm -rf helm-v2.16.3-linux-amd64.tar.gz linux-amd64"
    }
  }

resource "null_resource" "start_helm" {
  depends_on = ["null_resource.rm_helm"]
    provisioner "local-exec" {
      when    = "create"
      command = "helm init --service-account tiller"
  }
}

resource "null_resource" "ready_helm" {
  depends_on = ["null_resource.start_helm"]
    provisioner "local-exec" {
      when    = "create"
      command = "sleep 10"
  }
}
