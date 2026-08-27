output "cluster_name" {
  description = "Nom du cluster EKS créé"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "Endpoint de l'API Kubernetes"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority" {
  description = "Certificat CA du cluster (nécessaire pour kubectl)"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "oidc_provider_arn" {
  description = "ARN du fournisseur OIDC du cluster (nécessaire pour IRSA en Sprint 2)"
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "oidc_provider_url" {
  description = "URL du fournisseur OIDC du cluster (sans le https://)"
  value       = replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")
}
