resource "aws_ecr_repository" "backend" {
    name = "${var.project}-backend"
    image_tag_mutability = "MUTABLE"

    image_scanning_configuration {
        scan_on_push = true
    }

    tags = {
        Name = "${var.project}-backend"
        Project = var.project
    }
}

resource "aws_ecr_repository" "frontend" {
    name = "${var.project}-frontend"
    image_tag_mutability = "MUTABLE"

    image_scanning_configuration {
        scan_on_push = true
    }

    tags = {
        Name = "${var.project}-frontend"
        Project = var.project
    }
}