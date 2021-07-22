resource "kubernetes_service_account" "alb_ingress_controller" {
  metadata {
    name = "aws-load-balancer-controller"
    labels = {
      "app.kubernetes.io/name" : "aws-load-balancer-controller",
      "app.kubernetes.io/component" : "controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" : aws_iam_role.alb_controller.arn
    }
    namespace = local.alb_controller_namespace
  }
}

resource "kubernetes_cluster_role" "alb_ingress_controller" {
  metadata {
    name = "aws-load-balancer-controller"
    labels = {
      "app.kubernetes.io/name" : "aws-load-balancer-controller"
    }
  }
  rule {
    api_groups = [
      "",
      "extensions",
    ]
    resources = [
      "configmaps",
      "endpoints",
      "events",
      "ingresses",
      "ingresses/status",
      "services",
    ]
    verbs = [
      "create",
      "get",
      "list",
      "update",
      "watch",
      "patch",
    ]
  }

  rule {
    api_groups = [
      "",
      "extensions",
    ]
    resources = [
      "nodes",
      "pods",
      "secrets",
      "services",
      "namespaces",
    ]
    verbs = [
      "get",
      "list",
      "watch",
    ]
  }
  depends_on = [
    module.eks, // Enforce an explicit dependency to halt the helm chart install util the cluster is ready
  ]
}

resource "kubernetes_cluster_role_binding" "alb_ingress_controller" {
  metadata {
    name = "aws-load-balancer-controller"
    labels = {
      "app.kubernetes.io/name" : "aws-load-balancer-controller"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "aws-load-balancer-controller"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
  }
  depends_on = [
    module.eks, // Enforce an explicit dependency to halt the helm chart install util the cluster is ready
  ]
}

resource "kubernetes_namespace" "game_2048" {
  metadata {
    name = "game-2048"
  }
  depends_on = [
    module.eks, // Enforce an explicit dependency to halt the helm chart install util the cluster is ready
  ]
}