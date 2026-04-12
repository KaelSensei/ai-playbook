# Step 3: Break Down into Ordered, Implementable Tasks

## Prerequisites

- Step 2 completed (technical design documented in PLAN.md)

## Actions

1. **Convert the technical design into a task list.**

   Each task must be:
   - **Independently implementable** — an AI agent can execute it without reading other tasks
   - **Small enough** — completable in a single `/feature` or `/fix` invocation
   - **Ordered by dependency** — tasks that depend on others come after them
   - **Tied to a user story** — traceable back to a P1/P2/P3 requirement

2. **Organize tasks into phases:**

   ```markdown
   ## Task Breakdown

   ### Phase 1: Foundation (must complete first)

   - [ ] T001 [P1] <description> — `<file path(s)>`
   - [ ] T002 [P1] <description> — `<file path(s)>`

   ### Phase 2: Core Implementation

   - [ ] T003 [P1] <description> — `<file path(s)>`
   - [ ] T004 [P] [P1] <description> — `<file path(s)>`
   - [ ] T005 [P] [P2] <description> — `<file path(s)>`

   ### Phase 3: Integration & Polish

   - [ ] T006 [P2] <description> — `<file path(s)>`
   - [ ] T007 [P3] <description> — `<file path(s)>`

   ### Phase 4: Testing & Documentation

   - [ ] T008 [P1] Write tests for core functionality
   - [ ] T009 [P1] Update documentation
   ```

   **Task format:**
   - `T001` — Sequential task ID
   - `[P]` — (Optional) Marks tasks that can run in parallel with adjacent `[P]` tasks
   - `[P1]` / `[P2]` / `[P3]` — Priority tier (from user stories)
   - Description — What to do (imperative, specific)
   - File path(s) — Which files will be created or modified

3. **Define task dependencies** where order matters:

   ```markdown
   ### Dependencies

   - T003 depends on T001, T002 (schema must exist before API)
   - T006 depends on T003, T004 (integration needs core features)
   ```

4. **Estimate scope:**

   ```markdown
   ### Scope Summary

   - **Total tasks:** <count>
   - **P1 tasks:** <count> (must complete)
   - **P2 tasks:** <count> (should complete)
   - **P3 tasks:** <count> (if time permits)
   - **Estimated files changed:** <count>
   - **New files:** <count>
   ```

5. **Append to PLAN.md** and update frontmatter (add `3` to `stepsCompleted`).

## Output

- Phased task list with IDs, priorities, and file paths
- Dependency map
- Scope summary

## Completion Criteria

- [ ] Every P1 user story has at least one task
- [ ] Tasks are ordered by dependency (no task references unfinished prerequisites)
- [ ] Each task specifies which file(s) it touches
- [ ] Parallelizable tasks are marked with `[P]`

## Next

→ Proceed to `plan-steps/step-04-review.md`
