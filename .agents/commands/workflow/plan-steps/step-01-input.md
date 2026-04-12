# Step 1: Load Spec/Description and Project Architecture

## Prerequisites

- `/plan` was invoked, optionally with a spec path or inline description.

## Actions

1. **Locate the input:**
   - If a file path was provided: read that file as the spec
   - If `SPEC.md` exists in project root: use it as input
   - If an inline description was provided: use it directly (lighter plan, no spec reference)
   - If nothing found: **stop and ask** — "No spec found. Run `/spec` first or provide a
     description."

2. **Load project architecture:**
   - Read: `README.md`, architecture docs, existing PLAN.md (if resuming)
   - Identify the tech stack (languages, frameworks, databases, infrastructure)
   - Map the existing codebase structure (key directories, entry points, data flow)
   - Load rules from `.agents/rules/*.mdc` (especially `constitution.mdc`, `technical-stack.mdc`)

3. **Check for existing plan:**
   - Look for `PLAN.md` in project root
   - If found: read frontmatter and check `stepsCompleted`
   - If resuming: skip to the next incomplete step
   - If starting fresh: proceed

4. **Initialize PLAN.md** with frontmatter:

```markdown
---
feature: <feature name from spec or description>
spec: <path to SPEC.md, or "inline">
command: /plan
stepsCompleted: [1]
createdAt: <today's date>
lastUpdated: <today's date>
---

# Plan: <Feature Name>

> Source: <SPEC.md path or inline description>

## Project Context

- **Tech stack:** <languages, frameworks>
- **Architecture:** <pattern — e.g., hexagonal, MVC, monolith, microservices>
- **Database:** <type and ORM if any>
- **Key constraints:** <from constitution and tech-stack rules>
```

## Output

- Input source identified (spec file or inline description)
- Project architecture documented
- PLAN.md initialized with context

## Completion Criteria

- [ ] Input source is clear (spec or description)
- [ ] Tech stack and architecture are documented
- [ ] PLAN.md exists with frontmatter

## Next

→ Proceed to `plan-steps/step-02-design.md`
