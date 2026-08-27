# Module IRSA pour le Cluster Autoscaler (RBN-15).
# Même principe que alb-controller-irsa : un rôle IAM assumable UNIQUEMENT
# par le ServiceAccount "cluster-autoscaler" dans kube-system.
#
# Note : les Managed Node Groups EKS taguent automatiquement leur Auto Scaling
# Group sous-jacent avec "k8s.io/cluster-autoscaler/<cluster>" = owned et
# "k8s.io/cluster-autoscaler/enabled" = true — donc l'autodiscovery du
# Cluster Autoscaler fonctionne sans tag manuel supplémentaire de notre part.

resource "aws_iam_policy" "cluster_autoscaler" {
  name   = "${var.project_name}-cluster-autoscaler-policy"
  policy = file("${path.module}/policy.json")
}

resource "aws_iam_role" "cluster_autoscaler" {
  name = "${var.project_name}-cluster-autoscaler-role"

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
          "${var.oidc_provider_url}:sub" = "system:serviceaccount:kube-system:cluster-autoscaler"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  role       = aws_iam_role.cluster_autoscaler.name
  policy_arn = aws_iam_policy.cluster_autoscaler.arn
}
