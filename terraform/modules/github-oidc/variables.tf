variable "project_name" {
  description = "Nom du projet, utilisé pour préfixer les ressources"
  type        = string
}

variable "github_org" {
  description = "Ton nom d'utilisateur ou organisation GitHub (ex: 'kevin-dupont')"
  type        = string
}

variable "github_repo" {
  description = "Nom du repo GitHub (ex: 'orchestration-eks')"
  type        = string
}

variable "ecr_repository_arns" {
  description = "Liste des ARNs des repos ECR sur lesquels le pipeline a le droit de push (issus du module ecr)"
  type        = list(string)
}
