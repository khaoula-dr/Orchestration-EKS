# Fichier racine : assemble les modules dans l'ordre logique
# VPC -> IAM -> ECR -> EKS -> GitHub OIDC

module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  cluster_name = var.cluster_name
}

module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
}

module "ecr" {
  source = "./modules/ecr"

  project_name = var.project_name
  # service_names garde sa valeur par défaut (les 6 microservices)
}

module "eks" {
  source = "./modules/eks"

  cluster_name        = var.cluster_name
  vpc_id              = module.vpc.vpc_id
  cluster_role_arn    = module.iam.cluster_role_arn
  node_role_arn       = module.iam.node_role_arn
  public_subnet_ids   = module.vpc.public_subnet_ids
  private_subnet_ids  = module.vpc.private_subnet_ids
}

module "github_oidc" {
  source = "./modules/github-oidc"

  project_name         = var.project_name
  github_org           = var.github_org
  github_repo          = var.github_repo
  ecr_repository_arns  = values(module.ecr.repository_arns)
}

module "alb_controller_irsa" {
  source = "./modules/alb-controller-irsa"

  project_name      = var.project_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
}

module "ebs_csi_irsa" {
  source = "./modules/ebs-csi-irsa"

  project_name      = var.project_name
  cluster_name      = module.eks.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
}

module "cluster_autoscaler_irsa" {
  source = "./modules/cluster-autoscaler-irsa"

  project_name      = var.project_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
}

module "fluent_bit_irsa" {
  source = "./modules/fluent-bit-irsa"

  project_name      = var.project_name
  cluster_name      = module.eks.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
}