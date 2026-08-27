output "repository_urls" {
  description = "URLs des repos ECR créés, par service"
  value       = { for name, repo in aws_ecr_repository.services : name => repo.repository_url }
}

output "repository_arns" {
  description = "ARNs des repos ECR créés (utile pour les policies IAM)"
  value       = { for name, repo in aws_ecr_repository.services : name => repo.arn }
}
