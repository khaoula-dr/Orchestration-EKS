# Rôle IAM pour Fluent Bit : lui permet d'écrire les logs des pods
# vers CloudWatch Logs (un log group par service/namespace).

resource "aws_iam_role" "fluent_bit" {
  name = "${var.project_name}-fluent-bit-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = var.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${var.oidc_provider_url}:aud" = "sts.amazonaws.com"
          "${var.oidc_provider_url}:sub" = "system:serviceaccount:monitoring:aws-for-fluent-bit"
        }
      }
    }]
  })
}

resource "aws_iam_policy" "fluent_bit" {
  name = "${var.project_name}-fluent-bit-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "logs:PutRetentionPolicy"
      ]
      Resource = "arn:aws:logs:*:*:log-group:/eks/${var.cluster_name}/*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "fluent_bit" {
  role       = aws_iam_role.fluent_bit.name
  policy_arn = aws_iam_policy.fluent_bit.arn
}