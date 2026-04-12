# Step 1: Load Context and Create Branch

## Prerequisites

- `/spec <description>` was invoked with a feature description.

## Actions

1. **Load project context:**
   - Read: `README.md`, architecture docs, existing specs (if any)
   - Load rules from `.agents/rules/*.mdc` (or `.cursor/rules/*.mdc`)
   - Read the constitution (`constitution.mdc`) — you will check against it in Step 4

2. **Ensure a branch exists:**
   - Check current branch: `git branch --show-current`
   - If on `main`/`master`: create a branch using `git-branch-naming` skill (e.g.,
     `feature/user-auth` or `docs/spec-user-auth`)
   - If already on a feature branch: proceed

3. **Check for existing spec:**
   - Look for `SPEC.md` in project root or `specs/` directory
   - If found: read it and check `stepsCompleted` in frontmatter
   - If resuming: skip to the next incomplete step
   - If starting fresh: proceed to create new SPEC.md

4. **Initialize SPEC.md** with frontmatter:

```markdown
---
feature: <feature name derived from description>
command: /spec
stepsCompleted: [1]
createdAt: <today's date>
lastUpdated: <today's date>
---

# Spec: <Feature Name>

> <original description from the user>
```

## Output

- Branch created (if needed)
- `SPEC.md` initialized with frontmatter and feature description

## Completion Criteria

- [ ] Project context is loaded
- [ ] Working on a non-main branch
- [ ] SPEC.md exists with frontmatter

## Next

→ Proceed to `spec-steps/step-02-scope.md`
