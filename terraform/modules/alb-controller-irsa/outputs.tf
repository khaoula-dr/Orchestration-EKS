output "role_arn" {
  description = "ARN du rôle à annoter sur le ServiceAccount Kubernetes du contrôleur"
  value       = aws_iam_role.alb_controller.arn
}