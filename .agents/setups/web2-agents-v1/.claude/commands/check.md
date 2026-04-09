---
name: check
description: >
  Review qualité ciblée : qa-engineer + security-reviewer + data-engineer en parallèle.
  Complémentaire à /review — focus sur couverture de tests, vulnérabilités et intégrité des données.
  Utiliser avant tout déploiement en staging ou production.
argument-hint: '[fichiers, PR numéro, ou vide pour dernier commit]'
---

# /check

Update `tasks/current_task.md` : status=CHECK

---

## Contexte

`/check` est plus ciblé que `/review`. Il lance uniquement les 3 agents spécialisés qualité :

- `qa-engineer` — couverture comportementale, edge cases manquants
- `security-reviewer` — OWASP, vulnérabilités, secrets
- `data-engineer` — migrations, indexes, N+1, intégrité

Utiliser `/review` pour une review complète d'équipe. Utiliser `/check` pour un double-check ciblé
avant déploiement.

---

## Étape 1 — Déterminer l'input

Même logique que `/review` :

- Numéro PR → `gh pr diff [N]`
- Vide → `git diff HEAD~1`
- `staged` → `git diff --cached`

Lancer les tests :

```bash
[runner]             # must pass
[runner] --coverage  # afficher le rapport de couverture
```

Passer le rapport de couverture à `qa-engineer`.

---

## Étape 2 — Spawner les 3 agents en parallèle

**qa-engineer prompt :**

```
Tu es qa-engineer.
Charge .claude/agents/qa-engineer.md.
Charge project-architecture.md, data-architecture.md.
Charge testing-patterns, team--skill-review.

Review la couverture de tests du diff suivant.
Rapport de couverture : [coverage output]
Spec de référence (si disponible) : [spec]

Focus : manques de couverture, edge cases non testés,
ACs non couverts, tests existants qui pourraient manquer.
```

**security-reviewer prompt :**

```
Tu es security-reviewer.
Charge .claude/agents/security-reviewer.md.
Charge project-architecture.md, constants.md.
Charge security-web2, team--skill-review.

Review sécurité du diff suivant.
Parcourir la checklist OWASP complète.
Vérifier : injection, auth, données sensibles, access control,
misconfiguration, XSS, rate limiting, input validation, secrets.
```

**data-engineer prompt :**

```
Tu es data-engineer.
Charge .claude/agents/data-engineer.md.
Charge project-architecture.md, data-architecture.md.
Charge database-patterns, team--skill-review.

Review des aspects data du diff suivant.
Vérifier : migrations zero-downtime, indexes manquants,
N+1 queries, intégrité des données, soft delete respecté,
pagination sur les listes.
```

---

## Étape 3 — Présenter les résultats

```markdown
# Check Report

## qa-engineer

**Verdict** : [verdict] [findings]

## security-reviewer

**Verdict** : [verdict] [findings]

## data-engineer

**Verdict** : [verdict] [findings]

---

## Verdict Global : APPROVE | APPROVE_WITH_CHANGES | REQUEST_REDESIGN

### 🔴 Blockers Critiques

[dédupliqué cross-agents]

### 🟡 À Corriger

[dédupliqué]
```

---

## Étape 4 — Gate de déploiement

Avant tout déploiement en prod, les 3 verdicts DOIVENT être `APPROVE`.

Si `REQUEST_REDESIGN` → bloquer le déploiement, corriger, relancer `/check`. Si
`APPROVE_WITH_CHANGES` → décision utilisateur : corriger ou accepter le risque documenté.

Update `tasks/current_task.md` : status=IDLE
