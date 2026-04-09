# legacy-agents v1 — Multi-Agent Setup

Multi-agent setup for working on legacy projects. Mapping, characterization tests, safe refactoring,
Strangler Fig.

> **Tool-agnostic**: works with Claude Code, Cursor, or any AI tool that reads `.claude/` or
> `.cursor/` config directories.

---

## Le Problème du Legacy

Sur un projet legacy, les règles du développement classique ne s'appliquent pas. On ne peut pas
faire du TDD sur du code sans seams. On ne peut pas refactorer sans filet de tests. On ne peut pas
tout réécrire en une fois.

Ce setup implémente la méthode de Michael Feathers (_Working Effectively with Legacy Code_) avec une
équipe d'agents spécialisés.

---

## Les Agents

| Agent                     | Rôle                                                            |
| ------------------------- | --------------------------------------------------------------- |
| `legacy-analyst`          | Cartographie les modules, identifie les seams et zones à risque |
| `archaeologist`           | Comprend l'histoire du code, retrouve les décisions héritées    |
| `characterization-tester` | Écrit les tests qui figent le comportement existant             |
| `refactoring-guide`       | Guide le refactoring micro-incrémental (catalogue Fowler)       |
| `debt-tracker`            | Inventorie et priorise la dette technique                       |
| `dev-senior-a`            | Implémente (refactoring legacy ou TDD sur nouveau code)         |
| `dev-senior-b`            | Review critique — teste le filet avant le code                  |
| `architect`               | Strangler Fig, Anti-Corruption Layer, frontières                |
| `tech-lead`               | Arbitrage dette vs features, cohérence de migration             |
| `security-reviewer`       | OWASP + vulnérabilités legacy spécifiques                       |
| `data-engineer`           | Migrations legacy-aware, données sales, indexes                 |

---

## Installation

```bash
cd ~/your-legacy-project

# For Claude Code (default — installs into .claude/)
bash /path/to/legacy-agents-v1/install.sh

# For Cursor (installs into .cursor/)
bash /path/to/legacy-agents-v1/install.sh .cursor
```

---

## Les 3 docs à remplir

### `.claude/project-architecture.md` (~30 min)

Ce que fait le système, les modules connus (même partiellement), les zones à risque, **ce qui NE
PEUT PAS changer**.

### `.claude/legacy-map.md` (vivant — commence vide)

Se remplit automatiquement au fur et à mesure des `/understand`. C'est la carte du territoire — elle
grandit à chaque exploration. Ne jamais supprimer une entrée, seulement annoter.

### `.claude/constants.md` (~10 min)

Variables d'env connues, URLs par environnement, versions du toolchain. Sur un legacy, certaines
sont peut-être hardcodées dans le code — documenter où elles se trouvent.

---

## La Règle d'Or

```
JAMAIS toucher du code legacy sans filet de tests.

Ordre obligatoire :
  /understand → /characterize → /refactor ou /strangler

Pas de raccourci. Même pour "un petit changement".
```

---

## Utilisation

```bash
cd ton-projet-legacy
claude
```

---

### `/understand <module>`

Cartographier un module avant tout changement.

```
/understand src/billing/BillingService.php
```

**Ce qui se passe :** `legacy-analyst` + `archaeologist` en parallèle. L'un cartographie les
dépendances et seams, l'autre fouille l'histoire git. Résultat : fiche module dans `legacy-map.md`,
niveau de risque, seams identifiés.

---

### `/characterize <module>`

Écrire des tests qui figent le comportement existant.

```
/characterize src/billing/BillingService.php
```

**Ce qui se passe :**

```
1. Plan de caractérisation établi
2. Pour chaque comportement :
   a. Test écrit avec assertion intentionnellement fausse
   b. Test lancé → valeur réelle notée
   c. Test mis à jour avec la valeur réelle
   d. dev-senior-b review le test
3. Tous les tests passent → filet en place
```

Les tests de caractérisation documentent **ce que le code fait**, pas ce qu'on croit qu'il devrait
faire.

---

### `/refactor <cible>`

Refactoring sécurisé, micro-incrémental.

```
/refactor src/billing/BillingService.php
```

**Prérequis** : `/understand` + `/characterize` faits.

