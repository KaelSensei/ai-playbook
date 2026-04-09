---
name: task
description: >
  Point d'entrée universel Web3. Décris ta tâche en langage naturel. L'orchestrateur vérifie d'abord
  si ça touche des contrats (= niveau 3 automatique), puis analyse la complexité et lance les bons
  agents.
argument-hint: '[description libre de la tâche]'
---

# /task (Web3)

Update `tasks/current_task.md` : status=ORCHESTRATING, task=$ARGUMENTS

---

## Étape 1 — Orchestrateur analyse

```
Tu es orchestrator.
Charge .claude/agents/orchestrator.md.
Charge project-architecture.md, data-architecture.md, constants.md.
Charge le tableau ## Agent Team depuis CLAUDE.md.

Tâche reçue : $ARGUMENTS

PREMIÈRE QUESTION : est-ce que ça touche un contrat ou de la valeur ?
Si oui → niveau 3 immédiat, smart-contract-engineer obligatoire.
Sinon → analyser les domaines et la complexité.

Produis ton plan d'exécution.
```

Présenter le plan. **Gate** : _"Ce plan est-il correct ?"_

---

## Étape 2 — Exécution selon le niveau

### Niveau 1 — Direct (frontend/docs uniquement)

```
Tu es [AGENT].
Tâche : $ARGUMENTS
Implémenter directement. Lancer les tests.
```

---

### Niveau 2 — Modéré (frontend + indexer)

**Agent propriétaire → implémente** **Agent reviewer → review en parallèle ou juste après**
Appliquer `team--skill-refine` si nécessaire.

---

### Niveau 3 — Contrats ou complexe (flow complet)

```
Niveau 3 détecté — smart-contract-engineer obligatoire.
Lancement : /spec → /implement → /review
```

Enchaîner les flows formels automatiquement.

---

## Étape 3 — Complétion

Update `tasks/current_task.md` : status=IDLE

---

## Exemples de Routing

| Tâche                                                      | Niveau | Agents                              | Flow               |
| ---------------------------------------------------------- | ------ | ----------------------------------- | ------------------ |
| "fix le style du bouton Connect Wallet"                    | 1      | frontend-engineer                   | direct             |
| "ajouter une query GraphQL pour les deposits"              | 2      | backend-engineer + reviewer         | impl + review      |
| "checkout multi-wallet MetaMask + WalletConnect + Rainbow" | 2-3    | frontend + backend                  | impl/spec          |
| "nouveau vault ERC-4626"                                   | 3      | smart-contract-engineer + tous      | /spec → /implement |
| "ajouter des fees sur les withdrawals"                     | **3**  | smart-contract-engineer + tous      | /spec → /implement |
| "upgrade le proxy UUPS"                                    | **3**  | smart-contract-engineer + architect | /spec → /implement |
| "mettre à jour le subgraph pour un nouvel event"           | 2      | backend-engineer + reviewer         | impl + review      |
| "corriger l'affichage du solde en wei"                     | 1      | frontend-engineer                   | direct             |
