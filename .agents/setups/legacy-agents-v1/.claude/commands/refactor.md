---
name: refactor
description: >
  Safe refactoring with a test safety net. refactoring-guide orchestrates, dev-senior-a implements,
  dev-senior-b reviews after each step. Every micro-increment must be green before the next.
argument-hint: '[refactoring module or target]'
---

# /refactor

Update `tasks/current_task.md`: status=REFACTOR, module=$ARGUMENTS

---

## Absolute Prerequisites

Verify before starting:

```
[ ] /understand $ARGUMENTS done → card in legacy-map.md
[ ] /characterize $ARGUMENTS done → characterization tests in place
[ ] All tests pass (run the runner now)
```

If any missing → stop. No refactoring without a net.

```bash
[runner] tests/  # MUST be all green before starting
```

---

## Phase 1 — Establish the refactoring plan

Invoke `refactoring-guide` to establish the plan:

```
You are refactoring-guide.
Load .claude/agents/refactoring-guide.md.
Load project-architecture.md, legacy-map.md.
Load refactoring-patterns, legacy-patterns, testing-patterns skills.

Refactoring goal: $ARGUMENTS
Characterization tests in place: [list from legacy-map.md]

Propose a refactoring plan in micro-steps:
- Each step must be atomic (< 30 min)
- Each step must be committable in isolation
- Each step must leave tests green
- Use the Fowler catalogue (name each refactoring)
- Order: from safest to riskiest

Specify for each step:
- Refactoring name (Fowler catalogue)
- Exact change to make
- Estimated risk
```

Present the plan to the user. **Gate**: _"Is this plan correct? Any steps to modify?"_

---

## Phase 2 — Micro-incremental execution

For each step in the plan:

### 2a. dev-senior-a implements the step

```
You are dev-senior-a. Legacy refactoring mode.
Load .claude/agents/dev-senior-a.md.
Load project-architecture.md, legacy-map.md.
Load refactoring-patterns, legacy-patterns skills.

Step [N]: [refactoring name] — [description]
Reference characterization tests: [list]

RULES:
- Only change what is described in this step
- Do NOT improve behavior (pure refactoring)
- Run the tests after the change

Required output:
- Diff of the change
- Runner output (ALL tests must pass)
```

### 2b. dev-senior-b reviews the step

```
You are dev-senior-b.
Load team--skill-review.

Review this refactoring step:
[diff]

Verify:
1. Characterization tests still green?
2. Behavior preserved (no logic change)?
3. Minimal change (no scope creep)?
4. Step reversible via git revert?
```

Apply `team--skill-refine` if needed.

### 2c. Commit

```bash
git add .
git commit -m "refactor([module]): [Fowler refactoring name]"
```

---

## Phase 3 — Final review (all agents)

When all steps are done:

Spawn ALL agents on the full diff:

```
Review the complete refactoring of $ARGUMENTS.
Verify: behavior preserved, tests still green,
consistency of the result, debt reduced or maintained.
```

Apply `team--skill-refine` until unanimous APPROVE.

---

## Emergency Rule

If a characterization test turns red at any step:

```
1. git revert HEAD  (return immediately)
2. Analyze why (the refactoring changed behavior)
3. Split into a smaller step
4. Start again
```

Never "fix" a failing characterization test. A failing characterization test = changed behavior =
regression.

Update `tasks/current_task.md`: status=IDLE

```
Refactoring complete: $ARGUMENTS
Steps: [N] micro-increments
Tests: [N] passing (no regression)
Final review: unanimous APPROVE
```
