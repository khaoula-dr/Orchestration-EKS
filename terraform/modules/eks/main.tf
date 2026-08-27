# Module EKS : le cluster (control plane) + un Managed Node Group
# Le control plane est placé sur les sous-réseaux publics ET privés (recommandation AWS),
# les nœuds eux sont uniquement dans les sous-réseaux privés (sécurité).

resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = concat(var.public_subnet_ids, var.private_subnet_ids)
    endpoint_public_access   = true # permet kubectl depuis ton poste local
    endpoint_private_access  = true # permet aux nœuds de communiquer avec le control plane en interne
  }

  tags = {
    Name = var.cluster_name
  }
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-nodes"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids # les nœuds restent dans le réseau privé

  instance_types = [var.node_instance_type]

  launch_template {
    id      = aws_launch_template.eks_nodes.id
    version = "$Latest"
  }
  
  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  # Évite de supprimer/recréer le node group si on met juste à jour desired_size
  # (utile plus tard avec le Cluster Autoscaler / HPA de RBN-15)
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  tags = {
    Name = "${var.cluster_name}-nodes"
  }

  
}

# ---- OIDC provider du cluster : requis pour IRSA (utilisé par le Load Balancer Controller, EBS CSI, etc. en Sprint 2) ----
data "tls_certificate" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

