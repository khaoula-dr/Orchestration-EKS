variable "aws_region" {
  description = "Région AWS où déployer l'infrastructure"
  type        = string
  default     = "eu-west-3"
}

variable "project_name" {
  description = "Nom du projet, préfixe toutes les ressources"
  type        = string
  default     = "ecommerce"
}

variable "cluster_name" {
  description = "Nom du cluster EKS"
  type        = string
  default     = "ecommerce-eks"
}

variable "github_org" {
  description = "Ton nom d'utilisateur ou organisation GitHub"
  type        = string
}

variable "github_repo" {
  description = "Nom du repo GitHub contenant ce projet"
  type        = string
}
