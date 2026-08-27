# Chart Helm — Epic 3

## Avant de déployer : créer ton fichier de secrets local

Le repo Git **ne contient jamais** ton ID de compte AWS. Crée ton propre fichier local :

```bash
cd helm/ecommerce-app
cp values-secrets.yaml.example values-secrets.yaml
```

Édite `values-secrets.yaml` et remplace `<AWS_ACCOUNT_ID>` par ton vrai ID de compte :
```bash
aws sts get-caller-identity --query Account --output text
```

`values-secrets.yaml` est listé dans `.gitignore` — il ne sera jamais poussé sur GitHub, même par erreur avec un `git add .`.

## Vérifie ta StorageClass avant de déployer

```bash
kubectl get storageclass
```

Si le nom n'est pas `gp2`, adapte `storageClassName` dans `charts/postgres/values.yaml` et `charts/mongo/values.yaml`.

## Commandes de déploiement

```bash
cd helm/ecommerce-app

# 1. Récupère les dépendances
helm dependency update

# 2. Vérifie la syntaxe
helm lint .

# 3. Génère le YAML final pour relecture (avec ton fichier de secrets local)
helm template ecommerce-app . -f values.yaml -f values-secrets.yaml -f values-dev.yaml > /tmp/rendu.yaml
less /tmp/rendu.yaml

# 4. Déploie dans un namespace dédié
kubectl create namespace demo-app
helm install ecommerce-app . -n demo-app -f values.yaml -f values-secrets.yaml -f values-dev.yaml

# 5. Vérifie
kubectl get pods -n demo-app
kubectl get pvc -n demo-app
kubectl get ingress -n demo-app
```

## Pour changer d'environnement

Remplace juste le dernier `-f` :
```bash
helm upgrade ecommerce-app . -n demo-app -f values.yaml -f values-secrets.yaml -f values-staging.yaml
# ou
helm upgrade ecommerce-app . -n demo-app -f values.yaml -f values-secrets.yaml -f values-prod.yaml
```

## Pour désinstaller

```bash
helm uninstall ecommerce-app -n demo-app
```

⚠️ Ça supprime aussi les `PersistentVolumeClaim` par défaut ? Non — Helm **ne supprime pas** les PVC créés via `volumeClaimTemplates` d'un StatefulSet, il faut les supprimer à la main si tu veux vraiment repartir de zéro :
```bash
kubectl delete pvc -n demo-app --all
```
