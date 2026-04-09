---
name: task
description: >
  Point d'entrée universel Legacy. Décris ta tâche en langage naturel. L'orchestrateur vérifie
  d'abord si le module est cartographié et si un filet de tests existe. Si non, il lance understand
  + characterize avant tout. Tu ne peux pas contourner cette étape.
argument-hint: '[description libre de la tâche]'
---

# /task (Legacy)

Update `tasks/current_task.md` : status=ORCHESTRATING, task=$ARGUMENTS

---

## Étape 1 — Orchestrateur analyse

```
Tu es orchestrator.
Charge .claude/agents/orchestrator.md.
Charge project-architecture.md, legacy-map.md, constants.md.
Charge le tableau ## Agent Team depuis CLAUDE.md.

Tâche reçue : $ARGUMENTS

PREMIÈRE QUESTION : le module concerné est-il dans legacy-map.md ?
DEUXIÈME QUESTION : des tests de caractérisation existent-ils ?

Si non à l'une des deux → plan préalable obligatoire.
Sinon → analyser le type de tâche et la complexité.

Produis ton plan complet.
```

Présenter le plan. **Gate** : _"Ce plan est-il correct ?"_

---

## Étape 2 — Exécution selon le plan

### Si filet manquant → Prérequis d'abord

```
Filet manquant. Ordre d'exécution :

1. /understand [module] → legacy-analyst + archaeologist
2. /characterize [module] → characterization-tester
3. Revenir à /task $ARGUMENTS une fois le filet en place
```

Spawner legacy-analyst + archaeologist en parallèle. Puis characterization-tester. Puis relancer
l'analyse.

---

### Si filet en place → Exécution directe

**Refactoring (niveau 1-2) :**

```
refactoring-guide → plan micro-incréments
dev-senior-a → implémentation
dev-senior-b → review après chaque étape
```

**Nouveau code Strangler (niveau 2-3) :**

```
→ /strangler $ARGUMENTS
```

**Bug fix :**

```
characterization-tester → test de régression d'abord
dev-senior-a → fix
dev-senior-b → review
```

**Complexe (niveau 3) :**

```
→ /spec → /build (flows formels complets)
```

---

## Étape 3 — Complétion

Update `tasks/current_task.md` : status=IDLE

---

## Exemples de Routing

| Tâche                                     | Filet ? | Niveau    | Action                                |
| ----------------------------------------- | ------- | --------- | ------------------------------------- |
| "comprendre le module billing"            | N/A     | explore   | /understand billing                   |
| "corriger le bug de calcul de remise"     | non     | prérequis | understand → characterize → fix       |
| "corriger le bug de calcul de remise"     | oui     | 2         | test régression → fix → review        |
| "refactorer UserController (2000 lignes)" | non     | prérequis | understand → characterize → refactor  |
| "refactorer UserController (2000 lignes)" | oui     | 3         | /refactor micro-incrémental           |
| "nouveau module de notifications"         | N/A     | 3         | /strangler (nouveau code TDD)         |
| "audit de la dette technique"             | N/A     | explore   | /debt                                 |
| "migrer l'envoi d'email vers SendGrid"    | non     | prérequis | understand → characterize → strangler |
