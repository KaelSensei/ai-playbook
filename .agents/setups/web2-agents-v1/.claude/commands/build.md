---
name: build
description: >
  Implement in strict TDD. dev-senior-a codes (RED→GREEN→BLUE), dev-senior-b reviews the test FIRST
  then the code, all agents review in parallel at each step. Requires an approved spec.
argument-hint: '[spec slug]'
---

# /build

Update `tasks/current_task.md`: status=BUILD, Active Spec: .claude/specs/$ARGUMENTS.md

---

## Phase 1 — LOAD THE TEST LIST

Load `.claude/specs/$ARGUMENTS.md`. Extract the ordered test list. Show it to the user. Confirm
before starting.

Update `tasks/current_task.md`: Active Test List = [full list]

---

## Phase 2 — TDD LOOP (one item at a time)

Repeat for each item in the test list, in order.

### 2a. RED — dev-senior-a writes ONE test

```
You are dev-senior-a.
Load .claude/agents/dev-senior-a.md.
Load context docs and skills per the Agent Team table.
Load the spec: [contents of .claude/specs/$ARGUMENTS.md]

Remaining test list: [unchecked items]
Next item: [next item]

RED phase only.

Write ONE test for this behavior.
Run the test runner. The test MUST fail.
Verify it's an assertion failure (not a compilation error).

Required output:
- Test code
- Runner output (must be FAIL)
- Failure reason (must be the assertion, not an import)
```

**Automatic gate**: if the test passes → the test is wrong → redo.

---

### 2b. TEST REVIEW — dev-senior-b first

```
You are dev-senior-b.
Load .claude/agents/dev-senior-b.md.
Load context docs and skills per the Agent Team table.
Load team--skill-review.

REVIEW THE TEST ONLY — not the production code (it doesn't exist yet).

Test to review: [test written by dev-senior-a]

Questions:
- Does this test cover the right behavior?
- Is the assertion precise?
- Is the test independent?
- Would the test fail if the code were removed?
- Does the name clearly describe the behavior?

Verdict: APPROVE | APPROVE_WITH_CHANGES | REQUEST_REDESIGN
```

If `REQUEST_REDESIGN` → dev-senior-a rewrites the test. If `APPROVE_WITH_CHANGES` → fixes,
re-review. If `APPROVE` → move on to GREEN.

---

### 2c. GREEN — dev-senior-a writes the minimum code

```
You are dev-senior-a.
GREEN phase only.

Approved test: [test]
All existing tests: [list]

Write the MINIMUM code to make the test pass.
Hard-code if necessary. Duplication allowed.
Run the runner: ALL tests must pass.

Required output:
- Code added/modified
- Runner output (must be ALL PASS)
- "Sins committed": shortcuts, hardcode, duplication
```

**Automatic gate**: if a test regresses → fix before continuing.

---

### 2d. PAIR REVIEW — all agents in parallel

Load `team--skill-review` for all agents. Spawn EVERY agent from the `## Agent Team` table
simultaneously:

```
You are [AGENT_PERSONA]. Review mode — no code writing.
Load context docs and skills.
Load team--skill-review.

Review this TDD step from your disciplinary angle.
Step diff: [test + GREEN code]
Spec: [full spec]

Note: the code is in GREEN phase — duplication and hardcode are normal.
Review correctness and structural issues, not cleanliness.
```

Collect verdicts. Apply `team--skill-refine` if needed.

---

### 2e. BLUE — dev-senior-a refactors

```
You are dev-senior-a.
BLUE phase only.

Sins listed in GREEN: [list]
Current code: [code]

Eliminate duplication. Improve naming.
NO new functionality.
Run the runner at each step of the refactoring.
All tests must stay green.
```

---

### 2f. COMMIT and next item

```bash
git add .
git commit -m "test([scope]): [test list item]"
```

Check off the item in `tasks/current_task.md`. Move to the next item. Go back to 2a.

---

## Phase 3 — VERIFY (once the test list is exhausted)

```bash
[runner] --coverage    # coverage must not regress
[linter]               # zero warnings
```

---

## Phase 4 — FINAL REVIEW (full diff)

Spawn ALL agents on the full diff:

```
FULL review of the $ARGUMENTS implementation.
Look at interaction effects between steps.
Does the implementation match the spec?
Is the test list fully covered?
```

Loop with `team--skill-refine` until unanimous `APPROVE`.

## Phase 5 — scribe documents

Spawn `scribe` in parallel with the final review:

```
You are scribe.
Feature completed:
Commit range: [first build commit..HEAD]

Produce:
1. CHANGELOG.md entry
2. Update technical docs if architecture changed
3. ADR if an architectural decision was made during this build
4. Rollback plan in docs/rollbacks/
5. Update PROGRESS.md
```

Update `tasks/current_task.md`: status=IDLE

```
✅ Build complete
  Feature: $ARGUMENTS
  Tests: [N] passing
  Test list: [N/N] items covered
  Final review: unanimous APPROVE
```
