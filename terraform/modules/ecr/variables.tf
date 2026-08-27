variable "project_name" {
  description = "Nom du projet, utilisé comme préfixe des repos ECR"
  type        = string
}

variable "service_names" {
  description = "Liste des microservices ayant besoin d'un repo ECR"
  type        = list(string)
  default     = ["frontend", "api-gateway", "user-service", "product-service", "order-service", "notification-service"]
}
