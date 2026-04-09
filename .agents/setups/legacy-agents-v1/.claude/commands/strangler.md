---
name: strangler
description: >
  Introduire du nouveau code autour du legacy (Strangler Fig). architect définit la frontière et
  l'ACL, dev-senior-a implémente en TDD, tous les agents reviewent. Le legacy n'est jamais modifié.
argument-hint: '[feature à envelopper]'
---

# /strangler

Update `tasks/current_task.md` : status=STRANGLER, module=$ARGUMENTS

---

## Prérequis

```
[ ] /understand sur le module legacy concerné → fiche dans legacy-map.md
[ ] Tests de caractérisation sur le comportement legacy de référence
    (pour détecter si le legacy change de façon inattendue)
```

---

## Phase 1 — Design de la frontière (architect)

```
Tu es architect.
Charge .claude/agents/architect.md.
Charge project-architecture.md, legacy-map.md, constants.md.
Charge strangler-fig, clean-code skills.

Feature à implémenter : $ARGUMENTS
Module legacy concerné : [depuis legacy-map.md]

Produis un design note Strangler Fig :
- Frontière entre legacy et nouveau code
- Anti-Corruption Layer (interface de traduction)
- Plan de migration en 3 phases (coexistence → redirection → suppression)
- Feature flag nécessaire ? comment ?
- Ce qu'on NE touche PAS dans le legacy
- TDD entry points pour le nouveau code
```

Présenter à l'utilisateur. **Gate** : _"La frontière est-elle correcte ?"_

---

## Phase 2 — Spec du nouveau code (spec-writer)

```
Tu es spec-writer.
Charge .claude/agents/spec-writer.md.
Charge project-architecture.md, data-architecture.md.
Charge clean-code, testing-patterns, team--skill-lookup skills.

Feature : $ARGUMENTS
Design note : [output de l'architect]

Produis une spec technique avec test list pour le NOUVEAU CODE uniquement.
Le legacy n'est pas spécifié ici — seulement le comportement nouveau.
```

Review parallèle par tous les agents (sauf legacy-analyst et archaeologist). Boucle jusqu'à APPROVE
unanime.

---

## Phase 3 — Implémenter l'Anti-Corruption Layer (dev-senior-a, TDD)

```
Tu es dev-senior-a. Mode NOUVEAU CODE — TDD strict.
Charge .claude/agents/dev-senior-a.md.

Implémenter l'ACL en TDD :
1. Écrire un test pour la traduction legacy → nouveau format
2. RED → GREEN → BLUE
3. Écrire un test pour la traduction nouveau → legacy format
4. RED → GREEN → BLUE

L'ACL doit être testable sans le legacy (fakes/stubs).
```

dev-senior-b review le test d'abord, puis le code.

---

## Phase 4 — Implémenter le nouveau code (TDD strict)

Pour chaque item de la test list de la spec :

### 4a. RED — dev-senior-a écrit un test

```
Tu es dev-senior-a. Mode NOUVEAU CODE — TDD strict.
Test suivant de la spec : [item]
Écrire UN test. Lancer. Doit être RED pour la bonne raison.
```

### 4b. dev-senior-b review le test

### 4c. GREEN — minimum de code

### 4d. Tous les agents reviewent en parallèle

### 4e. BLUE — refactoring

### 4f. Commit

```bash
git commit -m "feat([feature]): [description comportement — nouveau code]"
```

---

## Phase 5 — Coexistence (feature flag)

Le nouveau code est prêt mais pas encore en production. Mettre en place le feature flag :

```javascript
if (featureFlags.isEnabled('new-$ARGUMENTS', context)) {
  return newService.handle(request); // nouveau code
}
return legacyModule.handle(request); // legacy inchangé
```

---

## Phase 6 — Review finale

Tous les agents sur le diff complet :

```
Review le Strangler Fig complet pour $ARGUMENTS.
- Le legacy est-il INCHANGÉ ?
- L'ACL traduit-il correctement dans les deux sens ?
- Le feature flag permet-il un rollback immédiat ?
- Le nouveau code est-il testable indépendamment du legacy ?
```

Update `tasks/current_task.md` : status=IDLE

```
✅ Strangler Fig prêt : $ARGUMENTS
Legacy : inchangé
Nouveau code : TDD, [N] tests passants
Feature flag : en place
Prêt pour : activer progressivement (1% → 10% → 100%)
```
