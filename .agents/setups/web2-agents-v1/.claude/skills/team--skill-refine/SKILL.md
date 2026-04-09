---
name: team--skill-refine
description: >
  Protocole d'itération. Chargé quand un agent retourne APPROVE_WITH_CHANGES ou REQUEST_REDESIGN.
  Définit comment résoudre les conflits, prioriser les corrections, les router vers le bon agent et
  éviter les boucles infinies.
---

# Team Refinement Protocol

## Sur REQUEST_REDESIGN (arrêt immédiat)

1. Arrêter immédiatement — ne pas tenter de corriger en place
2. Citer le finding exact qui a déclenché le redesign
3. Identifier quel agent l'a soulevé et sa discipline
4. Escalader à l'utilisateur avec :
   - Le problème verbatim
   - L'agent qui l'a soulevé
   - Deux options : (a) revoir le design, (b) l'utilisateur accepte explicitement le risque
5. Si override → documenter dans `tasks/current_task.md` : _"[date] [agent] → risque accepté :
   [problème] — Raison : [raison utilisateur]"_
6. Jamais contourner silencieusement un `REQUEST_REDESIGN`

## Sur APPROVE_WITH_CHANGES (itérer)

### Étape 1 — Collecter

Rassembler toutes les améliorations de tous les agents en une liste unique.

### Étape 2 — Prioriser

```
1. Sécurité (security-reviewer)
2. Correctness / logique (dev-senior-a/b, qa-engineer)
3. Intégrité des données (data-engineer)
4. Architecture / dette (architect, tech-lead)
5. Déploiement / ops (devops-engineer)
6. UX / accessibilité (ux-designer)
7. Style / nits (tout agent)
```

### Étape 3 — Router

Assigner chaque correction à son agent propriétaire par discipline. Les corrections indépendantes
peuvent être adressées en parallèle.

### Étape 4 — Re-review

Après corrections :

- Périmètre : uniquement les zones modifiées, pas re-review complète
- Exception : si les changements sont larges → re-review complète
- Les agents sans amélioration → leur verdict précédent reste valable

### Étape 5 — Vérifier le compteur de boucles

- Maximum **3 boucles** de refinement avant d'escalader à l'utilisateur
- Si après la boucle 3 un agent retourne encore `APPROVE_WITH_CHANGES` sur le même problème →
  escalader : _"3 itérations sur [problème]. Décision utilisateur requise."_
- Ne jamais supprimer silencieusement un finding répété pour éviter l'escalade

## Médiation de Conflits

Quand deux agents sont en désaccord sur une décision technique :

1. Citer les deux positions verbatim
2. Identifier le vrai trade-off (perf vs maintenabilité, simplicité vs extensibilité)
3. Présenter à l'utilisateur : _"[Agent A] recommande X parce que [raison]. [Agent B] recommande Y
   parce que [raison]. Lequel préférez-vous ?"_
4. Le tech-lead peut arbitrer si l'utilisateur délègue
5. Documenter dans `tasks/current_task.md`

Ne jamais résoudre les conflits en choisissant l'option "la plus gentille" ou celle de l'agent le
plus senior. Surfacer le trade-off clairement.

## Préservation du Contexte entre Boucles

Chaque itération transmet aux agents :

- Le verdict précédent de chaque agent (pour vérifier que leurs problèmes ont été adressés)
- Le diff de ce qui a changé depuis leur dernière review
- Les context docs inchangés

L'orchestrateur trace :

- Problèmes soulevés par agent par boucle
- Problèmes corrigés et vérifiés fermés
- Problèmes encore ouverts après chaque boucle
