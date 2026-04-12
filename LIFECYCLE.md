# Development Lifecycle Guide

This guide shows how all playbook commands connect into a complete development lifecycle. Use it to
understand which command to run when, and how they feed into each other.

---

## The Full Pipeline

```
IDEATION          SPECIFICATION       PLANNING            IMPLEMENTATION        REVIEW & CLOSE
─────────         ──────────────      ────────            ──────────────        ──────────────
/brainstorm  ──→  /spec         ──→   /plan         ──→   /ready-check    ──→   /validate
/prfaq       ──→  /checklist          /ready-check        /checklist            /review-pr
                                                          /feature              /retro
                                                          /fix                  /done
                                                          /refactor
                                                          /pivot (mid-flight)
```

---

## Phase 1: Ideation — "What should we build?"

| Command               | Purpose                                                   | Output                                     | Next step                      |
| --------------------- | --------------------------------------------------------- | ------------------------------------------ | ------------------------------ |
| `/brainstorm [topic]` | Generate and prioritize feature ideas                     | Ranked idea list with implementation plans | `/prfaq` or `/spec`            |
| `/prfaq <idea>`       | Validate if an idea is worth building (Working Backwards) | PRFAQ.md with press release + FAQ          | GO → `/spec`, PARK/DROP → stop |

**When to use which:**

- Start with `/brainstorm` when you have a general area but no specific idea.
- Start with `/prfaq` when you have a specific idea but aren't sure it's worth building.
- Skip both and go straight to `/spec` if requirements are already clear.

**Skills available:** `elicitation` (50 techniques), `party-mode` (multi-agent roundtable)

---

## Phase 2: Specification — "What exactly are we building?"

| Command               | Purpose                                 | Output                                                         | Next step                           |
| --------------------- | --------------------------------------- | -------------------------------------------------------------- | ----------------------------------- |
| `/spec <description>` | Structured feature specification        | SPEC.md (user stories, acceptance criteria, edge cases, scope) | `/plan`                             |
| `/checklist [spec]`   | Pre-implementation validation checklist | CHECKLIST.md ("unit tests for English")                        | Use during and after implementation |

**When to use which:**

- Use `/spec` for any feature that touches 4+ files, crosses layers, or has ambiguous requirements.
- Use `/checklist` after `/spec` to generate testable criteria before coding.
- Skip `/spec` for Quick Flow features (1-3 files, single layer, clear requirements).

**Key behaviors:**

- `[NEEDS CLARIFICATION]` markers stop progress until resolved (never guess).
- Constitution check runs in Step 4 (violations are blockers).
- Step-file architecture: loads one step at a time for token efficiency.

---

## Phase 3: Planning — "How will we build it?"

| Command                  | Purpose                            | Output                                               | Next step           |
| ------------------------ | ---------------------------------- | ---------------------------------------------------- | ------------------- |
| `/plan [spec]`           | Technical implementation plan      | PLAN.md (design, ADRs, phased task breakdown, risks) | `/ready-check`      |
| `/ready-check [feature]` | Verify prerequisites before coding | Readiness report (READY / NOT READY / CAUTIONS)      | `/feature` if ready |

**When to use which:**

- Use `/plan` after `/spec` for Full Flow features.
- Use `/ready-check` before any feature to verify alignment.
- Skip `/plan` for Quick Flow features.

**Key behaviors:**

- Tasks are numbered (T001), prioritized (P1/P2/P3), and marked for parallelism (`[P]`).
- Constitution check runs in Step 4.
- Risk assessment identifies what could go wrong and how to mitigate.

---

## Phase 4: Implementation — "Build it."

| Command                   | Purpose                            | Output                                    | Next step                   |
| ------------------------- | ---------------------------------- | ----------------------------------------- | --------------------------- |
| `/feature <description>`  | Implement a new feature end-to-end | Working code, tests, docs, commit         | `/validate` or `/review-pr` |
| `/fix <issue>`            | Diagnose and fix a bug             | Targeted fix, regression test, commit     | `/validate` or `/review-pr` |
| `/refactor <description>` | Non-functional improvements        | Restructured code (same behavior), commit | `/review-pr`                |
| `/pivot <change>`         | Mid-sprint scope change            | Updated SPEC.md / PLAN.md after approval  | Continue `/feature`         |
| `/beautify <target>`      | UI/UX enhancement                  | Visual improvements, commit               | `/review-pr`                |
| `/clean-code [target]`    | Remove dead code and tech debt     | Cleaner codebase, commit                  | `/review-pr`                |

