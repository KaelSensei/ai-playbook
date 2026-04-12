# Plan Command — Technical Implementation Plan

When `/plan [spec or description]` is invoked, create a technical implementation plan from a
specification or feature description. This is the second step of the **spec → plan → implement**
pipeline.

**Skills used:** `step-file-architecture` (workflow structure), `security-review` (security
planning), `code-audit` (architecture alignment).

**Input:** A `SPEC.md` file (from `/spec`) or an inline feature description. **Output:** A `PLAN.md`
file in the project root (or alongside the spec).

---

## Workflow Overview

| Step | File                           | Description                                      |
| ---- | ------------------------------ | ------------------------------------------------ |
| 1    | `plan-steps/step-01-input.md`  | Load spec/description and project architecture   |
| 2    | `plan-steps/step-02-design.md` | Technical design: approach, layers, dependencies |
| 3    | `plan-steps/step-03-tasks.md`  | Break down into ordered, implementable tasks     |
| 4    | `plan-steps/step-04-review.md` | Constitution check, risk assessment, finalize    |

## Execution Rules

1. **Load ONE step file at a time.** Read the step file completely before acting.
2. **Execute the step fully** before moving to the next.
3. **Track progress** in the PLAN.md frontmatter (`stepsCompleted` array).
4. **If interrupted:** On resume, read PLAN.md frontmatter to determine last completed step.
5. **Do NOT skip steps.**
6. **Constitution check** runs in Step 4 — violations are blockers.

## When to Use /plan

- After `/spec` to turn a specification into an actionable plan.
- Before `/feature` for Full Flow features that need architecture decisions.
- When the implementation approach is unclear and needs structured thinking.
- With an inline description (without a prior `/spec`) for medium-complexity features.

## When NOT to Use /plan

- For Quick Flow features — `/feature` handles these directly.
- For bug fixes — use `/fix` directly.
- For refactors — use `/refactor` directly.

---

## Quick Start

```
/plan                              # Plan from existing SPEC.md
/plan add webhook support          # Plan from inline description
```

This will create a `PLAN.md` with technical design, task breakdown, and risk assessment that feeds
into `/feature`.

---

## Usage

- `/plan` — Create plan from existing SPEC.md in the project
- `/plan add webhook support` — Create plan from inline description
- `/plan specs/auth/SPEC.md` — Create plan from a specific spec file
