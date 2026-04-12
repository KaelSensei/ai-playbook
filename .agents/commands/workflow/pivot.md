# Pivot Command — Mid-Sprint Change Management

When `/pivot <change description>` is invoked, manage a scope change mid-implementation with
structured impact analysis across all project artifacts.

**Skills used:** `security-review` (security impact of changes), `code-audit` (architecture impact).

Inspired by BMAD-METHOD's Correct Course workflow.

---

## Why This Exists

Mid-implementation scope changes are inevitable. The wrong way to handle them: silently change
direction and hope nothing breaks. The right way: assess impact across all artifacts, propose the
change formally, get approval, then update everything.

---

## Step 1: Load Current State

1. Read all project artifacts:
   - `SPEC.md`, `PLAN.md`, `PRFAQ.md` (if they exist)
   - Current branch, recent commits (`git log --oneline -20`)
   - Implementation progress (what's done, what's in flight, what's pending)
2. Load rules from `.agents/rules/*.mdc`
3. Parse the change description from the command argument

---

## Step 2: Classify the Change

Determine the change scope:

### Minor Change (cosmetic, no artifact updates needed)

Criteria: wording change, UI tweak, implementation detail that doesn't affect spec or plan. → **No
formal pivot needed.** Implement directly via `/feature` or `/fix`.

### Moderate Change (affects plan, not spec)

Criteria: different technical approach, task reordering, adding/removing implementation tasks, new
dependency. Spec intent is unchanged. → **Update PLAN.md.** Proceed with Steps 3-5.

### Major Change (affects spec and plan)

Criteria: scope change, new/removed user stories, changed acceptance criteria, different target
user, fundamental approach shift. → **Update SPEC.md and PLAN.md.** Proceed with Steps 3-6.

Present the classification to the user for confirmation before proceeding.

---

## Step 3: Impact Analysis

Analyze impact across every artifact:

```markdown
## Change Impact Analysis

### Change Summary

<1-2 sentences describing what is changing and why>

### Artifacts Affected

| Artifact       | Impact               | Details                                    |
| -------------- | -------------------- | ------------------------------------------ |
| SPEC.md        | None / Minor / Major | <what changes>                             |
| PLAN.md        | None / Minor / Major | <what changes>                             |
| PRFAQ.md       | None / Minor / Major | <what changes>                             |
| Implementation | None / Minor / Major | <what code changes, what gets thrown away> |
| Tests          | None / Minor / Major | <what tests change or become invalid>      |
| Documentation  | None / Minor / Major | <what docs need updating>                  |

### Tasks Affected

- T003: <status change — e.g., "no longer needed", "scope expanded", "blocked by new dependency">
- T005: <new task needed>

### Risk Assessment

- <risk 1 — e.g., "Throwing away 2 days of work on T003">
- <risk 2 — e.g., "New dependency has no audit history">
```

---

## Step 4: Propose the Change

Create a formal change proposal:

```markdown
## Pivot Proposal

### Before

<what the current spec/plan says>

### After

<what the new spec/plan would say>

### Justification

<why this change is needed — user feedback, technical discovery, requirement change>

### Cost

- Tasks to discard: <list>
- Tasks to add: <list>
- Tasks to modify: <list>
- Net scope change: <smaller / same / larger>

### Recommendation

PROCEED | PROCEED WITH CAUTION | RECONSIDER
```

**Present the proposal to the user. STOP and wait for approval.**

Do NOT update any artifacts until the user approves.

---

## Step 5: Update Plan Artifacts (After Approval)

If the change is Moderate:

1. Update `PLAN.md`:
   - Modify affected tasks (mark obsolete ones, add new ones)
   - Update the technical design if approach changed
   - Re-run the constitution check for the updated plan
2. Update task dependencies if order changed
3. Commit:
   ```bash
   git add PLAN.md
   git commit -m "docs: pivot — <brief description of change>"
   git push origin $(git branch --show-current)
   ```

---

## Step 6: Update Spec Artifacts (Major Changes Only)

If the change is Major:

1. Update `SPEC.md`:
   - Modify or add/remove user stories
   - Update acceptance criteria
   - Update scope boundaries (in/out)
   - Re-run the constitution check
2. Update `PLAN.md` to match the new spec (same as Step 5)
3. Update `PRFAQ.md` if the customer value proposition changed
4. Commit:
   ```bash
   git add SPEC.md PLAN.md
   git commit -m "docs: major pivot — <brief description of change>"
   git push origin $(git branch --show-current)
   ```

---

## Step 7: Resume Work

After artifacts are updated:

1. Tell the user what changed and what the next task is
2. Suggest: "Run `/validate` to verify consistency, then continue with `/feature`."

---

## Behavior Rules

- **Never update artifacts without user approval.** The proposal is a proposal, not an action.
- **Be honest about cost.** If the pivot means throwing away work, say so clearly.
- **Minor changes don't need /pivot.** Don't over-process small adjustments.
- **Track the pivot.** Every pivot gets a commit so the history shows why direction changed.
- **No blame.** Pivots happen. The point is to manage them, not prevent them.

---

## Usage

- `/pivot switch from REST to GraphQL` — Moderate: technical approach change
- `/pivot add multi-tenant support` — Major: new user stories and architecture
- `/pivot drop the mobile view for v1` — Major: scope reduction
- `/pivot use Redis instead of in-memory cache` — Moderate: dependency change
