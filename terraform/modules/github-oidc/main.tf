# Module GitHub OIDC : permet à GitHub Actions de s'authentifier sur AWS
# SANS stocker de clé secrète (Access Key/Secret Key) dans les secrets GitHub.
# GitHub fournit un token temporaire, AWS vérifie ce token via ce fournisseur OIDC,
# et accorde un rôle IAM limité au repo GitHub concerné.

# Le fournisseur OIDC de GitHub est le même pour tous les repos GitHub au monde,
# donc on ne le crée qu'une seule fois par compte AWS.
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"] # empreinte officielle GitHub Actions

  tags = {
    Name = "${var.project_name}-github-oidc"
  }
}

# Rôle IAM que GitHub Actions va assumer.
# La condition "sub" restreint ce rôle STRICTEMENT à ton repo GitHub (aucun autre repo ne peut l'utiliser).
resource "aws_iam_role" "github_actions" {
  name = "${var.project_name}-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          # N'autorise que ce repo précis, sur n'importe quelle branche (ajuster si besoin)
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:*"
        }
      }
    }]
  })
}

# Permissions : pousser des images vers ECR (le strict nécessaire pour l'instant)
resource "aws_iam_role_policy" "ecr_push" {
  name = "${var.project_name}-ecr-push-policy"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "ecr:GetAuthorizationToken"
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = var.ecr_repository_arns
      }
    ]
  })
}
