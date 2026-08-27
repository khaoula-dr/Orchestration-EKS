output "role_arn" {
  description = "ARN du rôle IAM du driver EBS CSI"
  value       = aws_iam_role.ebs_csi.arn
}

output "addon_name" {
  description = "Nom de l'addon EKS installé"
  value       = aws_eks_addon.ebs_csi.addon_name
}