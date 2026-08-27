#  Stratégie de déploiement (Rolling Update)

## Ce qui est déjà acquis, nativement

Un `Deployment` Kubernetes utilise par défaut la stratégie `RollingUpdate` : quand
l'image d'un service change (nouveau tag poussé par la CI), Kubernetes remplace les
pods progressivement, sans coupure de service -- il ne détruit jamais tous les
anciens pods avant que les nouveaux soient prêts.

Rien à coder pour l'avoir : c'est le comportement par défaut de tout `Deployment`
créé par nos charts Helm (`charts/*/templates/deployment.yaml`).

## Paramètres à vérifier/expliciter dans les charts

Actuellement, aucun `strategy` explicite n'est défini -> Kubernetes applique ses
valeurs par défaut (`maxSurge: 25%`, `maxUnavailable: 25%`). Pour un projet de démo
avec 1 seul replica en dev, ça n'a pratiquement aucun effet visible (pas grand-chose
à "surger" avec 1 pod) -- mais utile à documenter et à expliciter pour la prod.

Ajout recommandé dans `templates/deployment.yaml` (optionnel, mais montre qu'on
maîtrise le paramètre plutôt que de laisser le défaut implicite) :

```yaml
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1          # 1 pod supplémentaire max pendant la mise à jour
      maxUnavailable: 0    # jamais moins de pods que prévu -- zéro downtime
```

`maxUnavailable: 0` est le choix le plus sûr pour une démo : garantit qu'il y a
toujours au moins autant de pods disponibles qu'avant, au prix d'un peu plus de
ressources consommées pendant la transition (le nouveau pod démarre avant que
l'ancien soit tué).

## Comment le vérifier concrètement

```bash
kubectl set image deployment/user-service user-service=<nouvelle-image>:<tag> -n demo-app
kubectl rollout status deployment/user-service -n demo-app
kubectl rollout history deployment/user-service -n demo-app
```

`kubectl get pods -n demo-app -w` pendant la commande montre les anciens pods
`Terminating` pendant que les nouveaux passent `Running` -- jamais les deux à zéro
en même temps si `maxUnavailable: 0`.

Rollback si besoin :
```bash
kubectl rollout undo deployment/user-service -n demo-app
```

## Ce qui est volontairement laissé de côté : le Canary (Argo Rollouts)

Le ticket mentionne aussi un déploiement canary via Argo Rollouts (bascule
progressive du trafic entre ancienne et nouvelle version, avec analyse automatique
des métriques). C'est un chantier à part entière :

- installation du controller Argo Rollouts
- remplacement des `Deployment` par des `Rollout` (CRD différente)
- configuration du traffic splitting avec l'ALB Controller (`TrafficRouting`)
- définition de métriques d'analyse (ex: taux d'erreur 5xx via Prometheus) pour
  décider automatiquement de continuer ou d'annuler le rollout

Non fait pour l'instant -- le rolling update natif suffit largement pour une démo,
et le canary demande un investissement de temps disproportionné par rapport au
bénéfice pour ce projet. À reprendre plus tard si le temps le permet, séparément.