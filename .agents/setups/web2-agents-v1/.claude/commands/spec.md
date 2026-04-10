---
name: spec
description: >
  Produce a technical spec with an exhaustive test list from the stories. The test list is the
  central deliverable — it drives the whole TDD /build. EXPLORE → DRAFT → parallel review → loop →
  approved spec.
argument-hint: '[story slug or description]'
---

# /spec

Update `tasks/current_task.md`: status=SPEC, task=$ARGUMENTS

---

## Phase 1 — EXPLORE

Load `team--skill-lookup`.

Invoke `spec-writer` in exploration mode:

```
You are spec-writer.
Load project-architecture.md, data-architecture.md.
Load team--skill-lookup.

Check the freshness of the docs.

Explore the codebase for:
1. Existing patterns related to: $ARGUMENTS
2. The interfaces and modules this feature will touch
3. Existing DB migrations and the current schema
4. Existing tests to understand conventions

Produce: exploration-findings with doc status, codebase findings,
any divergences, and open questions.
```

If there are open questions → ask the user before drafting.

---

## Phase 2 — DRAFT

Invoke `spec-writer` with the findings:

```
You are spec-writer.
Load project-architecture.md, data-architecture.md.
Load clean-code, testing-patterns.

Exploration findings: [findings]
Stories and ACs: [contents of .claude/specs/$ARGUMENTS-story.md if it exists]

Produce a full technical spec for: $ARGUMENTS

Mandatory sections:
- Summary
- Acceptance Criteria (taken from the stories if /story was run)
- Test List (ordered simplest first — THIS IS THE MAIN DELIVERABLE)
  → Happy Path, Edge Cases, Error Cases, Integration
- Technical Interface (signatures only)
- Constraints (perf, security, data)
- Out of Scope

Rule: if the test list is empty → the spec is incomplete.
Use RFC 2119 (MUST, MUST NOT, MAY).
```

Show the draft to the user. **Gate**: _"Is the test list complete? Any missing ACs?"_ Do not
continue without confirmation.

---

## Phase 3 — PARALLEL REVIEW

Load `team--skill-review` for all agents.

Spawn EVERY agent from the `## Agent Team` table in `CLAUDE.md` at the same time — except
`spec-writer`:

```
You are [AGENT_PERSONA].
Load .claude/agents/[agent].md.
Load the context docs: [per Agent Team table].
Load the skills: [per Agent Team table].
Load team--skill-review.

Review mode only — no code writing.

Review this technical spec from your disciplinary angle.
All agents are reviewing in parallel.

[full spec contents]

Pay special attention to the TEST LIST:
- Are all ACs covered by at least one test?
- Are the edge cases from your discipline in the test list?
- Are there missing behaviors?

Follow the team--skill-review format exactly.
```

---

## Phase 4 — SYNTHESIS

```
Loop [N]:
  spec-writer        : [verdict]
  architect          : [verdict]
  tech-lead          : [verdict]
  dev-senior-a       : [verdict]
  dev-senior-b       : [verdict]
  qa-engineer        : [verdict]
  security-reviewer  : [verdict]
  data-engineer      : [verdict]
  devops-engineer    : [verdict]

Global verdict: [merged]
```

---

## Phase 5 — ITERATE if not unanimous

Load `team--skill-refine`. `REQUEST_REDESIGN` → stop, escalate to user. `APPROVE_WITH_CHANGES` →
`spec-writer` fixes, re-review, max 3 loops.

---

## Phase 6 — SAVE

Save to `.claude/specs/[slug].md`. Update `tasks/current_task.md`:

- status=IDLE
- Active Spec: .claude/specs/[slug].md

```
✅ Spec unanimously approved
  Agents: [list]
  Loops: [N]
  Saved to: .claude/specs/[slug].md
  Test List: [N items]

Ready for: /build [slug]
```
