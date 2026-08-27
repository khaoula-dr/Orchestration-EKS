output "cluster_role_arn" {
  description = "ARN du rôle IAM du cluster EKS"
  value       = aws_iam_role.eks_cluster.arn
}

output "node_role_arn" {
  description = "ARN du rôle IAM des nœuds EKS"
  value       = aws_iam_role.eks_node.arn
}
