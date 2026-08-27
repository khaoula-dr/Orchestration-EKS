output "role_arn" {
  description = "ARN du rôle à annoter sur le ServiceAccount Kubernetes du Cluster Autoscaler"
  value       = aws_iam_role.cluster_autoscaler.arn
}
