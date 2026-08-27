# Service Discovery 

Aucune configuration supplémentaire n'a été nécessaire — Kubernetes fournit
le service discovery nativement via **CoreDNS**, installé par défaut sur EKS.

## Comment ça fonctionne dans ce projet

Chaque microservice est exposé par un `Service` Kubernetes de type `ClusterIP`
(voir `charts/<service>/templates/service.yaml`). CoreDNS crée automatiquement
une entrée DNS interne pour chaque Service, résolvable depuis n'importe quel
pod du cluster sous la forme :
<nom-du-service>.<namespace>.svc.cluster.local

Dans notre cas, tous les services sont déployés dans le namespace `demo-app`,
donc par exemple `user-service` est joignable via :
- `user-service` (forme courte, si l'appelant est dans le même namespace)
- `user-service.demo-app.svc.cluster.local` (forme complète, fonctionne depuis
  n'importe quel namespace)

## Ce qui a changé par rapport à Docker Compose

| Docker Compose | Kubernetes |
|---|---|
| Réseau `ecommerce-net`, résolution par nom de conteneur | Réseau interne du cluster, résolution par CoreDNS |
| `http://user-service:3000` | `http://user-service:3000` (identique en pratique dans le même namespace) |

Aucune variable d'environnement n'a dû changer entre les 2 environnements
grâce à ce choix : `configData.USER_SERVICE_URL: http://user-service:3000`
dans nos `values.yaml` Helm fonctionne à l'identique de l'ancien
`docker-compose.yml`.

## Vérification

```bash
kubectl exec -n demo-app deploy/order-service -- nslookup user-service
```