**Ce qui se passe :**

```
1. Plan de refactoring en micro-étapes (catalogue Fowler)
2. Pour chaque étape :
   a. dev-senior-a fait UN changement minimal
   b. Tous les tests (caractérisation incluse) doivent passer
   c. dev-senior-b review
   d. Commit atomique
3. Review finale tous les agents
```

Si un test de caractérisation passe au rouge → `git revert` immédiat.

---

### `/strangler <feature>`

Implémenter une nouvelle feature autour du legacy, sans le modifier.

```
/strangler nouveau système de calcul de factures
```

**Ce qui se passe :**

```
1. architect définit la frontière et l'Anti-Corruption Layer
2. spec-writer produit la spec + test list du NOUVEAU code
3. dev-senior-a implémente en TDD strict (le legacy n'est jamais modifié)
4. Feature flag pour activation progressive
5. Review finale tous les agents
```

Le legacy reste en place jusqu'à ce que le nouveau code soit à 100%.

---

### `/debt`

Auditer et prioriser la dette technique.

```
/debt                          ← audit global
/debt src/billing/             ← audit d'un module
```

**Ce qui se passe :** `debt-tracker` + `legacy-analyst` analysent, produisent un inventaire priorisé
par Impact/Effort avec un plan de remboursement.

---

### `/review`

Review parallèle par tous les agents sur n'importe quel diff.

```
/review
/review 42           ← PR numéro 42
/review staged
```

**Spécial legacy** : vérifie que les tests de caractérisation passent et que le comportement est
préservé si c'est un refactoring.

---

## Deux Modes de Développement

### Sur du code legacy existant

```
1. /understand → cartographier
2. /characterize → figer le comportement
3. /refactor → restructurer sans changer le comportement
   (chaque étape doit laisser les tests verts)
```

### Sur du nouveau code (Strangler Fig)

```
TDD strict — Canon TDD (Kent Beck) :
RED   → UN test qui échoue
GREEN → minimum de code pour passer
BLUE  → refactorer sans casser
```

`dev-senior-b` review le test AVANT le code dans les deux cas.

---

## Personnaliser l'équipe

Dans `CLAUDE.md`, section `## Agent Team` : retirer les lignes des agents non pertinents.

Exemple minimal (pas de frontend, pas de BDD complexe) :

```markdown
| AGENT                   | PERSONA                    | CONTEXT DOCS                                         | SKILLS                                                                      |
| ----------------------- | -------------------------- | ---------------------------------------------------- | --------------------------------------------------------------------------- |
| legacy-analyst          | legacy-analyst.md          | project-architecture.md, legacy-map.md, constants.md | legacy-patterns, technical-debt, team--skill-review                         |
| archaeologist           | archaeologist.md           | project-architecture.md, legacy-map.md               | legacy-patterns, team--skill-lookup                                         |
| characterization-tester | characterization-tester.md | project-architecture.md, legacy-map.md               | testing-patterns, legacy-patterns, team--skill-review                       |
| refactoring-guide       | refactoring-guide.md       | project-architecture.md, legacy-map.md               | refactoring-patterns, legacy-patterns, testing-patterns, team--skill-review |
| dev-senior-a            | dev-senior-a.md            | project-architecture.md, legacy-map.md, constants.md | clean-code, testing-patterns, refactoring-patterns, team--skill-review      |
| dev-senior-b            | dev-senior-b.md            | project-architecture.md, legacy-map.md, constants.md | clean-code, testing-patterns, refactoring-patterns, team--skill-review      |
| tech-lead               | tech-lead.md               | project-architecture.md, legacy-map.md, constants.md | clean-code, technical-debt, team--skill-review                              |
| security-reviewer       | security-reviewer.md       | project-architecture.md, constants.md                | security-web2, team--skill-review                                           |
```

---

## Getting Started Checklist

```
[ ] bash install.sh [target-dir] in your project
[ ] Edit CLAUDE.md → Stack (language, framework, age)
[ ] Fill in <target>/project-architecture.md
[ ] Fill in <target>/constants.md
[ ] Start your AI tool
[ ] Run: /debt   (global overview)
[ ] Then: /understand <riskiest module>
```
