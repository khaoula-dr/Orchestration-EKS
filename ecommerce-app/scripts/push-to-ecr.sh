#!/bin/bash
# push-to-ecr.sh
# Construit et pousse les 6 images du projet vers Amazon ECR.
#
# Prérequis :
#   - AWS CLI configuré (aws configure) avec des credentials valides
#   - Docker installé et démarré
#   - Droits IAM suffisants pour créer des repos ECR et push des images
#
# Usage :
#   ./push-to-ecr.sh [tag]
#   ex: ./push-to-ecr.sh v1.0.0   (par défaut : "latest")

set -euo pipefail

TAG="${1:-latest}"
AWS_REGION="${AWS_REGION:-eu-west-3}"
SERVICES=(frontend api-gateway user-service product-service order-service notification-service)

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

echo "Compte AWS : $AWS_ACCOUNT_ID"
echo "Région     : $AWS_REGION"
echo "Registry   : $ECR_REGISTRY"
echo "Tag        : $TAG"
echo

echo "Authentification Docker sur ECR..."
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$ECR_REGISTRY"

for svc in "${SERVICES[@]}"; do
  REPO_NAME="ecommerce/${svc}"
  IMAGE_URI="${ECR_REGISTRY}/${REPO_NAME}:${TAG}"

  echo
  echo "=== $svc ==="

  # Crée le repo ECR s'il n'existe pas déjà (idempotent)
  aws ecr describe-repositories --repository-names "$REPO_NAME" --region "$AWS_REGION" >/dev/null 2>&1 || \
    aws ecr create-repository \
      --repository-name "$REPO_NAME" \
      --region "$AWS_REGION" \
      --image-scanning-configuration scanOnPush=true \
      --image-tag-mutability IMMUTABLE

  echo "Build de l'image $svc..."
  docker build -t "$IMAGE_URI" "./$svc"

  echo "Push vers $IMAGE_URI..."
  docker push "$IMAGE_URI"

  echo "$svc -> $IMAGE_URI"
done

echo
echo "Toutes les images ont été poussées avec le tag '$TAG'."
echo "URIs à utiliser dans les values.yaml Helm :"
for svc in "${SERVICES[@]}"; do
  echo "  $svc: ${ECR_REGISTRY}/ecommerce/${svc}:${TAG}"
done
