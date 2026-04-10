---
name: team--skill-review
description: >
  Shared review protocol for all agents. Defines verdict levels, output format, and merge rules.
  Loaded by every agent during /review, /spec, /build and /check.
---

# Team Review Protocol

## Verdict Levels

| Verdict                | Meaning                                        | Blocks?            |
| ---------------------- | ---------------------------------------------- | ------------------ |
| `APPROVE`              | No significant issue                           | No                 |
| `APPROVE_WITH_CHANGES` | Issues present but not blocking                | Iteration expected |
| `REQUEST_REDESIGN`     | Fundamental issue — must fix before continuing | Yes, hard stop     |

**Rules:**

- A single `REQUEST_REDESIGN` from any agent = full stop
- A single `APPROVE_WITH_CHANGES` = iteration before the next step
- Unanimous `APPROVE` = move forward
- No majority vote. No seniority override. Unanimous.

## Mandatory Output Format

Each agent MUST return exactly this structure:

```markdown
## [Discipline] Review

**Verdict**: APPROVE | APPROVE_WITH_CHANGES | REQUEST_REDESIGN

### 🔴 Blockers

<!-- Must be fixed before continuing.
     One entry per issue. Reference the precise location. -->

- **[file:line or component]**: [issue] — [why it blocks] — [required fix]

### 🟡 Improvements

<!-- Should be fixed, not blocking. -->

- **[location]**: [issue] — [suggested fix]

### 🔵 Nits

<!-- Optional. Style, naming, minor suggestions. -->

- [note]

### Discipline Checklist

- [x] / [ ] / [N/A] [item 1]
- [x] / [ ] / [N/A] [item 2] ...
```

## Merge Rules (for the orchestrator)

1. Collect all verdicts
2. If at least one `REQUEST_REDESIGN` → global verdict = `REQUEST_REDESIGN`
3. If at least one `APPROVE_WITH_CHANGES` (no redesign) → global verdict = `APPROVE_WITH_CHANGES`
4. All `APPROVE` → global verdict = `APPROVE`
5. Dedupe findings across agents — one entry per unique issue, highest severity
6. If multiple agents flagged the same issue → note: _"flagged by N agents"_
7. Present the merged verdict with per-agent attribution

## Scope by Flow

| Flow                  | Read | Write code       | Scope                                |
| --------------------- | ---- | ---------------- | ------------------------------------ |
| `/review`             | ✅   | ❌               | Full diff                            |
| `/spec` review        | ✅   | ❌               | Design only, no implementation       |
| `/build` pair review  | ✅   | Owner agent only | Current step diff                    |
| `/build` final review | ✅   | ❌               | Full diff from the start             |
| `/check`              | ✅   | ❌               | Full diff, focus on quality/sec/data |

## Forbidden Behaviors

- ❌ APPROVE without checking the checklist
- ❌ Generic feedback unrelated to your discipline
- ❌ APPROVE because another agent approved
- ❌ Criticizing what is outside your discipline
- ❌ `REQUEST_REDESIGN` without explaining the issue
