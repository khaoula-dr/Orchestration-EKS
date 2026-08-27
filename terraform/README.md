# Infrastructure Terraform — Epic 1 (+ ECR + GitHub Actions OIDC)

## Structure

```
terraform/
├── main.tf                    # assemble les modules
├── variables.tf
├── outputs.tf
├── providers.tf
├── terraform.tfvars.example
├── modules/
│   ├── vpc/                   # US 1.1 : réseau (VPC, subnets, NAT, routes)
│   ├── iam/                   # rôles IAM cluster + nœuds
│   ├── ecr/                   # 6 repos ECR (remplace le script manuel)
│   ├── eks/                   # US 1.2 : cluster EKS + node group + OIDC provider
│   └── github-oidc/           # rôle IAM pour GitHub Actions (sans clé stockée)
└── .github/workflows/
    └── build-push-ecr.yml     # pipeline CI : build + push automatique vers ECR
```

## Prérequis

- Terraform >= 1.6 installé
- AWS CLI configuré (`aws configure`) avec des droits suffisants (IAM, EKS, EC2, ECR)
- Un repo GitHub existant pour ce projet

## Étapes de déploiement

### 1. Configurer tes variables

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Édite `terraform.tfvars` et renseigne ton `github_org` et `github_repo` (le nom exact de ton repo GitHub, sinon le pipeline ne pourra pas s'authentifier).

### 2. Initialiser Terraform

```bash
terraform init
```

### 3. Vérifier ce qui va être créé (toujours faire avant d'appliquer)

```bash
terraform plan
```

### 4. Appliquer (crée réellement les ressources AWS)

```bash
terraform apply
```

Tape `yes` pour confirmer. Ça prend environ **15-20 minutes** (le control plane EKS est long à provisionner).

### 5. Récupérer les infos utiles

```bash
terraform output
```

Tu obtiens notamment :
- `configure_kubectl` : la commande à copier-coller pour connecter `kubectl`
- `ecr_repository_urls` : les URLs des 6 repos ECR
- `github_actions_role_arn` : à mettre dans les secrets GitHub

### 6. Connecter kubectl au cluster

```bash
aws eks update-kubeconfig --region eu-west-3 --name ecommerce-eks
kubectl get nodes
```

Tu dois voir 2 nœuds à l'état `Ready`.

### 7. Configurer le secret GitHub pour le pipeline CI

Dans ton repo GitHub → **Settings → Secrets and variables → Actions → New repository secret** :
- Nom : `AWS_ROLE_ARN`
- Valeur : la sortie `github_actions_role_arn` de l'étape 5

Une fois ce secret ajouté, chaque `git push` sur `main` qui touche `ecommerce-app/` déclenche automatiquement le build + push des 6 images vers ECR (workflow `.github/workflows/build-push-ecr.yml`).

### 8. Tester le pipeline manuellement (sans attendre un push)

Dans GitHub → onglet **Actions** → sélectionne le workflow → bouton **Run workflow**.

## Détruire l'infrastructure (important pour les coûts — RBN-36)

```bash
terraform destroy
```

⚠️ Pense à le faire après chaque session de travail/démo si tu ne veux pas payer le cluster EKS (control plane facturé même sans nœuds actifs) et les instances EC2 en continu.

## Vérifications utiles

```bash
# Vérifier que les repos ECR ont bien été créés
aws ecr describe-repositories --region eu-west-3

# Vérifier l'état du cluster
aws eks describe-cluster --name ecommerce-eks --region eu-west-3 --query "cluster.status"

# Vérifier que le rôle GitHub Actions existe
aws iam get-role --role-name ecommerce-github-actions-role
```

## Notes sur les choix techniques

- **Une seule NAT Gateway** (pas une par AZ) pour limiter les coûts en environnement de démo/dev. En production, on en mettrait une par AZ pour la haute disponibilité.
- **OIDC pour GitHub Actions** : aucune clé AWS n'est stockée dans les secrets GitHub, uniquement l'ARN d'un rôle. Le rôle est restreint à ce repo précis (`github_org/github_repo`) via la condition `sub` dans la trust policy.
- **`lifecycle { ignore_changes }`** sur le node group : évite que Terraform ne "recrée" le node group si le Cluster Autoscaler (RBN-15, à venir) modifie `desired_size` en dehors de Terraform.
