# Active le support des NetworkPolicy sur le plugin réseau du cluster (RBN-26).
# Sans ça, les objets NetworkPolicy créés plus bas dans Helm sont ignorés.
resource "aws_eks_addon" "vpc_cni" {
  cluster_name  = module.eks.cluster_name
  addon_name    = "vpc-cni"

  configuration_values = jsonencode({
    enableNetworkPolicy = "true"
  })

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}