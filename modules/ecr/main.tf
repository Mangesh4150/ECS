resource "aws_ecr_repository" "ecr" {
  count = var.registry_count
  name  = var.registry_names[count.index]
  tags  = var.tags

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  image_tag_mutability = var.image_tag_mutability
}

resource "aws_ecr_lifecycle_policy" "ecr_policy" {
  count      = var.registry_count
  repository = aws_ecr_repository.ecr[count.index].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire old images"
        selection = {
          tagStatus     = "untagged"
          countType     = "sinceImagePushed"
          countUnit     = "days"
          countNumber   = var.retention_days
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
