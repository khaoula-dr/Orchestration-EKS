variable "project_name" {
  description = "Nom du projet"
  type        = string
}

variable "common_name" {
  description = "Nom d'hôte pour le certificat (ex: ecommerce-demo.sslip.io). Purement indicatif pour un certificat auto-signé."
  type        = string
  default     = "ecommerce-demo.sslip.io"
}