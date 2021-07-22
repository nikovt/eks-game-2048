locals {
  cluster_name             = "eks-devops-challenge"
  alb_controller_namespace = "kube-system"

  common_tags = {
    "Terraform" = "true"
  }
}