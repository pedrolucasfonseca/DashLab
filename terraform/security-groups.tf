resource "aws_security_group" "eks_cluster" {
  name = "${var.project}-eks-cluster-sg"
  description = "Security group do cluster EKS"
  vpc_id = aws_vpc.main.id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-eks-cluster-sg"
    Project = var.project
  }
}

resource "aws_security_group" "eks_nodes" {
  name = "${var.project}-eks-nodes-sg"
  description = "Security group dos nos EKS"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
  }

  ingress {
    from_port = 1025
    to_port = 65535
    protocol = "tcp"
    security_groups = [aws_security_group.eks_cluster.id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-eks-nodes-sg"
    Project = var.project
  }
}