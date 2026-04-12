---
name: step-file-architecture
description:
  Pattern for splitting complex multi-step commands into individual step files loaded one at a time.
  Reduces token usage, enables resume, and prevents context bloat. Use when creating or refactoring
  commands with 5+ steps.
---

# Step-File Architecture Skill

A methodology for structuring complex AI workflows as sequences of self-contained step files, loaded
just-in-time rather than all at once. Inspired by BMAD-METHOD's micro-file design.

## When to use this skill

- When creating a new command with 5+ steps.
- When refactoring an existing command that exceeds ~150 lines.
- When a workflow needs resume capability (pick up where you left off).
- When referenced by `/create-command` for complex workflows.

## How this skill is used

**Users do not invoke skills directly.** Skills are reference knowledge that the AI loads
automatically when it detects a matching task, or when a command explicitly says "use the
`step-file-architecture` skill."

- **Automatic:** The AI loads this skill when creating complex commands.
- **Referenced by:** `/create-command`, `/spec`, `/plan`

---

## The Problem

Monolithic command files (200+ lines) have three issues:

1. **Token waste** — The AI loads the entire command into context, even though it only executes one
   step at a time.
2. **No resume** — If a conversation is interrupted, the AI has no way to know which step was last
   completed.
3. **Context contamination** — Instructions for later steps can confuse the AI during early steps,
   causing it to skip ahead or mix concerns.

## The Solution: Step Files

Split the command into:

- **A main file** — Overview, routing logic, and instructions to load steps one at a time.
- **Individual step files** — Self-contained instructions for one step of the workflow.

### Directory structure

```
.agents/commands/<category>/<command-name>.md        # Main command file
.agents/commands/<category>/<command-name>-steps/    # Step files directory
  step-01-<name>.md
  step-02-<name>.md
  step-03-<name>.md
  ...
```

### Main file structure

The main command file contains:

1. **Command description** — What the command does and when to use it.
2. **Skills used** — Which skills the workflow references.
3. **Step overview** — A numbered list of all steps with one-line descriptions.
4. **Routing instructions** — How to load and execute each step.
5. **State tracking** — How to track progress (for resume).

```markdown
# Command Name — Description

When `/command-name <args>` is invoked, execute the following workflow.

**Skills used:** `skill-a`, `skill-b`.

---

## Workflow Overview

| Step | File                  | Description                              |
| ---- | --------------------- | ---------------------------------------- |
| 1    | `step-01-context.md`  | Load project context and determine scope |
| 2    | `step-02-analyze.md`  | Analyze requirements and identify gaps   |
| 3    | `step-03-produce.md`  | Produce the output artifact              |
| 4    | `step-04-validate.md` | Validate and review the output           |

## Execution Rules

1. **Load ONE step file at a time.** Read the step file completely before acting.
2. **Execute the step fully** before moving to the next.
3. **Track progress** by noting which steps are completed.
4. **If interrupted:** On resume, check which steps produced output artifacts and continue from the
   next incomplete step.
5. **Do NOT skip steps** unless the step file explicitly says "skip if <condition>."
```

### Step file structure

Each step file is fully self-contained:

```markdown
# Step N: Step Name

## Prerequisites

- Step N-1 must be completed (artifact: `<expected output>`)
- Required context: <what this step needs from earlier steps>

## Actions

1. First action to take
2. Second action to take
3. ...

## Output

- What this step produces (artifact, decision, validation result)
- Where to store it (file path, memory, or inline)

## Completion Criteria

- [ ] Criterion 1 is met
- [ ] Criterion 2 is met

## Next

→ Proceed to `step-{N+1}-<name>.md`
```

---

## State Tracking for Resume

Commands using step files should track progress via one of:

### Option A: Output artifacts (recommended)

Each step produces a tangible output (a file, a section in a document, a decision recorded in a
spec). On resume, check which artifacts exist to determine the last completed step.

### Option B: Frontmatter in output document

If the workflow produces a single document, track progress in its YAML frontmatter:

```yaml
---
command: /spec
stepsCompleted: [1, 2, 3]
lastUpdated: 2026-04-12
---
```

### Option C: Inline checklist in main file

For simpler workflows, maintain a checklist in the main command output:

```markdown
## Progress

- [x] Step 1: Context loaded
- [x] Step 2: Requirements analyzed
- [ ] Step 3: Output produced
- [ ] Step 4: Validated
```

---

## When NOT to Use Step Files

- **Simple commands** (< 5 steps, < 100 lines) — Keep them monolithic. The overhead of step files
  isn't worth it.
- **Linear commands with no branching** — If every invocation runs the same 3-4 steps with no
  decisions, a single file is fine.
- **Commands that must be atomic** — If the command must complete in a single pass with no
  interruption (e.g., `/git`), don't split it.

## Anti-patterns

- **Steps that depend on reading other step files** — Each step must be self-contained. Don't
  reference instructions from other steps.
- **Steps that are too granular** — "Read file X" is not a step. A step should be a meaningful unit
  of work.
- **Main file that duplicates step content** — The main file is an index, not a summary of all
  steps. Keep it to one-line descriptions.
- **Skipping steps for speed** — If a step exists, it exists for a reason. Don't skip to save time.
