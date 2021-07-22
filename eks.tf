module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = local.cluster_name
  cluster_version = "1.20"
  subnets         = module.vpc.private_subnets
  enable_irsa     = true

  tags = merge(local.common_tags, {
    "Cluster-Name" = local.cluster_name
  })

  vpc_id = module.vpc.vpc_id

  worker_groups = [
    {
      instance_type = "t2.medium"
    }
  ]
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}