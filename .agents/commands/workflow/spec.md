# Spec Command — Feature Specification Workflow

When `/spec <feature description>` is invoked, transform the description into a structured
specification document. This is the first step of the **spec → plan → implement** pipeline.

**Skills used:** `step-file-architecture` (workflow structure), `git-branch-naming` (branch
creation), `security-review` (security implications).

**Output:** A `SPEC.md` file in the project root (or `specs/<name>/SPEC.md` for larger projects).

---

## Workflow Overview

| Step | File                             | Description                                       |
| ---- | -------------------------------- | ------------------------------------------------- |
| 1    | `spec-steps/step-01-context.md`  | Load project context and create branch            |
| 2    | `spec-steps/step-02-scope.md`    | Define scope, user stories, and boundaries        |
| 3    | `spec-steps/step-03-criteria.md` | Write acceptance criteria and edge cases          |
| 4    | `spec-steps/step-04-validate.md` | Constitution check, clarify ambiguities, finalize |

## Execution Rules

1. **Load ONE step file at a time.** Read the step file completely before acting.
2. **Execute the step fully** before moving to the next.
3. **Track progress** in the SPEC.md frontmatter (`stepsCompleted` array).
4. **If interrupted:** On resume, read SPEC.md frontmatter to determine last completed step.
5. **Do NOT skip steps** unless the step file explicitly allows it.
6. **Constitution check** runs in Step 4 — violations are blockers.

## When to Use /spec

- Before `/feature` for medium+ features (Full Flow).
- When requirements are unclear and need structured thinking.
- When multiple stakeholders need to agree on scope.
- When the feature touches multiple layers or requires architecture decisions.

## When NOT to Use /spec

- For Quick Flow features (1-3 files, single layer, clear requirements).
- For bug fixes — use `/fix` directly.
- For refactors — use `/refactor` directly.

---

## Quick Start

```
/spec add user authentication with OAuth2
```

This will create a `SPEC.md` with structured requirements, acceptance criteria, and scope boundaries
that feeds into `/plan` and then `/feature`.

---

## Usage

- `/spec add user authentication` — Specify a new feature
- `/spec redesign the dashboard layout` — Specify a UI overhaul
- `/spec add webhook support for external integrations` — Specify an integration feature
