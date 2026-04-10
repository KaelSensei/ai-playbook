---
name: strangler
description: >
  Introduce new code around the legacy (Strangler Fig). architect defines the boundary and the ACL,
  dev-senior-a implements with TDD, all agents review. The legacy is never modified.
argument-hint: '[feature to wrap]'
---

# /strangler

Update `tasks/current_task.md`: status=STRANGLER, module=$ARGUMENTS

---

## Prerequisites

```
[ ] /understand on the legacy module involved → card in legacy-map.md
[ ] Characterization tests on the reference legacy behavior
    (to detect if the legacy unexpectedly changes)
```

---

## Phase 1 — Boundary design (architect)

```
You are architect.
Load .claude/agents/architect.md.
Load project-architecture.md, legacy-map.md, constants.md.
Load strangler-fig, clean-code skills.

Feature to implement: $ARGUMENTS
Legacy module involved: [from legacy-map.md]

Produce a Strangler Fig design note:
- Boundary between legacy and new code
- Anti-Corruption Layer (translation interface)
- 3-phase migration plan (coexistence → redirection → deletion)
- Feature flag needed? how?
- What we DO NOT touch in the legacy
- TDD entry points for the new code
```

Present to the user. **Gate**: _"Is the boundary correct?"_

---

## Phase 2 — Spec for the new code (spec-writer)

```
You are spec-writer.
Load .claude/agents/spec-writer.md.
Load project-architecture.md, data-architecture.md.
Load clean-code, testing-patterns, team--skill-lookup skills.

Feature: $ARGUMENTS
Design note: [architect output]

Produce a technical spec with a test list for the NEW CODE only.
The legacy is not specified here — only the new behavior.
```

Parallel review by all agents (except legacy-analyst and archaeologist). Loop until unanimous
APPROVE.

---

## Phase 3 — Implement the Anti-Corruption Layer (dev-senior-a, TDD)

```
You are dev-senior-a. NEW CODE mode — strict TDD.
Load .claude/agents/dev-senior-a.md.

Implement the ACL in TDD:
1. Write a test for the legacy → new format translation
2. RED → GREEN → BLUE
3. Write a test for the new → legacy format translation
4. RED → GREEN → BLUE

The ACL must be testable without the legacy (fakes/stubs).
```

dev-senior-b reviews the test first, then the code.

---

## Phase 4 — Implement the new code (strict TDD)

For each item of the spec's test list:

### 4a. RED — dev-senior-a writes a test

```
You are dev-senior-a. NEW CODE mode — strict TDD.
Next test from the spec: [item]
Write ONE test. Run it. Must be RED for the right reason.
```

### 4b. dev-senior-b reviews the test

### 4c. GREEN — minimum code

### 4d. All agents review in parallel

### 4e. BLUE — refactoring

### 4f. Commit

```bash
git commit -m "feat([feature]): [behavior description — new code]"
```

---

## Phase 5 — Coexistence (feature flag)

The new code is ready but not yet in production. Put the feature flag in place:

```javascript
if (featureFlags.isEnabled('new-$ARGUMENTS', context)) {
  return newService.handle(request); // new code
}
return legacyModule.handle(request); // legacy unchanged
```

---

## Phase 6 — Final review

All agents on the full diff:

```
Review the complete Strangler Fig for $ARGUMENTS.
- Is the legacy UNCHANGED?
- Does the ACL translate correctly in both directions?
- Does the feature flag allow an immediate rollback?
- Is the new code testable independently of the legacy?
```

Update `tasks/current_task.md`: status=IDLE

```
Strangler Fig ready: $ARGUMENTS
Legacy: unchanged
New code: TDD, [N] tests passing
Feature flag: in place
Ready for: progressive enablement (1% → 10% → 100%)
```
