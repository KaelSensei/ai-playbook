---
name: task
description: >
  Point d'entrée universel. Décris ta tâche en langage naturel. L'orchestrateur analyse la
  complexité, décide quels agents spawner et dans quel ordre, puis lance l'exécution. Une correction
  CSS ou une nouvelle feature complète — même commande.
argument-hint: '[description libre de la tâche]'
---

# /task

Update `tasks/current_task.md` : status=ORCHESTRATING, task=$ARGUMENTS

---

## Étape 1 — Orchestrateur analyse la tâche

```
Tu es orchestrator.
Charge .claude/agents/orchestrator.md.
Charge project-architecture.md, data-architecture.md, constants.md.
Charge le tableau ## Agent Team depuis CLAUDE.md.

Tâche reçue : $ARGUMENTS

Analyse :
1. Quels domaines sont touchés ?
2. Quelle est la complexité (niveau 1, 2, ou 3) ?
3. Quels agents spawner ?
4. Quel flow utiliser ?

Produis ton plan d'exécution complet avant de spawner quoi que ce soit.
```

Présenter le plan à l'utilisateur. **Gate** : _"Ce plan est-il correct ?"_ Attendre confirmation
avant d'exécuter — sauf si tâche niveau 1 évidente.

---

## Étape 2 — Exécution selon le niveau

### Niveau 1 — Direct

Spawner l'agent unique identifié :

```
Tu es [AGENT].
Charge context docs et skills selon Agent Team table.

Tâche : $ARGUMENTS

Implémente directement. Pas de spec formelle nécessaire.
Lance les tests après chaque changement.
Output : diff + tests passants.
```

---

### Niveau 2 — Implémentation + Review

**2a. Agent propriétaire implémente :**

```
Tu es [AGENT_PROPRIETAIRE].
Tâche : $ARGUMENTS

Implémente. TDD si applicable.
Output : diff + tests.
```

**2b. Agent reviewer en parallèle ou juste après :**

```
Tu es [AGENT_REVIEWER].
Charge team--skill-review.
Review le diff de : $ARGUMENTS
```

Appliquer `team--skill-refine` si APPROVE_WITH_CHANGES.

---

### Niveau 3 — Flow complet

Rediriger vers les flows formels :

```
Complexité niveau 3 détectée.
Lancement du flow complet :

→ /spec [feature] pour produire la spec + test list
→ /build [spec] pour l'implémentation TDD
→ /review pour la review finale

Je lance /spec maintenant.
```

Enchaîner `/spec` → `/build` → `/review` automatiquement.

---

## Étape 3 — Complétion

Update `tasks/current_task.md` : status=IDLE

```
✅ Tâche complète : $ARGUMENTS
Niveau : [1/2/3]
Agents utilisés : [liste]
Flow : [direct / review / spec+build]
```

---

## Exemples de Routing Automatique

| Tâche                                            | Niveau | Agents                        | Flow           |
| ------------------------------------------------ | ------ | ----------------------------- | -------------- |
| "fix le padding du bouton submit"                | 1      | frontend-engineer             | direct         |
| "ajouter un champ `bio` au profil"               | 2      | dev-senior-a + data-engineer  | impl + review  |
| "nouveau système d'authentification JWT"         | 3      | tous                          | /spec → /build |
| "corriger le bug de calcul de TVA"               | 2      | dev-senior-a + dev-senior-b   | impl + review  |
| "migration PostgreSQL vers UUID"                 | 3      | data-engineer + tous          | /spec → /build |
| "mettre à jour le Dockerfile Node 18→20"         | 1      | devops-engineer               | direct         |
| "checkout multi-wallet MetaMask + WalletConnect" | 3      | frontend + backend + security | /spec → /build |
