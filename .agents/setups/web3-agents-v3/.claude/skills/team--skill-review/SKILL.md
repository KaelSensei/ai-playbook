---
name: team--skill-review
description: >
  Shared review protocol for all agents. Defines verdict levels, output format, and merge rules.
  Loaded by every agent during /review, /spec review pass, and /implement pair review. Every agent
  that reviews MUST follow this format.
---

# Team Review Protocol

## Verdict Levels

| Verdict                | Meaning                                          | Blocks progress?      |
| ---------------------- | ------------------------------------------------ | --------------------- |
| `APPROVE`              | No significant issues from this discipline       | No                    |
| `APPROVE_WITH_CHANGES` | Issues present but not blocking deployment       | Improvements expected |
| `REQUEST_REDESIGN`     | Fundamental problem — must fix before proceeding | Hard stop             |

**Rules:**

- Any single `REQUEST_REDESIGN` from any agent = full stop, escalate to user
- Any `APPROVE_WITH_CHANGES` (no redesign) = iterate before next step
- All `APPROVE` = proceed
- Unanimous approval required — no majority vote, no override by seniority

## Required Output Structure

Every agent MUST return exactly this structure, no exceptions:

```markdown
## [Discipline] Review

**Verdict**: APPROVE | APPROVE_WITH_CHANGES | REQUEST_REDESIGN

### 🔴 Blockers

<!-- Issues that must be fixed before proceeding.
     One entry per issue. Reference specific location. -->

- **[file:function or component]**: [issue] — [why it matters] — [required fix]

### 🟡 Improvements

<!-- Should fix, not hard blocking. -->

- **[location]**: [issue] — [suggested fix]

### 🔵 Nits

<!-- Optional. Style, naming, minor suggestions. -->

- [note]

### Discipline Checklist

<!-- Tick every item. If not applicable, mark N/A. -->

- [x] / [ ] / [N/A] [checklist item 1]
- [x] / [ ] / [N/A] [checklist item 2] ...
```

## Merge Rules (for orchestrator)

1. Collect all agent verdicts
2. If any `REQUEST_REDESIGN` → overall = `REQUEST_REDESIGN`
3. If any `APPROVE_WITH_CHANGES` (no redesign) → overall = `APPROVE_WITH_CHANGES`
4. All `APPROVE` → overall = `APPROVE`
5. Deduplicate findings across agents — one entry per unique issue, highest severity wins
6. If multiple agents flagged the same issue → note: _"flagged by N agents"_
7. Present merged verdict with attribution per agent

## Scope Per Flow

| Flow                      | Read | Write code       | Scope                                    |
| ------------------------- | ---- | ---------------- | ---------------------------------------- |
| `/review`                 | ✅   | ❌               | Full diff — correctness, security, ops   |
| `/spec` review pass       | ✅   | ❌               | Design only — no implementation critique |
| `/implement` pair review  | ✅   | Owner agent only | Current step diff only                   |
| `/implement` final review | ✅   | ❌               | Entire changeset                         |

## Prohibited Behaviors

- ❌ Approving without running your discipline checklist
- ❌ Generic feedback not tied to your discipline
- ❌ Approving because another agent approved
- ❌ Critiquing something outside your discipline's scope
- ❌ Empty `🔴 Blockers` section with `REQUEST_REDESIGN` verdict — always explain
