# web3-agents v3 — Multi-Agent Setup

Multi-agent setup for Web3 development. Specialized agents that work in parallel and review each
other.

> **Tool-agnostic**: works with Claude Code, Cursor, or any AI tool that reads `.claude/` or
> `.cursor/` config directories.

---

## What it is

Au lieu d'un seul agent qui fait tout, tu as une équipe :

- `smart-contract-engineer` — sécurité Solidity, reentrancy, flash loans, DeFi
- `infra-engineer` — K8s, Docker, health checks, monitoring
- `devops-engineer` — CI/CD, forge scripts, migrations, Safe multisig
- `frontend-engineer` — wagmi v2, viem, tx state machine, WebSocket cleanup
- `backend-engineer` — subgraphs, indexers, keeper bots, reorg handling
- `architect` — design système, blast radius, upgrade paths
- `spec-writer` — specs techniques EIP-style avant tout code
- `rust-reviewer` — Solana/Anchor, Arbitrum Stylus, Rust correctness

Chaque agent a sa checklist, son domaine, son style de verdict. Ils tournent en parallèle. Ils se
review mutuellement. Rien ne passe sans accord unanime.

---

## Installation

```bash
cd ~/your-web3-project

# For Claude Code (default — installs into .claude/)
bash /path/to/web3-agents-v3/install.sh

# For Cursor (installs into .cursor/)
bash /path/to/web3-agents-v3/install.sh .cursor
```

The installer creates this structure in your project:

```
your-project/
├── CLAUDE.md                        ← lists your active agents
├── tasks/
│   └── current_task.md              ← current state (managed automatically)
└── <target>/                        ← .claude/ or .cursor/ etc.
    ├── project-architecture.md      ← fill in (your system)
    ├── data-architecture.md         ← fill in (your data)
    ├── constants.md                 ← fill in (your addresses)
    ├── agents/                      ← 8 agent personas
    ├── skills/                      ← shared knowledge
    │   ├── solidity-patterns/
    │   ├── foundry-testing/
    │   ├── defi-protocols/
    │   ├── web3-frontend/
    │   ├── team--skill-review/
    │   ├── team--skill-refine/
    │   └── team--skill-lookup/
    └── commands/                    ← 4 workflows
        ├── research.md
        ├── spec.md
        ├── implement.md
        └── review.md
```

---

## Étape obligatoire : remplir les 3 docs fondation

Ces 3 fichiers sont la mémoire partagée de tous tes agents. **Sans eux les agents bossent à
l'aveugle.** Tu les remplis une seule fois (~1h), puis tu les mets à jour au fil du projet.

### `.claude/project-architecture.md` (~30 min)

Décris ton système. Exemple minimal :

```markdown
# Project Architecture

<!-- last-verified: 2026-03-23 -->

## System Overview

Un vault ERC-4626 sur Base qui accepte de l'USDC et le déploie dans Aave pour générer du yield.

## Trust Model

- Owner : multisig 3/5 — peut upgrade et pause
- Users : non trusted — tous les inputs validés on-chain

## Key Invariants

- Sum des balances == totalAssets
- Share price ne décroît jamais
```

Ce fichier doit contenir :

- Ce que fait le protocole
- Qui peut faire quoi (trust model)
- Ce qui doit toujours être vrai (invariants)
- Les dépendances externes (oracles, protocoles)
- Les adresses de déploiement

### `.claude/data-architecture.md` (~20 min)

Tes events Solidity, ton storage layout, ton schema GraphQL/Ponder si t'en as un, le flow de données
de la chain vers le frontend.

### `.claude/constants.md` (~10 min)

Tes adresses de contrats par chain, tes chain IDs, tes variables d'environnement, tes versions de
toolchain.

> **Règle de fraîcheur** : chaque doc a une ligne `last-verified: YYYY-MM-DD`. Les agents vérifient
> cette date. Si > 30 jours → ils explorent le codebase plutôt que de faire confiance au doc.

---

## Utilisation

Lance Claude Code dans ton projet :

```bash
cd ton-projet-web3
claude
```

Puis tape une des 4 commandes.

---

### `/research <sujet>`

Avant de coder quoi que ce soit d'inconnu.

```
/research comment implémenter un fee switch sur un vault ERC-4626
```

**Ce qui se passe :** 2 agents tournent en parallèle avec accès web. Chacun creuse son angle
(sécurité, architecture). Les findings sont mergés.

---

### `/spec <feature>`

Avant d'écrire la moindre ligne de code.

```
/spec ajouter un système de fees sur les withdrawals
```

**Ce qui se passe automatiquement :**

