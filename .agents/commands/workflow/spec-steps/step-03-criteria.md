# Step 3: Write Acceptance Criteria and Edge Cases

## Prerequisites

- Step 2 completed (user stories and scope defined in SPEC.md)

## Actions

1. **Write acceptance criteria** for each P1 user story using Given/When/Then format:

   ```
   Given <precondition>
   When <action>
   Then <expected result>
   ```

   Each P1 story should have 2-5 acceptance criteria. P2 stories need at least 1.

2. **Identify edge cases** — things that could go wrong or behave unexpectedly:
   - Empty / null inputs
   - Boundary values (zero, max, off-by-one)
   - Concurrent operations (two users, two tabs)
   - Network failures / timeouts
   - Permission / authorization edge cases
   - Data migration concerns (existing data vs new schema)

   For each edge case, define the expected behavior.

3. **Identify security implications** (lightweight, not full review):
   - Does this feature handle user input? → Validation needed
   - Does it add new endpoints? → Auth needed
   - Does it store sensitive data? → Encryption/masking needed
   - Does it add dependencies? → Audit needed

4. **Mark ambiguities** — for anything that cannot be determined from the description:
   - Write: `[NEEDS CLARIFICATION] <what is ambiguous and why>`
   - Maximum 3 markers — only flag high-impact ambiguities
   - These MUST be resolved before the spec is considered complete

5. **Append to SPEC.md:**

```markdown
## Acceptance Criteria

### US1: <user story summary>

- Given <precondition>, When <action>, Then <expected result>
- Given <precondition>, When <action>, Then <expected result>

### US2: <user story summary>

- ...

## Edge Cases

| Scenario    | Expected Behavior    |
| ----------- | -------------------- |
| <edge case> | <what should happen> |

## Security Implications

- [ ] User input validation required
- [ ] New endpoints need authentication
- [ ] Sensitive data handling
- [ ] Dependency audit needed

## Open Questions

- [NEEDS CLARIFICATION] <if any>
```

6. **Update frontmatter:** Add `3` to `stepsCompleted`.

## Output

- Acceptance criteria in Given/When/Then format for all P1 stories
- Edge case table with expected behaviors
- Security implications checklist
- Open questions with `[NEEDS CLARIFICATION]` markers (if any)

## Completion Criteria

- [ ] Every P1 user story has at least 2 acceptance criteria
- [ ] At least 3 edge cases are identified
- [ ] Security implications are documented
- [ ] Ambiguities are marked (not guessed)

## Next

→ Proceed to `spec-steps/step-04-validate.md`
