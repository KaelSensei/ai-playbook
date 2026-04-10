---
name: debt
description: >
  Audit and prioritize technical debt. debt-tracker + legacy-analyst in parallel. Produces a
  prioritized inventory and a repayment plan.
argument-hint: '[specific module or empty for global audit]'
---

# /debt

Update `tasks/current_task.md`: status=DEBT

---

## Phase 1 — Metrics collection

```bash
# Hotspots (most modified files = likely debt)
git log --name-only --format="" | grep -v "^$" | sort | uniq -c | sort -rn | head -20

# File size (large files = red flag)
find . -name "*.[extension]" | xargs wc -l 2>/dev/null | sort -rn | head -20

# Complexity (if tool available)
# PHP: phploc src/
# Python: radon cc src/ -a
# JS: npx complexity-report src/

# Duplication
# PHP: phpcpd src/ --min-lines 5
# JS: npx jscpd src/
```

---

## Phase 2 — Spawn debt-tracker and legacy-analyst in parallel

**debt-tracker prompt:**

```
You are debt-tracker.
Load .claude/agents/debt-tracker.md.
Load project-architecture.md, legacy-map.md.
Load technical-debt skill.

Scope: $ARGUMENTS (or global if empty)
Metrics collected: [Phase 1 output]
Existing legacy map: [legacy-map.md content]

Produce:
1. Debt inventory by category (critical/significant/minor)
2. Impact/Effort score for each item
3. Top 5 items to pay back in priority
4. Accepted deliberate debt (document reasons)
```

**legacy-analyst prompt:**

```
You are legacy-analyst.
Load .claude/agents/legacy-analyst.md.
Load project-architecture.md, legacy-map.md.
Load legacy-patterns, technical-debt skills.

Scope: $ARGUMENTS
Metrics: [Phase 1 output]

Enrich the inventory with:
1. Zones not yet mapped (unknown risk)
2. Identified dangerous couplings
3. Modules currently blocking features
4. Estimate the "interest" for each item (cost per future feature)
```

---

## Phase 3 — Synthesis and plan

Merge the outputs and produce:

```markdown
# Technical Debt Audit

Date: [today] Scope: $ARGUMENTS

## Executive Summary

[3-5 sentences: general state, top problems, main recommendation]

## Prioritized Inventory

### Critical (score > 3)

| Item | Type | File(s) | Impact | Effort | Score | Action |
| ---- | ---- | ------- | ------ | ------ | ----- | ------ |

### Significant (score 1.5-3)

| Item | Type | File(s) | Impact | Effort | Score | Action |
| ---- | ---- | ------- | ------ | ------ | ----- | ------ |

### Minor (score < 1.5)

| Item | Type | File(s) | Impact | Effort | Score | Action |
| ---- | ---- | ------- | ------ | ------ | ----- | ------ |

### Accepted Deliberate Debt

| Item | Reason | Since | Planned Repayment |
| ---- | ------ | ----- | ----------------- |

## Recommended Repayment Plan

### This week (Quick wins — effort 1)

- [items]

### This sprint (effort 2-3)

- [items]

### Next quarter (effort 4-5, Strangler Fig)

- [items]

### Accepted indefinitely

- [items with justification]

## Unmapped Zones (unknown risk)

- [modules never explored]
```

---

## Phase 4 — Present and decide

Present to the user. **Gate**: _"Does this plan match the business priorities?"_

Update `legacy-map.md` with the new findings. Save the report to
`.claude/specs/debt-audit-[date].md`.

Update `tasks/current_task.md`: status=IDLE

```
Audit complete
Critical items: [N]
Quick wins identified: [N]
Report: .claude/specs/debt-audit-[date].md
```
