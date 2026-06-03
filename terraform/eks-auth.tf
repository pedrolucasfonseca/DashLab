resource "aws_eks_access_entry" "github_actions" {
  cluster_name = aws_eks_cluster.main.name
  principal_arn = aws_iam_role.github_actions.arn
  type = "STANDARD"
}

resource "aws_eks_access_policy_association" "github_actions" {
  cluster_name = aws_eks_cluster.main.name
  principal_arn = aws_iam_role.github_actions.arn
  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"

  access_scope {
    type = "namespace"
    namespaces = ["dashlab"]
  }
}

resource "aws_eks_access_entry" "admin" {
  cluster_name = aws_eks_cluster.main.name
  principal_arn = "arn:aws:iam::${var.aws_account_id}:user/dashlab-admin"
  type = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin" {
  cluster_name = aws_eks_cluster.main.name
  principal_arn = "arn:aws:iam::${var.aws_account_id}:user/dashlab-admin"
  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}