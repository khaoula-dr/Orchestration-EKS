output "vpc_id" {
  description = "ID du VPC créé"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs des sous-réseaux publics"
  value       = aws_subnet.public[*].id
}

output "acm_certificate_arn" {
  description = "ARN du certificat ACM auto-signé (à mettre dans values-secrets.yaml)"
  value       = module.acm_self_signed.certificate_arn
}
output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}
