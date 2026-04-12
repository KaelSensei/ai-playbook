# Step 2: Define Scope, User Stories, and Boundaries

## Prerequisites

- Step 1 completed (SPEC.md exists with frontmatter)

## Actions

1. **Parse the feature description** and identify:
   - What the user wants to achieve (the goal)
   - Who benefits from this feature (the actor)
   - What problem it solves (the motivation)

2. **Write user stories** in standard format. Prioritize by impact:
   - **P1 (Must have):** Core functionality that defines the feature.
   - **P2 (Should have):** Important but not blocking — feature works without it.
   - **P3 (Nice to have):** Enhancements that can be deferred.

   Format:

   ```
   As a <actor>, I want to <action>, so that <benefit>.
   ```

   Aim for 3-7 user stories. If you need more than 7, the feature may need to be split.

3. **Define scope boundaries** explicitly:
   - **In scope:** What this spec covers (be specific)
   - **Out of scope:** What this spec does NOT cover (be explicit about exclusions)
   - **Dependencies:** What existing features, services, or data this relies on
   - **Assumptions:** What you are assuming to be true (each assumption is a risk)

4. **Identify impacted layers:**
   - UI / Frontend
   - API / Backend
   - Database / Schema
   - External integrations
   - Configuration / Infrastructure

5. **Append to SPEC.md:**

```markdown
## User Stories

### P1 — Must Have

- As a <actor>, I want to <action>, so that <benefit>.

### P2 — Should Have

- ...

### P3 — Nice to Have

- ...

## Scope

### In Scope

- ...

### Out of Scope

- ...

### Dependencies

- ...

### Assumptions

- ...

## Impacted Layers

- [ ] UI / Frontend
- [ ] API / Backend
- [ ] Database / Schema
- [ ] External integrations
- [ ] Configuration / Infrastructure
```

6. **Update frontmatter:** Add `2` to `stepsCompleted`.

## Output

- User stories with priorities (P1/P2/P3)
- Explicit scope boundaries (in/out/dependencies/assumptions)
- Impacted layers checklist

## Completion Criteria

- [ ] At least 2 P1 user stories exist
- [ ] In-scope and out-of-scope sections are explicit
- [ ] Assumptions are documented (each is a risk to track)

## Next

→ Proceed to `spec-steps/step-03-criteria.md`
