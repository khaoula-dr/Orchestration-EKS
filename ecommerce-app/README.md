# E-commerce Microservices Demo

Application e-commerce composée de 6 microservices + 2 bases de données, communiquant via HTTP sur un réseau Docker interne (`ecommerce-net`), fidèle au schéma fourni.

## Lancer l'application

```bash
docker compose up --build
```

Puis ouvre : **http://localhost:8080**

Pour arrêter :
```bash
docker compose down
```

Pour tout réinitialiser (y compris les données des DB) :
```bash
docker compose down -v
```

## Structure

```
.
├── docker-compose.yml
├── init-scripts/
│   └── postgres-init-multi-db.sh   # crée usersdb + ordersdb au 1er démarrage
├── frontend/            # Nginx statique (port 8080 exposé), proxy /api/* -> api-gateway
├── api-gateway/         # Node/Express (port 3000), route vers user/product/order-service
├── user-service/        # Node/Express + Postgres (usersdb)
├── product-service/     # Node/Express + MongoDB
├── order-service/       # Node/Express + Postgres (ordersdb), appelle user+product+notification
└── notification-service/# Node/Express, stateless (en mémoire, pas de DB)
```

## Endpoints principaux (via le frontend / api-gateway)

- `GET  /api/users`
- `GET  /api/users/:id`
- `POST /api/users`            `{ "name": "...", "email": "..." }`
- `GET  /api/products`
- `GET  /api/products/:id`
- `POST /api/products`         `{ "name": "...", "price": 9.99, "stock": 10 }`
- `GET  /api/orders`
- `GET  /api/orders/:id`
- `POST /api/orders`           `{ "userId": 1, "productId": "...", "quantity": 1 }`
  → vérifie l'utilisateur et le produit, crée la commande, puis notifie l'utilisateur via notification-service.

## Points déjà gérés (cf. les "points sensibles" du doc)

1. **Ordre de démarrage** : `user-service` et `order-service` attendent le healthcheck `pg_isready` de `postgres-db` (`depends_on: condition: service_healthy`). En plus, `db.js` retente la connexion 10 fois toutes les 3s en filet de sécurité.
2. **DNS interne Docker** : tous les appels inter-services utilisent le nom du conteneur (`http://user-service:3000`, etc.), tous sur `ecommerce-net`.
3. **Script d'init Postgres** : rendu exécutable (`chmod +x`) et monté en volume ; crée `usersdb` et `ordersdb` via `POSTGRES_MULTIPLE_DATABASES`.
4. **node_modules** : chaque service monte `./service:/app` + un volume anonyme `/app/node_modules` pour ne pas écraser les dépendances installées dans l'image.

## Débogage

```bash
docker compose logs <nom-du-service>
docker compose ps
```

## Images Docker multi-stage (RBN-16 / RBN-18)

Chaque service Node.js utilise un Dockerfile en 2 stages :
1. `deps` : installe uniquement les dépendances de production (`npm ci --omit=dev`)
2. `runtime` : image finale, exécutée par un utilisateur **non-root** (`appuser`), avec `HEALTHCHECK` intégré

Ça réduit la taille des images et limite la surface d'attaque (pas d'outils de build dans l'image finale, pas de root).

## Publier les images sur Amazon ECR (RBN-17)

```bash
export AWS_REGION=eu-west-3   # adapter à ta région
./scripts/push-to-ecr.sh latest
```

Le script :
- crée automatiquement un repo ECR par service (`ecommerce/frontend`, `ecommerce/api-gateway`, etc.) avec scan de vulnérabilités activé au push
- build et push chaque image
- affiche à la fin les URIs complètes à réutiliser dans les `values.yaml` des charts Helm (Sprint 3)

Prérequis : AWS CLI configuré (`aws configure`) avec des droits IAM pour créer des repos ECR et y pousser des images.
