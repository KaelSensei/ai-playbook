---
name: team--skill-refine
description: >
  Iterative refinement protocol. Loaded when any agent returns APPROVE_WITH_CHANGES or
  REQUEST_REDESIGN. Defines how to resolve conflicts, prioritize fixes, route them to the right
  agent, and avoid infinite loops.
---

# Team Refinement Protocol

## On REQUEST_REDESIGN (hard stop)

1. Stop immediately — do not attempt to fix in-place
2. Quote the exact finding that triggered the redesign
3. Identify which agent raised it and their discipline
4. Escalate to user with:
   - The blocker verbatim
   - The agent who raised it
   - Two options: (a) revise design, (b) user explicitly accepts risk
5. If user overrides → document: _"[date] User accepted risk: [issue] — Rationale: [user's reason]"_
   in `tasks/current_task.md`
6. Never silently work around a `REQUEST_REDESIGN`

## On APPROVE_WITH_CHANGES (iterate)

### Step 1 — Collect

Gather all improvements from all agents into a single list.

### Step 2 — Prioritize

```
1. Security / correctness      (smart-contract-engineer, rust-reviewer)
2. Data integrity              (backend-engineer)
3. Deployment / migration safety (devops-engineer, infra-engineer)
4. UX / performance            (frontend-engineer)
5. Style / nits                (any agent)
```

### Step 3 — Route

Assign each fix to its owning agent by discipline. Independent fixes can be addressed in parallel.

### Step 4 — Re-review

After fixes:

- Scope: only changed areas, not full re-review
- Exception: if changes are broad → full re-review
- Agents that had no improvements → no re-review needed (their verdict carries)

### Step 5 — Check loop count

- Maximum 3 refinement loops before escalating to user
- If after loop 3 any agent still returns `APPROVE_WITH_CHANGES` on the same issue: → Escalate:
  _"We've iterated 3 times on [issue]. User decision needed."_
- Never suppress a repeated finding to avoid escalation

## Conflict Mediation

When two agents disagree on a design decision:

1. Quote both positions verbatim
2. Identify the actual tradeoff (security vs gas, simplicity vs extensibility)
3. Present to user: _"[Agent A] recommends X because [reason]. [Agent B] recommends Y because
   [reason]. Which do you prefer?"_
4. User decides
5. Document in `tasks/current_task.md`: _"[agent A] vs [agent B] → user chose [decision] —
   [rationale]"_

Do not resolve conflicts by picking the "nicer" option or the senior agent's preference. Surface the
tradeoff clearly and let the user decide.

## Context Preservation Across Loops

Each iteration passes to agents:

- The previous verdict for each agent (so they can verify their specific issues were addressed)
- The diff of only what changed since their last review
- The original context docs (unchanged)

The orchestrator tracks:

- Issues raised per agent per loop
- Which issues were fixed and verified closed
- Which issues remain open after each loop
