output "region" {
    value = var.region
}

output "project" {
    value = var.project
}

output "ecr_backend_url" {
    value = aws_ecr_repository.backend.repository_url
}

output "ecr_frontend_url" {
    value = aws_ecr_repository.frontend.repository_url
}

output "cluster_name" {
    value = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
    value     = aws_eks_cluster.main.endpoint
    sensitive = true
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions.arn
}