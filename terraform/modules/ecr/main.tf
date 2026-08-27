# Module ECR : crée un repository par microservice
# Remplace la création manuelle faite jusqu'ici par scripts/push-to-ecr.sh
# (le script reste utilisable, mais les repos existeront déjà après "terraform apply")

resource "aws_ecr_repository" "services" {
  for_each = toset(var.service_names)

  name                 = "${var.project_name}/${each.value}"
  image_tag_mutability = "IMMUTABLE" # une fois un tag poussé, il ne peut plus être écrasé (traçabilité)

  image_scanning_configuration {
    scan_on_push = true # scan de vulnérabilités automatique à chaque push
  }

  tags = {
    Name = "${var.project_name}-${each.value}"
  }
}

# Nettoie automatiquement les vieilles images non taguées (évite de payer du stockage inutile)
resource "aws_ecr_lifecycle_policy" "cleanup" {
  for_each   = aws_ecr_repository.services
  repository = each.value.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Supprime les images non taguées après 7 jours"
      selection = {
        tagStatus   = "untagged"
        countType   = "sinceImagePushed"
        countUnit   = "days"
        countNumber = 7
      }
      action = {
        type = "expire"
      }
    }]
  })
}
