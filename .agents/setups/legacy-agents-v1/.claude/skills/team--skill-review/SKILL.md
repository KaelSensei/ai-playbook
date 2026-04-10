---
name: team--skill-review
description: >
  Review protocol shared by all agents. Defines verdict levels, output format, and merge rules.
  Loaded by all agents during /review, /spec, /build, and /check.
---

# Team Review Protocol

## Verdict Levels

| Verdict                | Meaning                                          | Blocks?            |
| ---------------------- | ------------------------------------------------ | ------------------ |
| `APPROVE`              | No significant issue                             | No                 |
| `APPROVE_WITH_CHANGES` | Issues present but not blocking                  | Iteration expected |
| `REQUEST_REDESIGN`     | Fundamental problem — must fix before continuing | Yes, hard stop     |

**Rules:**

- A single `REQUEST_REDESIGN` from any agent = complete halt
- A single `APPROVE_WITH_CHANGES` = iteration before the next step
- Unanimous `APPROVE` = proceed
- No majority vote. No seniority override. Unanimous.

## Mandatory Output Format

Each agent MUST return exactly this structure:

```markdown
## [Discipline] Review

**Verdict**: APPROVE | APPROVE_WITH_CHANGES | REQUEST_REDESIGN

### Blockers

<!-- Must be fixed before continuing.
     One entry per issue. Reference the exact location. -->

- **[file:line or component]**: [issue] — [why it's blocking] — [required fix]

### Improvements

<!-- Should be fixed, not blocking. -->

- **[location]**: [issue] — [suggested fix]

### Nits

<!-- Optional. Style, naming, minor suggestions. -->

- [note]

### Discipline Checklist

- [x] / [ ] / [N/A] [item 1]
- [x] / [ ] / [N/A] [item 2] ...
```

## Merge Rules (for the orchestrator)

1. Collect all verdicts
2. If at least one `REQUEST_REDESIGN` → global verdict = `REQUEST_REDESIGN`
3. If at least one `APPROVE_WITH_CHANGES` (without redesign) → global verdict =
   `APPROVE_WITH_CHANGES`
4. All `APPROVE` → global verdict = `APPROVE`
5. Deduplicate findings across agents — one entry per unique issue, highest severity
6. If multiple agents flagged the same issue → note: _"flagged by N agents"_
7. Present the merged verdict with per-agent attribution

## Scope Per Flow

| Flow                  | Read | Write code        | Scope                                  |
| --------------------- | ---- | ----------------- | -------------------------------------- |
| `/review`             | yes  | no                | Full diff                              |
| `/spec` review        | yes  | no                | Design only, no implementation         |
| `/build` pair review  | yes  | Owning agent only | Diff of the current step               |
| `/build` final review | yes  | no                | Full diff from the start               |
| `/check`              | yes  | no                | Full diff, focus quality/security/data |

## Forbidden Behaviors

- APPROVE without having ticked the checklist
- Generic feedback not tied to your discipline
- APPROVE because another agent approved
- Criticizing things outside your discipline's scope
- `REQUEST_REDESIGN` without explaining the problem
