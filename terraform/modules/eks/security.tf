# Security group custom pour les nœuds EKS.
# Vient EN PLUS du security group par défaut créé automatiquement par EKS
# (celui-ci reste attaché aussi, pour ne pas casser l'ALB Controller déjà en place).
# Objectif : rendre explicites les règles réellement nécessaires entre nœuds,
# plutôt que de se reposer uniquement sur les règles larges par défaut.

resource "aws_security_group" "eks_nodes_custom" {
  name        = "${var.cluster_name}-nodes-custom-sg"
  description = "Regles explicites de communication entre les noeuds EKS"
  vpc_id      = var.vpc_id

  tags = {
    Name                                         = "${var.cluster_name}-nodes-custom-sg"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

# Les nœuds doivent pouvoir se parler entre eux (CNI, kube-proxy, trafic pod-à-pod
# quand 2 pods sont sur des nœuds différents)
resource "aws_security_group_rule" "nodes_self_ingress" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_nodes_custom.id
  source_security_group_id = aws_security_group.eks_nodes_custom.id
  description               = "Communication entre noeuds (CNI, kube-proxy, pods)"
}

# Le control plane doit pouvoir appeler le kubelet de chaque nœud (port 10250)
resource "aws_security_group_rule" "nodes_kubelet_from_cluster" {
  type                     = "ingress"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes_custom.id
  source_security_group_id = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
  description               = "Control plane to kubelet"
}

# Le control plane doit pouvoir appeler les webhooks des nœuds (port 443, ex: métriques, admission)
resource "aws_security_group_rule" "nodes_https_from_cluster" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes_custom.id
  source_security_group_id = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
  description               = "Control plane to noeuds (webhooks, metrics)"
}

# Sortie libre : nécessaire pour tirer les images (ECR, Docker Hub), appeler l'API AWS, etc.
resource "aws_security_group_rule" "nodes_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_nodes_custom.id
  description       = "Sortie libre (pull images, appels API AWS)"
}

# Launch template qui attache CE security group aux instances du node group,
# EN PLUS du security group par défaut du cluster (pour ne rien casser).
resource "aws_launch_template" "eks_nodes" {
  name_prefix = "${var.cluster_name}-nodes-"

  vpc_security_group_ids = [
    aws_eks_cluster.main.vpc_config[0].cluster_security_group_id,
    aws_security_group.eks_nodes_custom.id,
  ]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.cluster_name}-node"
    }
  }
}