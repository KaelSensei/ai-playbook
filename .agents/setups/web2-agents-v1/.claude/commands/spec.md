---
name: spec
description: >
  Produire une spec technique avec test list exhaustive à partir des stories. La test list est le
  livrable central — elle drive tout le /build TDD. EXPLORE → DRAFT → review parallèle → boucle →
  spec approuvée.
argument-hint: '[slug de la story ou description]'
---

# /spec

Update `tasks/current_task.md` : status=SPEC, task=$ARGUMENTS

---

## Phase 1 — EXPLORE

Charger `team--skill-lookup`.

Invoquer `spec-writer` en mode exploration :

```
Tu es spec-writer.
Charge project-architecture.md, data-architecture.md.
Charge team--skill-lookup.

Vérifie la fraîcheur des docs.

Explore le codebase pour :
1. Les patterns existants liés à : $ARGUMENTS
2. Les interfaces et modules que cette feature va toucher
3. Les migrations BDD existantes et le schéma actuel
4. Les tests existants pour comprendre les conventions

Produis : exploration-findings avec statut des docs, findings codebase,
divergences éventuelles, questions ouvertes.
```

Si questions ouvertes → demander à l'utilisateur avant de drafter.

---

## Phase 2 — DRAFT

Invoquer `spec-writer` avec les findings :

```
Tu es spec-writer.
Charge project-architecture.md, data-architecture.md.
Charge clean-code, testing-patterns.

Findings d'exploration : [findings]
Stories et ACs : [contenu de .claude/specs/$ARGUMENTS-story.md si existe]

Produis une spec technique complète pour : $ARGUMENTS

Sections obligatoires :
- Summary
- Acceptance Criteria (repris des stories si /story a été fait)
- Test List (ordonnée simplest first — C'EST LE LIVRABLE PRINCIPAL)
  → Happy Path, Edge Cases, Error Cases, Integration
- Interface Technique (signatures uniquement)
- Contraintes (perf, sécu, data)
- Out of Scope

Règle : si la test list est vide → la spec est incomplète.
Utiliser RFC 2119 (MUST, MUST NOT, MAY).
```

Présenter le draft à l'utilisateur. **Gate** : _"La test list est-elle complète ? Des ACs manquants
?"_ Ne pas continuer sans confirmation.

---

## Phase 3 — REVIEW PARALLÈLE

Charger `team--skill-review` pour tous les agents.

Spawner TOUS les agents du tableau `## Agent Team` dans `CLAUDE.md` simultanément — sauf
`spec-writer` :

```
Tu es [AGENT_PERSONA].
Charge .claude/agents/[agent].md.
Charge les context docs : [selon Agent Team table].
Charge les skills : [selon Agent Team table].
Charge team--skill-review.

Mode review uniquement — pas d'écriture de code.

Review cette spec technique de ton angle disciplinaire.
Tous les agents reviewent en parallèle.

[contenu complet de la spec]

Focus particulier sur la TEST LIST :
- Tous les ACs sont-ils couverts par au moins un test ?
- Les edge cases de ta discipline sont-ils dans la test list ?
- Y a-t-il des comportements manquants ?

Suivre le format team--skill-review exactement.
```

---

## Phase 4 — SYNTHÈSE

```
Boucle [N] :
  spec-writer        : [verdict]
  architect          : [verdict]
  tech-lead          : [verdict]
  dev-senior-a       : [verdict]
  dev-senior-b       : [verdict]
  qa-engineer        : [verdict]
  security-reviewer  : [verdict]
  data-engineer      : [verdict]
  devops-engineer    : [verdict]

Verdict global : [merged]
```

---

## Phase 5 — ITÉRER si pas unanime

Charger `team--skill-refine`. `REQUEST_REDESIGN` → arrêt, escalade utilisateur.
`APPROVE_WITH_CHANGES` → `spec-writer` corrige, re-review, max 3 boucles.

---

## Phase 6 — SAUVEGARDER

Sauvegarder dans `.claude/specs/[slug].md` Update `tasks/current_task.md` :

- status=IDLE
- Active Spec: .claude/specs/[slug].md

```
✅ Spec approuvée unanimement
  Agents : [liste]
  Boucles : [N]
  Sauvegardée : .claude/specs/[slug].md
  Test List : [N items]

Prêt pour : /build [slug]
```
