terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  # Optionnel mais recommandé : stocke l'état Terraform sur S3 plutôt qu'en local,
  # pour éviter de perdre l'état ou de créer des conflits si vous êtes plusieurs à appliquer.
  # Décommente et adapte une fois le bucket créé :
  #
  # backend "s3" {
  #   bucket = "mon-bucket-terraform-state"
  #   key    = "orchestration-eks/terraform.tfstate"
  #   region = "eu-west-3"
  # }
}

provider "aws" {
  region = var.aws_region
}
