variable "project_name" {
  description = "Nom du projet, utilisé pour préfixer les ressources"
  type        = string
}

variable "cluster_name" {
  description = "Nom du cluster EKS"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN du fournisseur OIDC du cluster EKS (sortie du module eks)"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL du fournisseur OIDC du cluster EKS, sans https:// (sortie du module eks)"
  type        = string
}