# Service Discovery (RBN-25)

Aucune configuration supplémentaire n'a été nécessaire — Kubernetes fournit
le service discovery nativement via **CoreDNS**, installé par défaut sur EKS.

## Comment ça fonctionne dans ce projet

Chaque microservice est exposé par un `Service` Kubernetes de type `ClusterIP`
(voir `charts/<service>/templates/service.yaml`). CoreDNS crée automatiquement
une entrée DNS interne pour chaque Service, résolvable depuis n'importe quel
pod du cluster sous la forme :