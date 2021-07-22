resource "helm_release" "aws-load-balancer-controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.2.3"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = local.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
  depends_on = [
    module.eks,                                       // Enforce an explicit dependency to halt the helm chart install util the cluster is ready
    kubernetes_service_account.alb_ingress_controller // Depend on the k8s service account
  ]
}

resource "helm_release" "game_2048" {
  name      = "game-2048"
  chart     = "./charts/game-2048"
  namespace = "game-2048"

  depends_on = [
    kubernetes_namespace.game_2048,           // Namespace must be provisioned in advance
    helm_release.aws-load-balancer-controller // Controller must be provisioned first
  ]
}