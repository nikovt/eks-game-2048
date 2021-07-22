

resource "aws_iam_policy" "alb_controller" {
  name   = "AWSLoadBalancerControllerIAMPolicy"
  policy = file("iam_policy.json")
}

resource "aws_iam_role_policy_attachment" "alb_controller" {
  policy_arn = aws_iam_policy.alb_controller.arn
  role       = aws_iam_role.alb_controller.name
}

data "aws_iam_policy_document" "eks_oidc_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
      values = [
        "system:serviceaccount:${local.alb_controller_namespace}:aws-load-balancer-controller"
      ]
    }
    principals {
      identifiers = [
        module.eks.oidc_provider_arn
      ]
      type = "Federated"
    }
  }
}

resource "aws_iam_role" "alb_controller" {
  name        = "aws-load-balancer-controller"
  description = "Permissions required by the Kubernetes AWS Load Balancer controller to do its job."

  tags = local.common_tags

  assume_role_policy = data.aws_iam_policy_document.eks_oidc_assume_role.json
}