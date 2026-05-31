resource "aws_eks_cluster" "main" {
  name = "${var.project}-cluster"
  role_arn = aws_iam_role.eks_cluster.arn
  version = "1.32"

  vpc_config {
    subnet_ids = [aws_subnet.public_a.id, aws_subnet.public_b.id]
    security_group_ids = [aws_security_group.eks_cluster.id]
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]

  tags = {
    Name = "${var.project}-cluster"
    Project = var.project
  }

  access_config {
  authentication_mode = "API_AND_CONFIG_MAP"
  }
}

resource "aws_eks_node_group" "main" {
  cluster_name = aws_eks_cluster.main.name
  node_group_name = "${var.project}-nodes"
  node_role_arn = aws_iam_role.eks_nodes.arn
  subnet_ids = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  instance_types = ["t3.small"]

  scaling_config {
    desired_size = 2
    min_size = 1
    max_size = 3
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_ecr_policy,
  ]

  tags = {
    Name = "${var.project}-nodes"
    Project = var.project
  }
}