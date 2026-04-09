---
name: review
description: >
  Parallel code review. All agents from the Agent Team review simultaneously from their discipline's
  lens. Read-only — no code writing. Merged verdict presented to user. Use on PRs, diffs, or any
  code before deployment.
argument-hint: '[files, diff, or PR number — optional]'
---

# /review

Update `tasks/current_task.md`: status=REVIEW

---

## Step 1 — Determine input

| Argument    | Action                              |
| ----------- | ----------------------------------- |
| PR number   | Run `gh pr diff [N]` to get diff    |
| File paths  | Read those files directly           |
| No argument | Run `git diff HEAD~1` (last commit) |
| "staged"    | Run `git diff --cached`             |

If diff touches `.sol` files → also run:

```bash
forge build       # must compile cleanly
forge test -vvv   # must pass before review proceeds
```

If build or tests fail → stop. Report the failure. Do not review broken code.

---

## Step 2 — Spawn all agents simultaneously

Load `team--skill-review` for all agents. Read the `## Agent Team` table in `CLAUDE.md`. Spawn ALL
agents simultaneously — no exceptions, no skipping.

**Prompt for each agent:**

```
You are [AGENT_PERSONA]. Review-only mode — no code writing.
Load .claude/agents/[agent].md.
Load context docs: [per Agent Team table for this agent].
Load skills: [per Agent Team table for this agent].
Load team--skill-review skill.

Review the following code from your discipline's lens only.
Other agents are reviewing simultaneously from theirs.

[diff / code]

Follow team--skill-review output format exactly.
Return: APPROVE | APPROVE_WITH_CHANGES | REQUEST_REDESIGN
```

---

## Step 3 — Merge verdicts

Collect all verdicts. Apply merge rules from `team--skill-review`.

Present unified report:

```markdown
# Code Review

## Verdicts

| Agent                   | Verdict   |
| ----------------------- | --------- |
| smart-contract-engineer | [verdict] |
| infra-engineer          | [verdict] |
| devops-engineer         | [verdict] |
| frontend-engineer       | [verdict] |
| backend-engineer        | [verdict] |
| architect               | [verdict] |

**Overall: APPROVE | APPROVE_WITH_CHANGES | REQUEST_REDESIGN**

---

## 🔴 Blockers

[Deduplicated. If flagged by multiple agents: "(flagged by N agents)"]

- **[location]**: [issue] — [why it matters] — [required fix]

## 🟡 Improvements

[Deduplicated.]

- **[location]**: [issue] — [suggestion]

## 🔵 Nits

[Deduplicated.]

- [note]
```

---

## Step 4 — Smart contract gate

If diff touches any `.sol` file, `smart-contract-engineer` MUST explicitly state:

- All 10 checklist items checked
- No critical vulnerabilities found (or: exact vulnerabilities found)
- `forge test` output: pass/fail

If `smart-contract-engineer` returns `REQUEST_REDESIGN` on a `.sol` file → overall verdict is
`REQUEST_REDESIGN` regardless of other agents.

---

## Step 5 — Large PR split (optional)

If diff > 500 lines or spans > 3 domains:

Offer to split into focused sub-reviews:

- Security-only: `smart-contract-engineer` + `architect`
- Ops-only: `devops-engineer` + `infra-engineer`
- Data-only: `backend-engineer`
- Frontend-only: `frontend-engineer`

Each sub-review runs the same parallel pattern on its slice. Merge all sub-review verdicts into one
final report.

---

Update `tasks/current_task.md`: status=IDLE
