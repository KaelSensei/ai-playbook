# Step 4: Constitution Check, Risk Assessment, Finalize

## Prerequisites

- Steps 1-3 completed (PLAN.md has context, design, and task breakdown)

## Actions

### 4.1 Constitution Check

Verify the plan against each article of the constitution (`constitution.mdc`):

1. **Article 1 (Security First)** — Are security implications addressed in the design? Do tasks
   include security validation steps?
2. **Article 2 (Explicit Over Implicit)** — Is the technical approach clear enough that an AI agent
   can implement each task without guessing?
3. **Article 3 (Branch Discipline)** — Will the implementation follow branch/commit conventions?
4. **Article 5 (No Scope Creep)** — Does the task list stay within the spec's defined scope?
5. **Article 6 (Test What Matters)** — Does the plan include testing tasks for critical paths?
6. **Article 8 (Simplicity)** — Is this the simplest viable design? Could any task be eliminated?
7. **Article 9 (Project Boundaries)** — Does the design respect the tech stack and architecture?

For each violation: `[CONSTITUTION VIOLATION] Article N: <description>` Violations are **blockers**
— they must be resolved before the plan is finalized.

### 4.2 Risk Assessment

Identify and document risks:

```markdown
## Risks

| Risk                  | Impact          | Likelihood      | Mitigation                 |
| --------------------- | --------------- | --------------- | -------------------------- |
| <what could go wrong> | High/Medium/Low | High/Medium/Low | <how to prevent or handle> |
```

Common risks to consider:

- Schema migrations on production data
- Breaking changes to existing APIs
- Performance impact on critical paths
- Third-party service reliability
- Complex merge conflicts with parallel work

### 4.3 Self-Review Checklist

- [ ] **Spec alignment** — Does the plan implement all P1 user stories from the spec?
- [ ] **No gold-plating** — Does the plan avoid implementing things not in the spec?
- [ ] **Dependency order** — Can tasks be executed in the listed order without blockers?
- [ ] **Testability** — Are there testing tasks for critical functionality?
- [ ] **Reversibility** — Can the implementation be rolled back if something goes wrong?
- [ ] **Constitution compliance** — No violations found or all violations resolved?

### 4.4 Finalize

1. **Update frontmatter:** Add `4` to `stepsCompleted`, update `lastUpdated`.
2. **Add status to PLAN.md:**

```markdown
## Status

**READY FOR IMPLEMENTATION** — This plan is complete and approved. Next step: Run `/feature` to
begin implementing tasks, or `/ready-check` to verify readiness.

### Implementation Order

1. Start with Phase 1 tasks (foundation)
2. Proceed through phases sequentially
3. Tasks marked [P] within a phase can run in parallel
4. Run `/ready-check` before starting if confidence is low
```

3. **Commit and push:**

```bash
git add PLAN.md
git commit -m "docs: add implementation plan for <feature name>"
git push origin $(git branch --show-current)
```

4. **Tell the user:**
   - Summary of the approach
   - Total tasks (P1/P2/P3 breakdown)
   - Key risks identified
   - Suggest: "Run `/feature` to start implementation, beginning with Phase 1 tasks."

## Output

- Constitution check passed
- Risks documented with mitigations
- PLAN.md finalized and committed
- User informed of next steps

## Completion Criteria

- [ ] Constitution check passed — no unresolved violations
- [ ] Self-review checklist passed
- [ ] Risks are documented with mitigations
- [ ] PLAN.md committed and pushed
- [ ] User informed of implementation order
