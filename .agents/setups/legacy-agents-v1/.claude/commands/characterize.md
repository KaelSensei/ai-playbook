---
name: characterize
description: >
  Write characterization tests to pin down existing behavior. Mandatory before /refactor.
  characterization-tester orchestrates, dev-senior-b reviews. Produces a test net that protects
  against regressions.
argument-hint: '[module to characterize]'
---

# /characterize

Update `tasks/current_task.md`: status=CHARACTERIZE, module=$ARGUMENTS

**Prerequisite**: `/understand $ARGUMENTS` must have been run. If no mapping in `legacy-map.md` →
run `/understand` first.

---

## Phase 1 — Verify prerequisites

Read `legacy-map.md` for `$ARGUMENTS`. Verify that the module card exists and contains:

- Available seams
- Risk level

If missing → stop. Ask to run `/understand $ARGUMENTS` first.

---

## Phase 2 — Characterization plan

Invoke `characterization-tester` to establish a plan:

```
You are characterization-tester.
Load .claude/agents/characterization-tester.md.
Load project-architecture.md, legacy-map.md.
Load testing-patterns, legacy-patterns skills.

Module to characterize: $ARGUMENTS
Available seams: [from legacy-map.md]

Establish a characterization plan:
1. Which behaviors are most important to pin?
   (priority: most-used paths, most risky)
2. In what order should they be tackled?
3. Which seams should be used for each behavior?
4. What test data should be used? (real data if possible)

Produce: ordered list of behaviors to characterize
```

Present the plan to the user. **Gate**: _"Does this plan cover the critical behaviors?"_

---

## Phase 3 — Write the tests (one behavior at a time)

For each behavior in the plan:

### 3a. characterization-tester writes the intentionally wrong test

```
You are characterization-tester.

Behavior to characterize: [behavior]
Seam to use: [seam]

Step 1: write a test with assert == "???"
Step 2: run the test
Step 3: record the REAL result
Step 4: update the test with the real value
Step 5: add a comment explaining this behavior
```

### 3b. dev-senior-b reviews the characterization test

```
You are dev-senior-b.
Load legacy-patterns, testing-patterns, team--skill-review.

Review this characterization test:
[test]

Verify:
- Does the test document the real behavior (not the assumed one)?
- Is the assertion precise?
- Is the test independent (no global state)?
- Does the comment clearly explain what is documented?
- Would the test fail if the behavior changed?
```

Apply `team--skill-refine` if needed.

---

## Phase 4 — Net validation

When all behaviors in the plan are covered:

```bash
# Run all characterization tests
[runner] tests/characterization/

# All must pass — this is the baseline
```

---

## Phase 5 — Update legacy-map.md

Add to the "Pinned Behaviors" section of `legacy-map.md`:

```markdown
- [x] [behavior description] — [test_file:line] — [date]
```

Update `tasks/current_task.md`:

- Characterization Tests in place: [list]
- status=IDLE

```
Characterization complete: $ARGUMENTS
Pinned behaviors: [N]
Passing tests: [N/N]

Net in place. Ready for:
→ /refactor $ARGUMENTS   (if goal = refactoring)
→ /strangler $ARGUMENTS  (if goal = wrap with new code)
```
