output "certificate_arn" {
  description = "ARN du certificat ACM à utiliser dans l'annotation Ingress"
  value       = aws_acm_certificate.demo.arn
}