# web2-agents v1 — Multi-Agent Setup

Multi-agent setup for web2 development. 11 specialized agents, mandatory TDD, parallel reviews.

> **Tool-agnostic**: works with Claude Code, Cursor, or any AI tool that reads `.claude/` or
> `.cursor/` config directories.

---

## What it is

A simulated engineering team that follows a structured workflow from business need to deployable
code.

| Agent               | Rôle                                           |
| ------------------- | ---------------------------------------------- |
| `product-owner`     | User stories, ACs, scope, dire non             |
| `ux-designer`       | Parcours utilisateur, wireframes, états UI     |
| `tech-lead`         | Standards d'équipe, cohérence, arbitrage       |
| `architect`         | Découpage modules, API contracts, blast radius |
| `spec-writer`       | Spec technique + test list exhaustive          |
| `dev-senior-a`      | Implémentation TDD (RED → GREEN → BLUE)        |
| `dev-senior-b`      | Review critique — test d'abord, code ensuite   |
| `qa-engineer`       | Couverture comportementale, edge cases         |
| `security-reviewer` | OWASP, auth, injections, secrets               |
| `data-engineer`     | Schema BDD, migrations, N+1, indexes           |
| `devops-engineer`   | CI/CD, Docker, déploiement, rollback           |

---

## Installation

```bash
cd ~/your-web2-project

# For Claude Code (default — installs into .claude/)
bash /path/to/web2-agents-v1/install.sh

# For Cursor (installs into .cursor/)
bash /path/to/web2-agents-v1/install.sh .cursor
```

---

## Étape obligatoire : remplir les 3 docs fondation

Ces 3 fichiers sont la mémoire partagée de tous les agents. **Sans eux les agents bossent à
l'aveugle.** Une fois remplis (~1h), tu les mets à jour au fil du projet.

### `.claude/project-architecture.md` (~30 min)

Vue d'ensemble du système, modules, authentification, invariants clés, dépendances externes.

### `.claude/data-architecture.md` (~20 min)

Schéma BDD, relations, indexes, stratégie de migration, soft delete, données sensibles, caching.

### `.claude/constants.md` (~10 min)

Variables d'environnement, URLs par env, versions du toolchain, rate limits, feature flags.

> **Règle de fraîcheur** : chaque doc a une ligne `last-verified: YYYY-MM-DD`. Les agents vérifient
> cette date. Si > 30 jours → ils explorent le codebase plutôt que de faire confiance au doc.

---

## Utilisation

```bash
cd ton-projet-web2
claude
```

---

### `/story <besoin>`

Transformer un besoin en user stories avec ACs et wireframes.

```
/story permettre aux utilisateurs de réinitialiser leur mot de passe
```

**Ce qui se passe :** `product-owner` et `ux-designer` travaillent en parallèle. L'un produit les
ACs, l'autre les wireframes. Ils se cross-reviewent. Résultat : stories validées prêtes pour
`/spec`.

---

### `/spec <story>`

Produire une spec technique avec test list exhaustive. **La test list est le livrable principal —
elle drive tout le `/build`.**

```
/spec reset-password
```

**Ce qui se passe :**

```
1. spec-writer explore le codebase
2. spec-writer drafts la spec + test list ordonnée
3. Tu valides le draft
4. Tous les agents reviewent en parallèle
5. Boucle jusqu'à APPROVE unanime
6. Spec sauvegardée dans .claude/specs/
```

---

### `/build <spec>`

Implémenter en TDD strict. Un test à la fois.

```
/build reset-password
```

**Ce qui se passe (pour chaque item de la test list) :**

```
1. dev-senior-a écrit UN test → RED (doit échouer)
2. dev-senior-b review le TEST en premier
3. dev-senior-a écrit le minimum de code → GREEN (doit passer)
4. Tous les agents reviewent en parallèle
5. dev-senior-a refactore → BLUE (tests toujours verts)
6. Commit → item suivant
```

> TDD canon (Kent Beck) : aucun code de prod sans test qui échoue d'abord. dev-senior-b review le
> test avant le code — toujours.

---

### `/review`

Review parallèle par tous les agents sur n'importe quel diff.

```
/review              ← dernier commit
/review 42           ← PR numéro 42
/review src/auth/    ← fichiers spécifiques
/review staged       ← staging area
```

---

### `/check`

Review ciblée qualité avant déploiement. `qa-engineer` + `security-reviewer` + `data-engineer` en
parallèle.

```
/check
```

Les 3 verdicts doivent être `APPROVE` avant tout déploiement prod.

---

## Comment les agents s'orchestrent

Tu ne gères rien manuellement. Claude Code s'en occupe.

```
Tu tapes /story, /spec, /build, /review ou /check
    ↓
Claude lit CLAUDE.md → connaît la liste des agents actifs
    ↓
Claude spawne les agents en parallèle (Task tool natif)
    ↓
Chaque agent charge son fichier .md → sait qui il est et quoi checker
    ↓
Chaque agent charge les foundation docs → connaît ton projet
    ↓
Chaque agent retourne son verdict structuré
    ↓
Claude merge, itère si nécessaire, présente le résultat
```

---

## TDD — Règle absolue

```
RED   → écrire UN test qui échoue pour la bonne raison
GREEN → minimum de code pour le faire passer
BLUE  → refactorer sans casser les tests
```

**dev-senior-b review le test AVANT le code.** Si le test est mauvais, le code qui suit l'est aussi.

Le cycle complet prend 2-5 minutes par item de test list. C'est normal. C'est le prix d'un code
qu'on maîtrise.

---

## Personnaliser les agents actifs

Dans `CLAUDE.md`, section `## Agent Team` : retire les lignes des agents non pertinents pour ce
projet.

Exemple minimal (backend only, pas de frontend) :

```markdown
| AGENT             | PERSONA              | CONTEXT DOCS                                                | SKILLS                                                        |
| ----------------- | -------------------- | ----------------------------------------------------------- | ------------------------------------------------------------- |
| tech-lead         | tech-lead.md         | project-architecture.md, data-architecture.md, constants.md | clean-code, testing-patterns, team--skill-review              |
| architect         | architect.md         | project-architecture.md, data-architecture.md, constants.md | clean-code, api-design, database-patterns, team--skill-review |
| spec-writer       | spec-writer.md       | project-architecture.md, data-architecture.md               | clean-code, testing-patterns, team--skill-lookup              |
| dev-senior-a      | dev-senior-a.md      | project-architecture.md, data-architecture.md, constants.md | clean-code, testing-patterns, api-design, team--skill-review  |
| dev-senior-b      | dev-senior-b.md      | project-architecture.md, data-architecture.md, constants.md | clean-code, testing-patterns, api-design, team--skill-review  |
| qa-engineer       | qa-engineer.md       | project-architecture.md, data-architecture.md               | testing-patterns, team--skill-review                          |
| security-reviewer | security-reviewer.md | project-architecture.md, constants.md                       | security-web2, team--skill-review                             |
| data-engineer     | data-engineer.md     | project-architecture.md, data-architecture.md               | database-patterns, team--skill-review                         |
| devops-engineer   | devops-engineer.md   | project-architecture.md, constants.md                       | team--skill-review                                            |
```

---

## Getting Started Checklist

```
[ ] bash install.sh [target-dir] in your project
[ ] Fill in <target>/project-architecture.md
[ ] Fill in <target>/data-architecture.md
[ ] Fill in <target>/constants.md
[ ] Edit CLAUDE.md → Stack + remove unused agents
[ ] Start your AI tool
[ ] Run: /story <first need>
```
