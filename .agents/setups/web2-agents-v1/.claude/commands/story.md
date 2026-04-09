---
name: story
description: >
  Transformer un besoin en user stories avec Acceptance Criteria et wireframes. product-owner +
  ux-designer en parallèle. Livrable : stories prêtes pour /spec.
argument-hint: '[besoin métier ou idée de feature]'
---

# /story

Update `tasks/current_task.md` : status=STORY, task=$ARGUMENTS

---

## Phase 1 — EXPLORE (contexte avant de drafter)

Charger `team--skill-lookup`.

Invoquer `spec-writer` en mode exploration :

```
Tu es spec-writer.
Charge project-architecture.md. Vérifie la fraîcheur.
Charge team--skill-lookup.

Explore le codebase pour comprendre :
1. Les features existantes liées à : $ARGUMENTS
2. Les patterns UI / flux utilisateur déjà en place
3. Les contraintes techniques connues

Produis : un résumé des findings (patterns existants, contraintes, questions ouvertes)
```

---

## Phase 2 — DRAFT PARALLÈLE

Spawner `product-owner` et `ux-designer` simultanément.

**product-owner prompt :**

```
Tu es product-owner.
Charge project-architecture.md.
Charge team--skill-review.

À partir de ce besoin : $ARGUMENTS
Et de ces findings d'exploration : [findings]

Produis :
1. Les user stories (format : En tant que [persona], je veux [action] afin de [bénéfice])
2. Les Acceptance Criteria en Given/When/Then pour chaque story
3. Les critères de rejet explicites
4. Ce qui est OUT OF SCOPE pour cette itération

Max 3 stories. Si plus, prioriser et reporter le reste.
```

**ux-designer prompt :**

```
Tu es ux-designer.
Charge project-architecture.md.
Charge team--skill-review.

À partir de ce besoin : $ARGUMENTS
Et de ces findings d'exploration : [findings]

Produis :
1. Le parcours utilisateur (happy path + chemins d'erreur)
2. Les wireframes textuels des écrans clés
3. Les états UI à couvrir : chargement, erreur, vide, succès
4. Les points de friction identifiés

```

---

## Phase 3 — REVIEW CROISÉE

Chaque agent review le livrable de l'autre :

- `product-owner` review les wireframes : _"Ces wireframes correspondent-ils aux ACs ?"_
- `ux-designer` review les ACs : _"Ces ACs couvrent-ils tous les états UI définis ?"_

Appliquer `team--skill-refine` si désaccord.

---

## Phase 4 — PRÉSENTER

Quand accord unanime, présenter à l'utilisateur :

```markdown
# Stories : $ARGUMENTS

## Story 1 : [titre]

**En tant que** [persona], **je veux** [action] **afin de** [bénéfice]

### Acceptance Criteria

- [ ] Given [...], When [...], Then [...] ...

### Critères de rejet

- [ ] [cas d'échec explicite]

### Wireframe

[wireframe textuel]

### États UI

- Chargement : [description]
- Erreur : [description]
- Succès : [description]

## Out of Scope

- [items reportés]
```

**Gate** : _"Ces stories sont-elles correctes ? Des ajustements avant /spec ?"_

Sauvegarder dans `.claude/specs/[slug]-story.md` Update `tasks/current_task.md` : status=IDLE

```
✅ Stories validées
Prêt pour : /spec [slug]-story
```
