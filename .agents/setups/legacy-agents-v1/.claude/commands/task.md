---
name: task
description: >
  Universal Legacy entry point. Describe your task in natural language. The orchestrator first
  checks whether the module is mapped and whether a test safety net exists. If not, it launches
  understand + characterize before anything else. You cannot bypass this step.
argument-hint: '[free-form task description]'
---

# /task (Legacy)

Update `tasks/current_task.md`: status=ORCHESTRATING, task=$ARGUMENTS

---

## Step 1 — Orchestrator analyzes

```
You are orchestrator.
Load .claude/agents/orchestrator.md.
Load project-architecture.md, legacy-map.md, constants.md.
Load the ## Agent Team table from CLAUDE.md.

Task received: $ARGUMENTS

FIRST QUESTION: is the affected module in legacy-map.md?
SECOND QUESTION: do characterization tests exist?

If no to either → mandatory prior plan.
Otherwise → analyze the task type and complexity.

Produce your full plan.
```

Present the plan. **Gate**: _"Is this plan correct?"_

---

## Step 2 — Execution per the plan

### If net is missing → Prerequisites first

```
Net missing. Execution order:

1. /understand [module] → legacy-analyst + archaeologist
2. /characterize [module] → characterization-tester
3. Return to /task $ARGUMENTS once the net is in place
```

Spawn legacy-analyst + archaeologist in parallel. Then characterization-tester. Then restart the
analysis.

---

### If net is in place → Direct execution

**Refactoring (level 1-2):**

```
refactoring-guide → micro-increments plan
dev-senior-a → implementation
dev-senior-b → review after each step
```

**New Strangler code (level 2-3):**

```
→ /strangler $ARGUMENTS
```

**Bug fix:**

```
characterization-tester → regression test first
dev-senior-a → fix
dev-senior-b → review
```

**Complex (level 3):**

```
→ /spec → /build (full formal flows)
```

---

## Step 3 — Completion

Update `tasks/current_task.md`: status=IDLE

---

## Routing Examples

| Task                                   | Net? | Level   | Action                                |
| -------------------------------------- | ---- | ------- | ------------------------------------- |
| "understand the billing module"        | N/A  | explore | /understand billing                   |
| "fix the discount calculation bug"     | no   | prereq  | understand → characterize → fix       |
| "fix the discount calculation bug"     | yes  | 2       | regression test → fix → review        |
| "refactor UserController (2000 lines)" | no   | prereq  | understand → characterize → refactor  |
| "refactor UserController (2000 lines)" | yes  | 3       | /refactor micro-incremental           |
| "new notifications module"             | N/A  | 3       | /strangler (new TDD code)             |
| "technical debt audit"                 | N/A  | explore | /debt                                 |
| "migrate email sending to SendGrid"    | no   | prereq  | understand → characterize → strangler |
