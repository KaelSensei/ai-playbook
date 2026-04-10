---
name: story
description: >
  Turn a need into user stories with Acceptance Criteria and wireframes. product-owner + ux-designer
  in parallel. Deliverable: stories ready for /spec.
argument-hint: '[business need or feature idea]'
---

# /story

Update `tasks/current_task.md`: status=STORY, task=$ARGUMENTS

---

## Phase 1 — EXPLORE (context before drafting)

Load `team--skill-lookup`.

Invoke `spec-writer` in exploration mode:

```
You are spec-writer.
Load project-architecture.md. Check freshness.
Load team--skill-lookup.

Explore the codebase to understand:
1. Existing features related to: $ARGUMENTS
2. UI patterns / user flows already in place
3. Known technical constraints

Produce: a summary of findings (existing patterns, constraints, open questions)
```

---

## Phase 2 — PARALLEL DRAFT

Spawn `product-owner` and `ux-designer` at the same time.

**product-owner prompt:**

```
You are product-owner.
Load project-architecture.md.
Load team--skill-review.

From this need: $ARGUMENTS
And these exploration findings: [findings]

Produce:
1. The user stories (format: As a [persona], I want [action] so that [benefit])
2. Acceptance Criteria in Given/When/Then for each story
3. Explicit rejection criteria
4. What is OUT OF SCOPE for this iteration

Max 3 stories. If more, prioritize and defer the rest.
```

**ux-designer prompt:**

```
You are ux-designer.
Load project-architecture.md.
Load team--skill-review.

From this need: $ARGUMENTS
And these exploration findings: [findings]

Produce:
1. The user journey (happy path + error paths)
2. Textual wireframes for the key screens
3. The UI states to cover: loading, error, empty, success
4. Identified friction points

```

---

## Phase 3 — CROSS REVIEW

Each agent reviews the other's deliverable:

- `product-owner` reviews the wireframes: _"Do these wireframes match the ACs?"_
- `ux-designer` reviews the ACs: _"Do these ACs cover all the defined UI states?"_

Apply `team--skill-refine` on disagreement.

---

## Phase 4 — PRESENT

Once there is unanimous agreement, present to the user:

```markdown
# Stories: $ARGUMENTS

## Story 1: [title]

**As a** [persona], **I want** [action] **so that** [benefit]

### Acceptance Criteria

- [ ] Given [...], When [...], Then [...] ...

### Rejection criteria

- [ ] [explicit failure case]

### Wireframe

[textual wireframe]

### UI states

- Loading: [description]
- Error: [description]
- Success: [description]

## Out of Scope

- [deferred items]
```

**Gate**: _"Are these stories correct? Any adjustments before /spec?"_

Save to `.claude/specs/[slug]-story.md`. Update `tasks/current_task.md`: status=IDLE

```
✅ Stories validated
Ready for: /spec [slug]-story
```
