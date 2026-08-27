variable "project_name" {
  description = "Nom du projet, utilisé pour préfixer les ressources"
  type        = string
}

variable "cluster_name" {
  description = "Nom du cluster EKS (utilisé dans les tags requis par Kubernetes)"
  type        = string
}

variable "vpc_cidr" {
  description = "Plage CIDR du VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Plages CIDR des 2 sous-réseaux publics"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Plages CIDR des 2 sous-réseaux privés"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}
