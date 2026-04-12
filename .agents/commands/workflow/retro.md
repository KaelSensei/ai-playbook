# Retro Command — Post-Feature Retrospective

When `/retro [feature or branch]` is invoked, run a structured retrospective on completed work to
capture learnings, identify improvements, and celebrate wins.

**Skills used:** `elicitation` (retrospective techniques), `party-mode` (optional, for
multi-perspective review).

Inspired by BMAD-METHOD's retrospective workflow.

---

## Why Retrospectives Matter

Without retrospectives, teams repeat the same mistakes and forget what worked. A 10-minute retro
after each feature saves hours on the next one. The goal is not blame — it's learning.

---

## Step 1: Load Context

1. Identify the scope of the retrospective:
   - If argument provided: focus on that feature/branch
   - If no argument: retrospect on the current branch's work
2. Read the work history:
   - `git log --oneline` for the branch (all commits since branch creation)
   - `SPEC.md`, `PLAN.md` (if they exist) — what was intended
   - Actual implementation — what was built
   - Any pivot commits — what changed mid-flight
3. Estimate timeline: when did the work start? When did it finish?

---

## Step 2: Gather Evidence

Before opinions, gather facts:

### What was planned?

- User stories from SPEC.md (P1/P2/P3)
- Tasks from PLAN.md
- Original scope boundaries

### What was delivered?

- Actual commits and files changed
- Which P1/P2/P3 stories were completed
- Any scope changes (pivots)

### What happened along the way?

- How many commits? How many pivots?
- Any blockers or surprises?
- Any `[NEEDS CLARIFICATION]` markers that slowed things down?
- Any constitution violations caught during implementation?

---

## Step 3: Structured Reflection

Use one of these formats (auto-select based on complexity, or let the user choose):

### Format A: Start / Stop / Continue (Quick — for small features)

```markdown
## Retrospective: <feature/branch>

### Start (things we should do next time)

- ...

### Stop (things that hurt us)

- ...

### Continue (things that worked well)

- ...
```

### Format B: 4 Ls (Standard — for medium features)

```markdown
## Retrospective: <feature/branch>

### Liked (what went well)

- ...

### Learned (new knowledge gained)

- ...

### Lacked (what was missing)

- ...

### Longed For (what we wished we had)

- ...
```

### Format C: Timeline (Deep — for complex features or multi-week work)

```markdown
## Retrospective: <feature/branch>

### Timeline

| Date   | Event                   | Impact          |
| ------ | ----------------------- | --------------- |
| <date> | Branch created          | —               |
| <date> | First blocker hit       | Delayed 2 days  |
| <date> | Pivot: changed approach | Threw away T003 |
| <date> | Feature complete        | —               |

### High Points

- ...

### Low Points

- ...

### Patterns

- ...
```

### Optional: Party Mode Retro

If `--party` flag is used, spawn a roundtable retrospective:

- **The Pragmatist** — Was the approach efficient? What would be faster next time?
- **The Skeptic** — What nearly went wrong? What risks were underestimated?
- **The Newcomer** — What was confusing? What would help someone new?

---

## Step 4: Extract Actionable Improvements

From the reflection, identify 2-5 concrete, actionable improvements:

```markdown
### Action Items

1. **<specific improvement>**
   - Why: <what happened that motivates this>
   - How: <concrete next step>
   - When: <next feature / next sprint / now>

2. **<specific improvement>**
   - Why: ...
   - How: ...
   - When: ...
```

### Good action items:

- "Add edge case tests for date parsing before implementing date features"
- "Run /ready-check before starting Full Flow features"
- "Create SPEC.md for any feature touching more than 3 files"

### Bad action items:

- "Be more careful" (vague)
- "Write better code" (not actionable)
- "Don't make mistakes" (not helpful)

---

## Step 5: Document and Close

1. **Save the retrospective:**
   - Append to `RETRO.md` in the project root (create if doesn't exist)
   - Include date, feature name, format used, findings, and action items

2. **Commit:**

   ```bash
   git add RETRO.md
   git commit -m "docs: retro for <feature/branch>"
   git push origin $(git branch --show-current)
   ```

3. **Celebrate:** If the feature shipped successfully, acknowledge it. Retrospectives should end on
   a positive note, not just a list of problems.

---

## Behavior Rules

- **No blame.** Retrospectives are about the process, not the people.
- **Evidence first, opinions second.** Start with git log and artifacts, then reflect.
- **Concrete over vague.** "Edge case tests would have caught the date bug" > "we need more tests."
- **Short is fine.** A 5-line Start/Stop/Continue is better than no retro at all.
- **Action items must be actionable.** If you can't do it next time, it's not an action item.
- **Positive required.** Every retro must include at least one thing that went well.

---

## Usage

- `/retro` — Retrospect on current branch's work
- `/retro feature/user-auth` — Retrospect on a specific branch
- `/retro --party` — Multi-perspective retrospective
- `/retro --deep` — Force Timeline format for thorough analysis
