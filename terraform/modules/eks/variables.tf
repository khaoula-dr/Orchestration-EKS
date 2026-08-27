variable "cluster_name" {
  description = "Nom du cluster EKS"
  type        = string
}

variable "kubernetes_version" {
  description = "Version de Kubernetes pour le control plane"
  type        = string
  default     = "1.34"
}

variable "cluster_role_arn" {
  description = "ARN du rôle IAM du cluster (issu du module iam)"
  type        = string
}

variable "node_role_arn" {
  description = "ARN du rôle IAM des nœuds (issu du module iam)"
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs des sous-réseaux publics (issus du module vpc)"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "IDs des sous-réseaux privés (issus du module vpc)"
  type        = list(string)
}

variable "node_instance_type" {
  description = "Type d'instance EC2 pour les nœuds"
  type        = string
  default     = "t3.medium"
}

variable "node_desired_size" {
  description = "Nombre de nœuds souhaité au démarrage"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Nombre minimum de nœuds"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Nombre maximum de nœuds"
  type        = number
  default     = 3
}

variable "vpc_id" {
  description = "ID du VPC (nécessaire pour créer le security group custom des nœuds)"
  type        = string
}