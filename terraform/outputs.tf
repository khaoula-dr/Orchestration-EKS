output "cluster_name" {
  description = "Nom du cluster EKS"
  value       = module.eks.cluster_name
}

output "configure_kubectl" {
  description = "Commande à lancer pour connecter kubectl au cluster"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "ecr_repository_urls" {
  description = "URLs des repos ECR créés (à utiliser dans les values.yaml Helm)"
  value       = module.ecr.repository_urls
}

output "github_actions_role_arn" {
  description = "ARN à mettre dans le workflow GitHub Actions (variable AWS_ROLE_ARN)"
  value       = module.github_oidc.role_arn
}

output "alb_controller_role_arn" {
  description = "ARN du rôle IAM pour l'AWS Load Balancer Controller"
  value       = module.alb_controller_irsa.role_arn
}


output "ebs_csi_role_arn" {
  description = "ARN du rôle IAM pour l'EBS CSI Driver"
  value       = module.ebs_csi_irsa.role_arn
}

output "cluster_autoscaler_role_arn" {
  description = "ARN du rôle IAM pour le Cluster Autoscaler (annotation du ServiceAccount)"
  value       = module.cluster_autoscaler_irsa.role_arn
}

output "fluent_bit_role_arn" {
  value = module.fluent_bit_irsa.role_arn
}