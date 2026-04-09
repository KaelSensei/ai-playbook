---
name: characterize
description: >
  Écrire des tests de caractérisation pour figer le comportement existant. Obligatoire avant
  /refactor. characterization-tester orchestre, dev-senior-b review. Produit un filet de tests qui
  protège contre les régressions.
argument-hint: '[module à caractériser]'
---

# /characterize

Update `tasks/current_task.md` : status=CHARACTERIZE, module=$ARGUMENTS

**Prérequis** : `/understand $ARGUMENTS` doit avoir été fait. Si pas de cartographie dans
`legacy-map.md` → lancer `/understand` d'abord.

---

## Phase 1 — Vérifier les prérequis

Lire `legacy-map.md` pour `$ARGUMENTS`. Vérifier que la fiche module existe et contient :

- Les seams disponibles
- Le niveau de risque

Si absent → arrêter. Demander de lancer `/understand $ARGUMENTS` d'abord.

---

## Phase 2 — Plan de caractérisation

Invoquer `characterization-tester` pour établir un plan :

```
Tu es characterization-tester.
Charge .claude/agents/characterization-tester.md.
Charge project-architecture.md, legacy-map.md.
Charge testing-patterns, legacy-patterns skills.

Module à caractériser : $ARGUMENTS
Seams disponibles : [depuis legacy-map.md]

Établis un plan de caractérisation :
1. Quels comportements sont les plus importants à figer ?
   (priorité : chemins les plus utilisés, plus risqués)
2. Dans quel ordre les aborder ?
3. Quels seams utiliser pour chaque comportement ?
4. Quelles données de test utiliser ? (réelles si possible)

Produire : liste ordonnée des comportements à caractériser
```

Présenter le plan à l'utilisateur. **Gate** : _"Ce plan couvre-t-il les comportements critiques ?"_

---

## Phase 3 — Écrire les tests (un comportement à la fois)

Pour chaque comportement du plan :

### 3a. characterization-tester écrit le test intentionnellement faux

```
Tu es characterization-tester.

Comportement à caractériser : [comportement]
Seam à utiliser : [seam]

Étape 1 : écrire un test avec assert == "???"
Étape 2 : lancer le test
Étape 3 : noter le résultat RÉEL
Étape 4 : mettre à jour le test avec la valeur réelle
Étape 5 : ajouter un commentaire expliquant ce comportement
```

### 3b. dev-senior-b review le test de caractérisation

```
Tu es dev-senior-b.
Charge legacy-patterns, testing-patterns, team--skill-review.

Review ce test de caractérisation :
[test]

Vérifier :
- Le test documente-t-il le comportement réel (pas supposé) ?
- L'assertion est-elle précise ?
- Le test est-il indépendant (pas d'état global) ?
- Le commentaire explique-t-il clairement ce qui est documenté ?
- Le test échouerait-il si le comportement changeait ?
```

Appliquer `team--skill-refine` si nécessaire.

---

## Phase 4 — Validation du filet

Quand tous les comportements du plan sont couverts :

```bash
# Lancer tous les tests de caractérisation
[runner] tests/characterization/

# Tous doivent passer — c'est la baseline
```

---

## Phase 5 — Mise à jour legacy-map.md

Ajouter dans la section "Comportements Figés" de `legacy-map.md` :

```markdown
- [x] [description comportement] — [fichier_test:ligne] — [date]
```

Update `tasks/current_task.md` :

- Tests de Caractérisation en place : [liste]
- status=IDLE

```
✅ Caractérisation terminée : $ARGUMENTS
Comportements figés : [N]
Tests passants : [N/N]

Filet en place. Prêt pour :
→ /refactor $ARGUMENTS   (si objectif = refactoring)
→ /strangler $ARGUMENTS  (si objectif = envelopper avec nouveau code)
```
