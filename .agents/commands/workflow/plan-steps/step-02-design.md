# Step 2: Technical Design — Approach, Layers, Dependencies

## Prerequisites

- Step 1 completed (PLAN.md exists with project context)
- Spec or description is loaded

## Actions

1. **Choose the technical approach:**
   - Review the user stories / requirements from the spec (or description)
   - Identify 1-2 viable approaches
   - Pick the simplest one that satisfies all P1 requirements (Article 8: Simplicity)
   - If multiple approaches are equally viable, note both and recommend one with reasoning

2. **Map changes to architecture layers:**

   For each impacted layer, describe what changes:

   ```markdown
   ## Technical Design

   ### Approach

   <1-3 paragraphs describing the chosen approach and why>

   ### Changes by Layer

   #### UI / Frontend

   - <component or page changes>
   - <new components needed>

   #### API / Backend

   - <new endpoints or modified routes>
   - <business logic changes>

   #### Database / Schema

   - <new tables, columns, or migrations>
   - <index changes>

   #### External Integrations

   - <new APIs, webhooks, or services>

   #### Configuration

   - <new env vars, feature flags, or config changes>
   ```

   Omit layers that are not impacted.

3. **Identify new dependencies:**
   - List any new packages, services, or tools needed
   - For each: justify why it's needed and note alternatives considered
   - If no new dependencies: state "No new dependencies required" (this is preferred)

4. **Document key decisions** as lightweight ADRs (Architecture Decision Records):

   ```markdown
   ### Key Decisions

   **Decision 1: <title>**

   - Context: <why this decision was needed>
   - Decision: <what was decided>
   - Alternatives considered: <what else was considered>
   - Rationale: <why this option was chosen>
   ```

   Only document decisions that aren't obvious from the approach.

5. **Append to PLAN.md** and update frontmatter (add `2` to `stepsCompleted`).

## Output

- Technical approach with rationale
- Changes mapped to architecture layers
- New dependencies (if any) with justification
- Key decisions documented

## Completion Criteria

- [ ] Approach is documented with clear rationale
- [ ] All impacted layers have specific changes listed
- [ ] New dependencies are justified (or explicitly stated as none)
- [ ] Key decisions are recorded

## Next

→ Proceed to `plan-steps/step-03-tasks.md`
