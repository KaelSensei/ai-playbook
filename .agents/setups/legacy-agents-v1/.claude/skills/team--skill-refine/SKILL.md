---
name: team--skill-refine
description: >
  Iteration protocol. Loaded when an agent returns APPROVE_WITH_CHANGES or REQUEST_REDESIGN. Defines
  how to resolve conflicts, prioritize fixes, route them to the right agent, and avoid infinite
  loops.
---

# Team Refinement Protocol

## On REQUEST_REDESIGN (immediate halt)

1. Stop immediately — do not try to fix in place
2. Quote the exact finding that triggered the redesign
3. Identify which agent raised it and their discipline
4. Escalate to the user with:
   - The problem verbatim
   - The agent who raised it
   - Two options: (a) rework the design, (b) the user explicitly accepts the risk
5. If override → document in `tasks/current_task.md`: _"[date] [agent] → risk accepted: [problem] —
   Reason: [user reason]"_
6. Never silently bypass a `REQUEST_REDESIGN`

## On APPROVE_WITH_CHANGES (iterate)

### Step 1 — Collect

Gather all improvements from all agents into a single list.

### Step 2 — Prioritize

```
1. Security (security-reviewer)
2. Correctness / logic (dev-senior-a/b, qa-engineer)
3. Data integrity (data-engineer)
4. Architecture / debt (architect, tech-lead)
5. Deployment / ops (devops-engineer)
6. UX / accessibility (ux-designer)
7. Style / nits (any agent)
```

### Step 3 — Route

Assign each fix to its owning agent by discipline. Independent fixes can be addressed in parallel.

### Step 4 — Re-review

After fixes:

- Scope: only the modified areas, not a full re-review
- Exception: if the changes are large → full re-review
- Agents with no improvement → their previous verdict remains valid

### Step 5 — Check the loop counter

- Maximum **3 refinement loops** before escalating to the user
- If after loop 3 an agent still returns `APPROVE_WITH_CHANGES` on the same issue → escalate: _"3
  iterations on [problem]. User decision required."_
- Never silently drop a repeated finding to avoid escalation

## Conflict Mediation

When two agents disagree on a technical decision:

1. Quote both positions verbatim
2. Identify the real trade-off (perf vs maintainability, simplicity vs extensibility)
3. Present to the user: _"[Agent A] recommends X because [reason]. [Agent B] recommends Y because
   [reason]. Which do you prefer?"_
4. The tech-lead can arbitrate if the user delegates
5. Document in `tasks/current_task.md`

Never resolve conflicts by picking the "nicest" option or the most senior agent's option. Surface
the trade-off clearly.

## Context Preservation Between Loops

Each iteration passes to the agents:

- Each agent's previous verdict (so they can check whether their issues were addressed)
- The diff of what changed since their last review
- Unchanged context docs

The orchestrator tracks:

- Issues raised per agent per loop
- Issues fixed and verified closed
- Issues still open after each loop
