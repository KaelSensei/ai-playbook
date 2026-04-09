---
name: spec
description: >
  Spec pipeline: EXPLORE → DRAFT → parallel agent review → SYNTHESIZE → REVISE loop → PRESENT. No
  code writing. Unanimous APPROVE required. Saves approved spec to .claude/specs/.
argument-hint: '[feature description]'
---

# /spec

Per image 6: Explore → Draft → Parallel Review → Synthesize → Revise (loop) → Present

Update `tasks/current_task.md`: status=SPEC, task=$ARGUMENTS

---

## Phase 1 — EXPLORE (gather context)

Load `team--skill-lookup`.

Invoke `spec-writer` in explore mode:

```
You are spec-writer.
Load .claude/agents/spec-writer.md.
Load context docs: project-architecture.md, data-architecture.md, constants.md.
Load team--skill-lookup skill.

Exploration mode — no writing yet.

Check staleness of all context docs.
Explore the codebase to understand:
  1. Existing patterns and conventions relevant to: $ARGUMENTS
  2. Code this feature will touch or depend on
  3. External protocols or standards involved

Produce: exploration-findings.md with sections:
  - Context Docs Status (FRESH/STALE per doc)
  - Codebase Findings (relevant files, patterns, interfaces)
  - External Research (relevant EIPs, protocol docs)
  - Discrepancies (doc vs codebase mismatches)
  - Open Questions (needs user input before drafting)
```

If open questions require user input → ask before proceeding to Phase 2.

---

## Phase 2 — DRAFT (write initial spec)

Invoke `spec-writer` with exploration findings:

```
You are spec-writer.
Load .claude/agents/spec-writer.md.
Load context docs: project-architecture.md, data-architecture.md.
Load solidity-patterns skill.

Using these exploration findings:
[exploration-findings.md content]

Draft a complete technical specification for: $ARGUMENTS

Required sections (no skipping):
  Summary, Motivation, State Variables, Interface (Solidity + NatSpec),
  Events, Access Control Matrix, State Transitions, Invariants,
  Edge Cases, Out of Scope, Test Plan (unit/integration/fork/invariant),
  Security Considerations.

Use RFC 2119 language throughout (MUST, MUST NOT, MAY).
If the test plan is empty, the spec is incomplete — do not submit.
```

Present draft to user. **Gate**: _"Does this capture what you want? Any corrections before the
review pass?"_ Do not proceed until confirmed.

---

## Phase 3 — PARALLEL REVIEW (N agents simultaneously)

Load `team--skill-review` for all agents.

Read the `## Agent Team` table in `CLAUDE.md`. Spawn ALL agents from the table simultaneously —
except `spec-writer`.

**Prompt for each agent:**

```
You are [AGENT_PERSONA].
Load .claude/agents/[agent].md.
Load context docs: [per Agent Team table for this agent].
Load skills: [per Agent Team table for this agent].
Load team--skill-review skill.

Review-only mode — no code writing.

Review this specification from your discipline's lens only.
All agents from the Agent Team are reviewing simultaneously.

[full spec text]

Follow the team--skill-review output format exactly.
Return: APPROVE | APPROVE_WITH_CHANGES | REQUEST_REDESIGN
```

Wait for all agents to return before proceeding.

---

## Phase 4 — SYNTHESIZE (collect verdicts, find gaps)

Collect all verdicts. Apply merge rules from `team--skill-review`.

Display:

```
Review pass [N]:
  smart-contract-engineer : [verdict]
  infra-engineer          : [verdict]
  devops-engineer         : [verdict]
  frontend-engineer       : [verdict]
  backend-engineer        : [verdict]
  architect               : [verdict]

Overall: [merged verdict]
```

---

## Phase 5 — REVISE (loop if not unanimous APPROVE)

Load `team--skill-refine`.

Apply refinement protocol:

**If any `REQUEST_REDESIGN`:**

- Hard stop. Quote the blocker. Escalate to user.
- Do not proceed until user decides: revise or explicitly accept risk.

**If any `APPROVE_WITH_CHANGES`:**

- Collect all improvements. Prioritize per `team--skill-refine`.
- Route fixes to `spec-writer`.
- Revise spec.
- Loop back to Phase 3.
- Maximum 3 loops before escalating to user.

**If unanimous `APPROVE`:**

- Proceed to Phase 7.

---

## Phase 7 — PRESENT to user

Save approved spec to: `.claude/specs/[feature-slug].md` Update `tasks/current_task.md`:

- status=IDLE
- Active Spec: .claude/specs/[feature-slug].md

Present:

```
✅ Spec approved unanimously

  Agents: [list]
  Review loops: [N]
  Saved: .claude/specs/[feature-slug].md

Ready for: /implement [feature-slug]
```
