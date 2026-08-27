#!/bin/bash
# compare-image-sizes.sh
# Build la version "naive" (Dockerfile.naive, single-stage) et la version
# "optimisée" (Dockerfile, multi-stage) de chaque service, puis affiche
# un tableau comparatif des tailles + le nombre de layers.
#
# Usage : ./compare-image-sizes.sh
# Prérequis : Docker installé et démarré

set -euo pipefail

SERVICES=(api-gateway user-service product-service order-service notification-service)

echo "Build des images (avant / après) pour chaque service..."
echo

for svc in "${SERVICES[@]}"; do
  echo "=== $svc ==="
  docker build -f "./$svc/Dockerfile.naive" -t "ecommerce/${svc}:naive" "./$svc" --quiet
  docker build -f "./$svc/Dockerfile"       -t "ecommerce/${svc}:optimized" "./$svc" --quiet
  echo "OK"
  echo
done

echo
echo "=========================================="
echo "  COMPARATIF DES TAILLES D'IMAGES"
echo "=========================================="
printf "%-25s %-15s %-15s %-12s\n" "SERVICE" "AVANT (naive)" "APRES (optim)" "GAIN"
echo "----------------------------------------------------------------------"

for svc in "${SERVICES[@]}"; do
  SIZE_NAIVE=$(docker images "ecommerce/${svc}:naive" --format "{{.Size}}")
  SIZE_OPT=$(docker images "ecommerce/${svc}:optimized" --format "{{.Size}}")
  printf "%-25s %-15s %-15s\n" "$svc" "$SIZE_NAIVE" "$SIZE_OPT"
done

echo
echo "=========================================="
echo "  NOMBRE DE LAYERS (docker history)"
echo "=========================================="
for svc in "${SERVICES[@]}"; do
  LAYERS_NAIVE=$(docker history "ecommerce/${svc}:naive" -q | wc -l)
  LAYERS_OPT=$(docker history "ecommerce/${svc}:optimized" -q | wc -l)
  echo "$svc : naive=$LAYERS_NAIVE layers | optimized=$LAYERS_OPT layers"
done

echo
echo "Pour une vue détaillée layer par layer d'une image (utile pour tes screenshots) :"
echo "  docker history ecommerce/user-service:optimized"
echo
echo "Pour vérifier que le conteneur tourne bien en non-root (sécurité, RBN-18) :"
echo "  docker run --rm ecommerce/user-service:optimized whoami"
echo "  -> doit afficher 'appuser', pas 'root'"
echo
echo "Astuce (optionnel) : installer 'dive' pour une analyse visuelle des layers :"
echo "  https://github.com/wagoodman/dive"
echo "  dive ecommerce/user-service:optimized"
