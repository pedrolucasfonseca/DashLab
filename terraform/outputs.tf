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