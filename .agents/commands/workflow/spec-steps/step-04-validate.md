# Step 4: Constitution Check, Resolve Ambiguities, Finalize

## Prerequisites

- Steps 1-3 completed (SPEC.md has user stories, scope, acceptance criteria, edge cases)

## Actions

### 4.1 Constitution Check

Verify the planned feature against each article of the constitution (`constitution.mdc`):

1. **Article 1 (Security First)** — Does the feature introduce security risks? Are they documented?
2. **Article 2 (Explicit Over Implicit)** — Is the spec clear enough that implementation won't
   require guessing?
3. **Article 4 (Spec Before Implementation)** — Is this spec complete enough to begin planning?
4. **Article 5 (No Scope Creep)** — Is the scope bounded? Could this grow unexpectedly?
5. **Article 8 (Simplicity)** — Is this the simplest approach to solving the problem?
6. **Article 9 (Project Boundaries)** — Does this respect the tech stack and architecture?

For each violation: `[CONSTITUTION VIOLATION] Article N: <description>` Violations are **blockers**
— they must be resolved before the spec is finalized.

### 4.2 Resolve Open Questions

1. Check for any `[NEEDS CLARIFICATION]` markers in the spec.
2. **If markers exist:** Present them to the user and STOP. Wait for answers.
3. **If all resolved:** Remove the markers and update the relevant sections.

### 4.3 Self-Review Checklist

Run through this checklist before finalizing:

- [ ] **Completeness** — Are all P1 stories specified with acceptance criteria?
- [ ] **Testability** — Can each acceptance criterion be verified (manually or with a test)?
- [ ] **Feasibility** — Can this be built with the project's current tech stack?
- [ ] **Independence** — Can this feature be developed without blocking or being blocked by other
      work?
- [ ] **No implementation details** — Does the spec describe WHAT, not HOW? (HOW belongs in `/plan`)
- [ ] **No open ambiguities** — Are all `[NEEDS CLARIFICATION]` markers resolved?

### 4.4 Finalize

1. **Update frontmatter:** Add `4` to `stepsCompleted`, update `lastUpdated`.
2. **Add status to SPEC.md:**

```markdown
## Status

**READY FOR PLANNING** — This spec is complete and approved. Next step: Run `/plan` to create the
implementation plan.
```

3. **Commit and push:**

```bash
git add SPEC.md
git commit -m "docs: add spec for <feature name>"
git push origin $(git branch --show-current)
```

4. **Tell the user:**
   - Summary of what was specified
   - Number of user stories (P1/P2/P3)
   - Any security implications flagged
   - Suggest: "Run `/plan` to create the implementation plan, or `/ready-check` to verify
     readiness."

## Output

- Finalized SPEC.md with all sections complete
- Constitution check passed (no violations)
- All ambiguities resolved
- Committed and pushed

## Completion Criteria

- [ ] Constitution check passed — no violations
- [ ] Self-review checklist passed — all items checked
- [ ] No `[NEEDS CLARIFICATION]` markers remain
- [ ] SPEC.md committed and pushed
- [ ] User informed of next steps