```
1. spec-writer explore le codebase
2. spec-writer produit un draft
3. Tu valides le draft
4. Tous les agents reviewent en parallèle :
     smart-contract-engineer → sécurité
     devops-engineer         → déploiement
     architect               → design
     frontend-engineer       → impact frontend
     backend-engineer        → impact indexer
     ...
5. Chacun retourne APPROVE / APPROVE_WITH_CHANGES / REQUEST_REDESIGN
6. Si pas unanime → itération, re-review, jusqu'à accord
7. Spec sauvegardée dans .claude/specs/
```

Tu ne lances rien manuellement. Claude orchestre tout.

---

### `/implement <spec>`

Après avoir un spec approuvé.

```
/implement fee-switch
```

**Ce qui se passe automatiquement :**

```
1. Plan établi depuis le spec (étapes ordonnées)
2. Pour chaque étape :
   a. L'agent propriétaire écrit le code (TDD)
   b. Tous les agents reviewent en parallèle
   c. Si findings → l'agent propriétaire corrige → re-review
   d. Si unanime APPROVE → commit → étape suivante
3. forge test + forge snapshot + slither
4. Review finale sur le diff complet
```

---

### `/review`

Sur n'importe quel diff avant de merger ou déployer.

```
/review
```

**Ce qui se passe :** tous les agents reviewent en parallèle. Verdict mergé avec 🔴 Blockers / 🟡
Improvements / 🔵 Nits.

Tu peux aussi préciser :

```
/review 42          ← PR numéro 42
/review src/Vault.sol
/review staged      ← ce qui est en git staging
```

---

## Comment les agents se parlent

Tu ne gères pas ça. Claude Code s'en occupe.

```
Tu tapes /spec ou /implement
    ↓
Claude lit CLAUDE.md → connaît la liste des agents actifs
    ↓
Claude spawn les agents en parallèle (Task tool natif de Claude Code)
    ↓
Chaque agent lit son fichier .md → sait qui il est et quoi vérifier
    ↓
Chaque agent lit les 3 foundation docs → connaît ton projet
    ↓
Ils retournent leurs verdicts à l'orchestrateur
    ↓
L'orchestrateur merge, itère si besoin, présente le résultat
```

---

## Personnaliser les agents actifs

Dans `CLAUDE.md`, la section `## Agent Team` liste les agents actifs. Retire les lignes des agents
non pertinents pour ce projet.

Exemple pour un projet contracts-only sans frontend :

```markdown
## Agent Team

| AGENT                   | PERSONA                    | CONTEXT DOCS                                                | SKILLS                                                                 |
| ----------------------- | -------------------------- | ----------------------------------------------------------- | ---------------------------------------------------------------------- |
| smart-contract-engineer | smart-contract-engineer.md | project-architecture.md, data-architecture.md               | solidity-patterns, foundry-testing, defi-protocols, team--skill-review |
| devops-engineer         | devops-engineer.md         | project-architecture.md, constants.md                       | foundry-testing, team--skill-review                                    |
| architect               | architect.md               | project-architecture.md, data-architecture.md, constants.md | solidity-patterns, defi-protocols, team--skill-review                  |
| spec-writer             | spec-writer.md             | project-architecture.md, data-architecture.md               | solidity-patterns, team--skill-lookup                                  |
```

---

## Permissions Claude Code (optionnel)

Pour éviter les confirmations à chaque commande `forge` ou `git`, crée `.claude/settings.json` :

```json
{
  "permissions": {
    "allow": [
      "Bash(forge:*)",
      "Bash(cast:*)",
      "Bash(git add:*)",
      "Bash(git commit:*)",
      "Bash(git diff:*)",
      "Bash(git status:*)",
      "Bash(slither:*)",
      "Bash(npm:*)",
      "Bash(npx:*)"
    ]
  }
}
```

---

## Résolution des skills (priorité)

Un projet peut surcharger n'importe quel skill global en plaçant un `SKILL.md` du même nom dans
`.claude/skills/` local.

| Priorité    | Chemin                     | Scope                |
| ----------- | -------------------------- | -------------------- |
| 1 — HIGHEST | `<projet>/.claude/skills/` | Ce projet uniquement |
| 2 — MEDIUM  | `.claude/skills/`          | Workspace            |
| 3 — LOWEST  | `~/.claude/skills/`        | Global               |

---

## Getting Started Checklist

```
[ ] bash install.sh [target-dir] in your project
[ ] Fill in <target>/project-architecture.md
[ ] Fill in <target>/data-architecture.md
[ ] Fill in <target>/constants.md
[ ] Edit CLAUDE.md → Stack section + remove unused agents
[ ] Create <target>/settings.json with Bash permissions (optional)
[ ] Start your AI tool
[ ] Run: /research <first topic>
```
