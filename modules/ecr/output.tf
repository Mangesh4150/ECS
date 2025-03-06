output "ecr_repository_urls" {
  description = "List of ECR repository URLs"
#   value       = aws_ecr_repository.ecr[*].repository_url
value = { for repo in aws_ecr_repository.ecr : repo.name => repo.repository_url }
}