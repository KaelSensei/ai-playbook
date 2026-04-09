---
name: review
description: >
  Review parallèle par tous les agents. Read-only. Verdict mergé. Sur n'importe quel diff avant de
  merger ou déployer.
argument-hint: '[fichiers, PR numéro, ou vide pour dernier commit]'
---

# /review

Update `tasks/current_task.md` : status=REVIEW

---

## Étape 1 — Déterminer l'input

| Argument         | Action              |
| ---------------- | ------------------- |
| Numéro PR        | `gh pr diff [N]`    |
| Chemins fichiers | Lire ces fichiers   |
| `staged`         | `git diff --cached` |
| Aucun            | `git diff HEAD~1`   |

Avant de lancer : vérifier que les tests passent.

```bash
[runner]  # tous les tests doivent passer
```

Si les tests échouent → arrêter. Reporter l'échec. Ne pas reviewer du code cassé.

---

## Étape 2 — Spawner tous les agents simultanément

Charger `team--skill-review` pour tous les agents. Lire le tableau `## Agent Team` dans `CLAUDE.md`.
Spawner TOUS les agents en même temps :

```
Tu es [AGENT_PERSONA]. Mode review uniquement — pas d'écriture de code.
Charge context docs et skills selon Agent Team table.
Charge team--skill-review.

Review le code suivant depuis ton angle disciplinaire uniquement.
Tous les agents reviewent en parallèle.

[diff / code]

Suivre le format team--skill-review exactement.
```

---

## Étape 3 — Merger les verdicts

Collecter tous les verdicts. Appliquer les règles de merge de `team--skill-review`.

```markdown
# Code Review

## Verdicts

| Agent             | Verdict   |
| ----------------- | --------- |
| product-owner     | [verdict] |
| ux-designer       | [verdict] |
| tech-lead         | [verdict] |
| architect         | [verdict] |
| dev-senior-a      | [verdict] |
| dev-senior-b      | [verdict] |
| qa-engineer       | [verdict] |
| security-reviewer | [verdict] |
| data-engineer     | [verdict] |
| devops-engineer   | [verdict] |

**Verdict global : APPROVE | APPROVE_WITH_CHANGES | REQUEST_REDESIGN**

---

## 🔴 Blockers

[Dédupliqué. Si flaggé par plusieurs agents : "(flaggé par N agents)"]

## 🟡 Improvements

[Dédupliqué]

## 🔵 Nits

[Dédupliqué]
```

---

## Étape 4 — Gate sécurité

Si le diff touche auth, sessions, données utilisateur, ou endpoints publics → `security-reviewer`
DOIT explicitement confirmer :

- Checklist OWASP complète
- Aucune vulnérabilité critique
- Rate limiting présent si applicable

Si `security-reviewer` retourne `REQUEST_REDESIGN` sur ces zones → verdict global =
`REQUEST_REDESIGN` sans exception.

Update `tasks/current_task.md` : status=IDLE
