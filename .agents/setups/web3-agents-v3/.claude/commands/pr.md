---
name: pr
description: >
  Workflow PR complet. dev-senior-a crée la PR, dev-senior-b la review sur GitHub réel, si APPROVE
  dev-senior-a merge en auto, scribe documente. Remplace le merge manuel. Utiliser après /build ou
  /refactor terminé.
argument-hint: '[feature slug ou description]'
---

# /pr

Update `tasks/current_task.md` : status=PR, task=$ARGUMENTS

---

## Prérequis

```bash
# Vérifier que tout est propre
git status          # aucun fichier non commité
[runner]            # tous les tests passent
gh auth status      # GitHub CLI authentifié
```

Si tests en échec → arrêter. Pas de PR sur du rouge.

---

## Étape 1 — dev-senior-a crée la PR

```
Tu es dev-senior-a.
Charge .claude/agents/dev-senior-a.md.
Charge project-architecture.md.

Feature : $ARGUMENTS

Crée une Pull Request GitHub avec :

1. Titre : [type]([scope]): [description courte]
   Types : feat / fix / refactor / chore / docs / security

2. Description (template ci-dessous)

3. Labels appropriés : feature / bug / refactor / security / breaking-change

Lance :
gh pr create --title "[titre]" --body "[description]" --label "[labels]"
```

**Template de description PR :**

````markdown
## Description

[Ce que cette PR fait en 2-3 phrases — orienté utilisateur]

## Type de changement

- [ ] feat: nouvelle fonctionnalité
- [ ] fix: correction de bug
- [ ] refactor: refactoring sans changement de comportement
- [ ] security: correction de sécurité
- [ ] breaking: changement cassant

## Changements

- [liste des changements principaux]

## Tests

- [ ] Tests unitaires ajoutés/mis à jour
- [ ] Tests d'intégration si applicable
- [ ] Coverage maintenue ou améliorée

## Coverage

Avant : [X%] → Après : [Y%]

## Rollback

```bash
git revert [commit hash]
[commande migration rollback si applicable]
```
````

## Checklist

- [ ] Tests passants
- [ ] Linter propre
- [ ] Doc technique mise à jour si archi change
- [ ] Pas de secrets dans le code

```

Output : URL de la PR créée.

---

## Étape 2 — dev-senior-b review la PR GitHub réelle

```

Tu es dev-senior-b. Charge .claude/agents/dev-senior-b.md. Charge context docs et skills. Charge
team--skill-review.

PR à reviewer : [URL ou numéro]

Récupérer le diff complet : gh pr diff [numéro]

Lire aussi : gh pr view [numéro] ← description + metadata gh pr checks [numéro] ← état des CI checks

Review depuis ton angle : test d'abord, code ensuite. Vérifier que la description PR correspond au
code. Vérifier que les CI checks sont verts.

Soumettre la review sur GitHub : gh pr review [numéro] --approve --body "[commentaire]" ou gh pr
review [numéro] --request-changes --body "[commentaire]"

```

---

## Étape 3 — Résolution si REQUEST_CHANGES

Charger `team--skill-refine`.

dev-senior-a adresse les changements demandés.
Force-push sur la même branche.
dev-senior-b re-review.
Maximum 3 itérations avant escalade.

---


## Étape 3.5 — Smoke Tests (avant merge)

Spawner `qa-automation` en mode smoke :

```

Tu es qa-automation. Charge .claude/agents/qa-automation.md. Charge TEST_PLAN.md section Smoke
Tests. Charge .claude/observability.md.

Lance les smoke tests sur l'env de staging/preview.

```

Si smoke FAIL → merge bloqué. Corriger d'abord, relancer /pr.
Si smoke PASS → continuer vers le merge.

---
## Étape 4 — Merge si APPROVE

```

Tu es dev-senior-a.

PR approuvée : [numéro] CI checks : [verts]

Merger : gh pr merge [numéro] --squash --delete-branch

Message de commit squash : [type]([scope]): [description]

[corps optionnel si breaking change ou contexte important]

```

**Pourquoi squash ?**
Un commit propre par feature dans main.
Historique lisible. Revert simple.

---

## Étape 5 — scribe documente post-merge

```

Tu es scribe. Charge .claude/agents/scribe.md. Charge project-architecture.md, CHANGELOG.md,
PROGRESS.md.

Feature mergée : $ARGUMENTS Commit de merge : [hash]

Produire :

1. Entrée CHANGELOG.md
2. Mise à jour doc technique si archi a changé
3. ADR si décision d'archi prise pendant cette feature
4. Rollback plan dans docs/rollbacks/
5. Mise à jour PROGRESS.md (déplacer de "En Cours" vers "En Production")
6. Coverage delta si disponible

```

---

## Étape 6 — Complétion

Update `tasks/current_task.md` : status=IDLE

```

✅ PR mergée : $ARGUMENTS PR : #[numéro] Commit : [hash] Reviewer : dev-senior-b Merge :
dev-senior-a (squash) Doc : CHANGELOG.md + PROGRESS.md mis à jour ADR : [créé / non nécessaire]
Rollback : docs/rollbacks/[feature]-rollback.md

```

```
