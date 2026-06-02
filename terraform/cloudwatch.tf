resource "aws_cloudwatch_log_group" "backend" {
  name  = "/dashlab/backend"
  retention_in_days = 30

  tags = {
    Name = "${var.project}-backend-logs"
    Project = var.project
  }
}

resource "aws_cloudwatch_log_group" "frontend" {
  name = "/dashlab/frontend"
  retention_in_days = 30

  tags = {
    Name = "${var.project}-frontend-logs"
    Project = var.project
  }
}

resource "aws_iam_role_policy_attachment" "eks_nodes_cloudwatch" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role = aws_iam_role.eks_nodes.name
}