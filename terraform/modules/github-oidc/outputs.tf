output "role_arn" {
  description = "ARN du rôle à renseigner dans le workflow GitHub Actions (secret AWS_ROLE_ARN)"
  value       = aws_iam_role.github_actions.arn
}
