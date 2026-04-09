---
name: build
description: >
  Implémenter en TDD strict. dev-senior-a code (RED→GREEN→BLUE), dev-senior-b review le test EN
  PREMIER puis le code, tous les agents reviewent en parallèle à chaque étape. Requiert une spec
  approuvée.
argument-hint: '[slug de la spec]'
---

# /build

Update `tasks/current_task.md` : status=BUILD, Active Spec: .claude/specs/$ARGUMENTS.md

---

## Phase 1 — CHARGER LA TEST LIST

Charger `.claude/specs/$ARGUMENTS.md`. Extraire la test list ordonnée. L'afficher à l'utilisateur.
Confirmer avant de démarrer.

Update `tasks/current_task.md` : Test List en cours = [liste complète]

---

## Phase 2 — BOUCLE TDD (un item à la fois)

Répéter pour chaque item de la test list dans l'ordre.

### 2a. RED — dev-senior-a écrit UN test

```
Tu es dev-senior-a.
Charge .claude/agents/dev-senior-a.md.
Charge context docs et skills selon Agent Team table.
Charge la spec : [contenu de .claude/specs/$ARGUMENTS.md]

Test list restante : [items non cochés]
Prochain item : [item suivant]

PHASE RED uniquement.

Écris UN test pour ce comportement.
Lance le test runner. Le test DOIT échouer.
Vérifie que c'est un échec d'assertion (pas une erreur de compilation).

Output requis :
- Code du test
- Output du runner (must be FAIL)
- Raison de l'échec (doit être l'assertion, pas l'import)
```

**Gate automatique** : si le test passe → le test est mauvais → recommencer.

---

### 2b. REVIEW DU TEST — dev-senior-b en premier

```
Tu es dev-senior-b.
Charge .claude/agents/dev-senior-b.md.
Charge context docs et skills selon Agent Team table.
Charge team--skill-review.

REVIEW DU TEST UNIQUEMENT — pas du code de prod (il n'existe pas encore).

Test à reviewer : [test écrit par dev-senior-a]

Questions :
- Ce test teste-t-il le bon comportement ?
- L'assertion est-elle précise ?
- Le test est-il indépendant ?
- Le test échouerait-il si le code était supprimé ?
- Le nom décrit-il clairement le comportement ?

Verdict : APPROVE | APPROVE_WITH_CHANGES | REQUEST_REDESIGN
```

Si `REQUEST_REDESIGN` → dev-senior-a réécrit le test. Si `APPROVE_WITH_CHANGES` → corrections,
re-review. Si `APPROVE` → passer à GREEN.

---

### 2c. GREEN — dev-senior-a écrit le minimum de code

```
Tu es dev-senior-a.
PHASE GREEN uniquement.

Test approuvé : [test]
Tous les tests existants : [liste]

Écris le MINIMUM de code pour faire passer le test.
Hard-code si nécessaire. Duplication permise.
Lance le runner : TOUS les tests doivent passer.

Output requis :
- Code ajouté/modifié
- Output du runner (must be ALL PASS)
- "Sins committed" : shortcuts, hardcode, duplication
```

**Gate automatique** : si un test regression → corriger avant de continuer.

---

### 2d. PAIR REVIEW — tous les agents en parallèle

Charger `team--skill-review` pour tous les agents. Spawner TOUS les agents du tableau
`## Agent Team` simultanément :

```
Tu es [AGENT_PERSONA]. Mode review — pas d'écriture de code.
Charge context docs et skills.
Charge team--skill-review.

Review cette étape TDD depuis ton angle disciplinaire.
Diff de l'étape : [test + code GREEN]
Spec : [spec complète]

Note : le code est en phase GREEN — duplication et hardcode sont normaux.
Review la correctness et les problèmes structurels, pas la propreté.
```

Collecter verdicts. Appliquer `team--skill-refine` si nécessaire.

---

### 2e. BLUE — dev-senior-a refactore

```
Tu es dev-senior-a.
PHASE BLUE uniquement.

Sins listés en GREEN : [liste]
Code actuel : [code]

Élimine la duplication. Améliore le nommage.
PAS de nouvelle fonctionnalité.
Lance le runner à chaque étape de refactoring.
Tous les tests doivent rester verts.
```

---

### 2f. COMMIT et item suivant

```bash
git add .
git commit -m "test([scope]): [item de la test list]"
```

Cocher l'item dans `tasks/current_task.md`. Passer à l'item suivant. Retourner à 2a.

---

## Phase 3 — VERIFY (quand test list épuisée)

```bash
[runner] --coverage    # coverage ne doit pas régresser
[linter]               # zero warnings
```

---

## Phase 4 — REVIEW FINALE (diff complet)

Spawner TOUS les agents sur le diff complet :

```
Review COMPLÈTE de l'implémentation de $ARGUMENTS.
Regarder les effets d'interaction entre étapes.
L'implémentation correspond-elle à la spec ?
La test list est-elle entièrement couverte ?
```

Boucle avec `team--skill-refine` jusqu'à `APPROVE` unanime.

## Phase 5 — scribe documente

Spawner `scribe` en parallèle avec la review finale :

```
Tu es scribe.
Feature terminée :
Commit range : [premier commit du build..HEAD]

Produire :
1. Entrée CHANGELOG.md
2. Mise à jour doc technique si archi a changé
3. ADR si décision d'archi prise pendant ce build
4. Rollback plan dans docs/rollbacks/
5. Mise à jour PROGRESS.md
```

Update `tasks/current_task.md` : status=IDLE

```
✅ Build complet
  Feature : $ARGUMENTS
  Tests : [N] passants
  Test list : [N/N] items couverts
  Review finale : APPROVE unanime
```
