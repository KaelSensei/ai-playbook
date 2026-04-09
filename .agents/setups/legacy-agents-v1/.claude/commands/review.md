---
name: review
description: >
  Review parallèle legacy-aware. Tous les agents reviewent simultanément. Vérification spéciale : le
  comportement legacy est-il préservé ? Les tests de caractérisation passent-ils ?
argument-hint: '[fichiers, PR numéro, ou vide pour dernier commit]'
---

# /review

Update `tasks/current_task.md` : status=REVIEW

---

## Étape 1 — Déterminer l'input et vérifier les tests

| Argument  | Action              |
| --------- | ------------------- |
| Numéro PR | `gh pr diff [N]`    |
| Fichiers  | Lire ces fichiers   |
| `staged`  | `git diff --cached` |
| Aucun     | `git diff HEAD~1`   |

**Vérification critique avant review :**

```bash
[runner]  # tous les tests doivent passer

# Si des tests de caractérisation existent pour les modules touchés :
[runner] tests/characterization/  # TOUS doivent passer
```

Si des tests de caractérisation échouent → arrêter. Un test de caractérisation rouge = comportement
changé = régression possible. Ne pas continuer sans analyse.

---

## Étape 2 — Identifier le type de changement

Lire le diff. Catégoriser :

| Type                     | Ce qui change               | Mode review                       |
| ------------------------ | --------------------------- | --------------------------------- |
| Refactoring pur          | Structure sans comportement | Vérifier comportement préservé    |
| Nouveau code (Strangler) | Ajout autour du legacy      | Vérifier que le legacy est intact |
| Bug fix                  | Comportement corrigé        | Vérifier le test de régression    |
| Feature nouvelle         | Nouveau comportement        | Review standard                   |

Communiquer le type identifié aux agents dans leur prompt.

---

## Étape 3 — Spawner tous les agents en parallèle

Charger `team--skill-review` pour tous les agents. Spawner TOUS les agents du tableau
`## Agent Team` simultanément :

```
Tu es [AGENT_PERSONA].
Charge context docs et skills selon Agent Team table.
Charge team--skill-review.

Type de changement identifié : [type]
Module(s) concerné(s) : [depuis legacy-map.md si cartographié]
Tests de caractérisation en place : [oui/non/liste]

Review depuis ton angle disciplinaire.

Points d'attention legacy spécifiques :
- Si refactoring : comportement est-il strictement préservé ?
- Si Strangler : le legacy est-il inchangé ?
- Si bug fix : y a-t-il un test de régression ?
- Si feature : y a-t-il des tests de caractérisation sur le legacy touché ?

[diff / code]

Suivre le format team--skill-review exactement.
```

---

## Étape 4 — Gate sécurité legacy

Sur du code legacy, les vulnérabilités les plus courantes sont :

- SQL injection par concaténation de string
- Secrets hardcodés découverts lors du refactoring
- Dépendances obsolètes exposées

`security-reviewer` doit confirmer :

- Checklist OWASP + checklist legacy spécifique complète
- Aucun secret découvert et laissé en place
- Aucune injection introduite ou exposée

---

## Étape 5 — Merger les verdicts

```markdown
# Code Review (Legacy-Aware)

## Verdicts

| Agent                   | Verdict   |
| ----------------------- | --------- |
| legacy-analyst          | [verdict] |
| characterization-tester | [verdict] |
| refactoring-guide       | [verdict] |
| dev-senior-a            | [verdict] |
| dev-senior-b            | [verdict] |
| tech-lead               | [verdict] |
| architect               | [verdict] |
| security-reviewer       | [verdict] |
| data-engineer           | [verdict] |

**Verdict global : APPROVE | APPROVE_WITH_CHANGES | REQUEST_REDESIGN**

## Tests de Caractérisation

- En place : ✅ / ❌
- Tous passants : ✅ / ❌

## 🔴 Blockers

## 🟡 Improvements

## 🔵 Nits
```

Update `tasks/current_task.md` : status=IDLE
