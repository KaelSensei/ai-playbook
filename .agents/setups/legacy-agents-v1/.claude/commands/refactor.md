---
name: refactor
description: >
  Refactoring sécurisé avec filet de tests. refactoring-guide orchestre, dev-senior-a implémente,
  dev-senior-b review après chaque étape. Chaque micro-incrément doit être vert avant le suivant.
argument-hint: '[module ou cible de refactoring]'
---

# /refactor

Update `tasks/current_task.md` : status=REFACTOR, module=$ARGUMENTS

---

## Prérequis Absolus

Vérifier avant de commencer :

```
[ ] /understand $ARGUMENTS fait → fiche dans legacy-map.md
[ ] /characterize $ARGUMENTS fait → tests de caractérisation en place
[ ] Tous les tests passent (lancer le runner maintenant)
```

Si l'un manque → arrêter. Pas de refactoring sans filet.

```bash
[runner] tests/  # DOIT être tout vert avant de commencer
```

---

## Phase 1 — Établir le plan de refactoring

Invoquer `refactoring-guide` pour établir le plan :

```
Tu es refactoring-guide.
Charge .claude/agents/refactoring-guide.md.
Charge project-architecture.md, legacy-map.md.
Charge refactoring-patterns, legacy-patterns, testing-patterns skills.

Objectif de refactoring : $ARGUMENTS
Tests de caractérisation en place : [liste depuis legacy-map.md]

Propose un plan de refactoring en micro-étapes :
- Chaque étape doit être atomique (< 30 min)
- Chaque étape doit être committable en isolation
- Chaque étape doit laisser les tests verts
- Utiliser le catalogue Fowler (nommer chaque refactoring)
- Ordre : du plus sûr au plus risqué

Préciser pour chaque étape :
- Nom du refactoring (catalogue Fowler)
- Changement exact à faire
- Risque estimé
```

Présenter le plan à l'utilisateur. **Gate** : _"Ce plan est-il correct ? Des étapes à modifier ?"_

---

## Phase 2 — Exécution micro-incrémentale

Pour chaque étape du plan :

### 2a. dev-senior-a implémente l'étape

```
Tu es dev-senior-a. Mode refactoring legacy.
Charge .claude/agents/dev-senior-a.md.
Charge project-architecture.md, legacy-map.md.
Charge refactoring-patterns, legacy-patterns skills.

Étape [N] : [nom refactoring] — [description]
Tests de caractérisation de référence : [liste]

RÈGLES :
- Ne changer QUE ce qui est décrit dans cette étape
- Ne PAS améliorer le comportement (refactoring pur)
- Lancer les tests après le changement

Output requis :
- Diff du changement
- Output du runner (TOUS les tests doivent passer)
```

### 2b. dev-senior-b review l'étape

```
Tu es dev-senior-b.
Charge team--skill-review.

Review cette étape de refactoring :
[diff]

Vérifier :
1. Tests de caractérisation toujours verts ?
2. Comportement préservé (aucun changement de logique) ?
3. Changement minimal (pas de scope creep) ?
4. Étape réversible par git revert ?
```

Appliquer `team--skill-refine` si nécessaire.

### 2c. Commit

```bash
git add .
git commit -m "refactor([module]): [nom refactoring Fowler]"
```

---

## Phase 3 — Review finale (tous les agents)

Quand toutes les étapes sont faites :

Spawner TOUS les agents sur le diff complet :

```
Review le refactoring complet de $ARGUMENTS.
Vérifier : comportement préservé, tests toujours verts,
cohérence du résultat, dette réduite ou maintenue.
```

Appliquer `team--skill-refine` jusqu'à APPROVE unanime.

---

## Règle d'Urgence

Si un test de caractérisation passe au rouge à n'importe quelle étape :

```
1. git revert HEAD  (revenir immédiatement)
2. Analyser pourquoi (le refactoring a changé le comportement)
3. Découper en étape plus petite
4. Recommencer
```

Ne jamais "corriger" un test de caractérisation qui échoue. Un test de caractérisation qui échoue =
un comportement changé = une régression.

Update `tasks/current_task.md` : status=IDLE

```
✅ Refactoring terminé : $ARGUMENTS
Étapes : [N] micro-incréments
Tests : [N] passants (aucune régression)
Review finale : APPROVE unanime
```