**Scale-adaptive routing (built into /feature and /fix):**

- **Quick Flow** — Small scope (1-3 files, single layer). Goes straight to implementation.
- **Full Flow / Deep Flow** — Larger scope. References SPEC.md/PLAN.md, runs constitution check.

**Key behaviors:**

- `[NEEDS CLARIFICATION]` markers stop progress (never guess).
- Constitution check before implementation (Full Flow only).
- `/pivot` requires user approval before changing any artifact.

---

## Phase 5: Review & Close — "Is it done?"

| Command                | Purpose                          | Output                                      | Next step                           |
| ---------------------- | -------------------------------- | ------------------------------------------- | ----------------------------------- |
| `/validate [scope]`    | Cross-artifact consistency check | Validation report (5-pass analysis)         | Fix findings, then `/review-pr`     |
| `/checklist [spec]`    | Post-implementation verification | Checked-off validation checklist            | `/review-pr`                        |
| `/review-pr [PR#]`     | Pull request review              | Structured review (standard or adversarial) | Merge or address findings           |
| `/done`                | Technical completion checklist   | Completion report (DONE / NOT DONE)         | Merge via `/merge-branch-into-main` |
| `/retro [branch]`      | Post-feature retrospective       | RETRO.md with learnings and action items    | Next feature                        |
| `/audit-code [target]` | Code quality and security audit  | Severity-tiered findings report             | Fix findings                        |

**Recommended closing sequence:**

```
/validate → /checklist → /review-pr → /done → /merge-branch-into-main → /retro
```

---

## Supporting Commands

These commands support the lifecycle but don't belong to a specific phase:

| Command                      | Purpose                                               |
| ---------------------------- | ----------------------------------------------------- |
| `/start`                     | Bootstrap project context, load rules, pick next task |
| `/continue`                  | Resume work, reload context                           |
| `/create-branch`             | Create a properly named branch                        |
| `/git` or `/add-commit-push` | Stage, commit, push                                   |
| `/create-pr <target>`        | Open a pull request                                   |
| `/release [version]`         | Generate release notes and GitHub release             |
| `/devops <task>`             | CI/CD and infrastructure                              |
| `/magic-wand [issue]`        | Deep debugging when all else fails                    |
| `/export-context [path]`     | Compress context for handoff to another agent         |
| `/create-command <name>`     | Create a new playbook command                         |

---

## Choosing the Right Depth

Not every feature needs the full pipeline. Use this decision tree:

```
Is the change trivial? (typo, config, 1-file fix)
  YES → /fix or /feature directly (Quick Flow)
  NO  ↓

Is the scope clear? (you know exactly what to build)
  YES → /feature directly (Full Flow with inline planning)
  NO  ↓

Is the idea validated? (you know it's worth building)
  YES → /spec → /plan → /feature
  NO  ↓

Do you know what the user needs?
  YES → /prfaq → /spec → /plan → /feature
  NO  → /brainstorm → /prfaq → /spec → /plan → /feature
```

---

## Skills Reference

Skills are loaded automatically when needed. Key skills by phase:

| Phase          | Skills                                                         |
| -------------- | -------------------------------------------------------------- |
| Ideation       | `elicitation`, `party-mode`                                    |
| Specification  | `step-file-architecture`, `security-review`                    |
| Planning       | `step-file-architecture`, `code-audit`, `security-review`      |
| Implementation | `git-branch-naming`, `conventional-commits`, `security-review` |
| Review         | `adversarial-review`, `code-audit`, `security-review`          |
| Cross-cutting  | `distillation`, `customization`, `token-optimization`          |

---

## Rules That Apply Always

These rules from `.agents/rules/` are loaded in every session:

| Rule                     | Effect                                                          |
| ------------------------ | --------------------------------------------------------------- |
| `constitution.mdc`       | 9 articles of immutable governance, checked at phase boundaries |
| `security.mdc`           | Security-first principles, enforced on every change             |
| `general-principles.mdc` | Simplicity, explicitness, project constraints                   |
| `documentation.mdc`      | Auto-update docs with every change                              |
| `version-management.mdc` | Auto-commit and push, conventional commits, branch discipline   |
