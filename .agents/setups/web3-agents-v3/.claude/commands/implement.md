---
name: implement
description: >
  Implémente une spec Web3 en TDD strict adapté aux smart contracts. Cycle RED-GREEN-BLUE sur chaque
  item de la test list. Ordre obligatoire : unit → integration → fork → invariant. Requiert une spec
  approuvée depuis /spec.
argument-hint: '[slug de la spec]'
---

# /implement (Web3 — TDD Strict)

Update tasks/current_task.md: status=IMPLEMENT

---

## Phase 1 — Charger la spec et la test list

```
Charger .claude/specs/$ARGUMENTS.md
Extraire la test list ordonnée (4 niveaux obligatoires si valeur on-chain) :
  1. Unit tests (domain pur, pas de fork)
  2. Integration tests (interactions entre contrats)
  3. Fork tests (comportement sur mainnet réel)
  4. Invariant tests (propriétés qui doivent toujours tenir)
```

Afficher la test list. Gate utilisateur avant de démarrer.

---

## Phase 2 — Boucle TDD (un item à la fois)

### 🔴 RED — smart-contract-engineer écrit UN test

```
Tu es smart-contract-engineer.
Charge project-architecture.md SUMMARY.
Charge solidity-patterns → section pertinente uniquement.
Charge foundry-testing skill.

Spec : [contenu de .claude/specs/$ARGUMENTS.md]
Item suivant : [item de la test list]

PHASE RED :
Écrire UN test Foundry qui échoue.
Le test exprime le COMPORTEMENT attendu — pas l'implémentation.
Nommage : test_[comportement]_[condition]()
Lancer : forge test --match-test [nom] — doit être RED.
Vérifier que c'est un échec d'assertion, pas une erreur de compilation.

Output :
- Code du test
- forge test output (doit montrer FAIL)
- Raison de l'échec (assertion, pas import error)
```

**Gate RED** : si le test passe → il est mauvais → recommencer.

---

### 🔵 Review du TEST — dev-senior-b avant le code

```
Tu es dev-senior-b (mode Web3).
Charge testing-patterns, solidity-patterns skills.
Charge team--skill-review.

Review du TEST uniquement — pas de code de prod.

Vérifier :
- Le test exprime-t-il le comportement (pas l'implémentation) ?
- L'assertion est-elle précise (pas juste assertTrue) ?
- Le test est-il indépendant (setUp propre) ?
- Les cheatcodes sont-ils appropriés (vm.prank, deal, etc.) ?
- Pour les fonctions value : ReentrancyGuard testé ?
- Pour les oracles : freshness et deviation testés ?

Verdict : APPROVE / APPROVE_WITH_CHANGES / REQUEST_REDESIGN
```

Si REQUEST_REDESIGN → réécrire le test. Si APPROVE → GREEN.

---

### 🟢 GREEN — smart-contract-engineer implémente le minimum

```
Tu es smart-contract-engineer.
PHASE GREEN :

Écrire le MINIMUM de code Solidity pour faire passer le test.
Règles SUPER GREEN (adapté Web3) :
  ✅ Test passe
  ✅ Nommage expressif (pas de a, b, x comme variables)
  ✅ CEI enforced si transfert de valeur
  ✅ Pas de magic numbers — utiliser des constantes nommées
  ✅ Events émis correctement

Lancer : forge test --match-test [nom]
TOUS les tests précédents doivent passer.

Output :
- Code Solidity ajouté
- forge test output (ALL PASS)
- Gas: forge test --gas-report pour cette fonction
```

---

### 🔵 MAYBE REFACTOR — évaluer, ne pas refactorer par principe

```
Tu es smart-contract-engineer.
PHASE MAYBE REFACTOR :

Évaluer :
1. Duplication détectée ? → extraire une fonction interne
2. Magic number ? → extraire en constante
3. Mauvaise couche ? (logique dans le test plutôt que dans le contrat) → déplacer
4. Gas optimisable sans changer le comportement ? → optimiser

Si tout va → SKIP. Justifier le skip.
Jamais refactorer si ça change le comportement observable.
Lancer forge test après chaque changement de refactoring.
```

---

### ✅ Commit et item suivant

```bash
git add .
git commit -m "test([contract]): [comportement testé]"
```

Cocher l'item dans tasks/current_task.md. Item suivant → retour à RED.

---

## Phase 3 — Verify (test list épuisée)

```bash
# Tous les niveaux
forge test                          # unit + integration
forge test --fork-url $MAINNET_RPC  # fork tests
forge test --match-contract Invariant # invariant tests

# Gas snapshot
forge snapshot

# Slither si installé
slither . --config-file slither.config.json
```

---

## Phase 4 — Review finale (tous les agents)

Spawner TOUS les agents en parallèle sur le diff complet. Appliquer team--skill-refine jusqu'à
APPROVE unanime.

Update tasks/current_task.md: status=IDLE

```
✅ Implémentation terminée : $ARGUMENTS
Tests : unit [N] + integration [N] + fork [N] + invariant [N]
Gas snapshot : sauvegardé
Review finale : APPROVE unanime
Prêt pour : /pr $ARGUMENTS
```
