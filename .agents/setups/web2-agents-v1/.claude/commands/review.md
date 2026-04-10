---
name: review
description: >
  Parallel review by all agents. Read-only. Merged verdict. For any diff before merging or
  deploying.
argument-hint: '[files, PR number, or empty for latest commit]'
---

# /review

Update `tasks/current_task.md`: status=REVIEW

---

## Step 1 — Determine the input

| Argument   | Action              |
| ---------- | ------------------- |
| PR number  | `gh pr diff [N]`    |
| File paths | Read those files    |
| `staged`   | `git diff --cached` |
| None       | `git diff HEAD~1`   |

Before running: verify the tests pass.

```bash
[runner]  # all tests must pass
```

If tests fail → stop. Report the failure. Do not review broken code.

---

## Step 2 — Spawn all agents simultaneously

Load `team--skill-review` for all agents. Read the `## Agent Team` table in `CLAUDE.md`. Spawn EVERY
agent at the same time:

```
You are [AGENT_PERSONA]. Review mode only — no code writing.
Load context docs and skills per the Agent Team table.
Load team--skill-review.

Review the following code from your disciplinary angle only.
All agents are reviewing in parallel.

[diff / code]

Follow the team--skill-review format exactly.
```

---

## Step 3 — Merge the verdicts

Collect all verdicts. Apply the merge rules from `team--skill-review`.

```markdown
# Code Review

## Verdicts

| Agent             | Verdict   |
| ----------------- | --------- |
| product-owner     | [verdict] |
| ux-designer       | [verdict] |
| tech-lead         | [verdict] |
| architect         | [verdict] |
| dev-senior-a      | [verdict] |
| dev-senior-b      | [verdict] |
| qa-engineer       | [verdict] |
| security-reviewer | [verdict] |
| data-engineer     | [verdict] |
| devops-engineer   | [verdict] |

**Global verdict: APPROVE | APPROVE_WITH_CHANGES | REQUEST_REDESIGN**

---

## 🔴 Blockers

[Deduped. If flagged by multiple agents: "(flagged by N agents)"]

## 🟡 Improvements

[Deduped]

## 🔵 Nits

[Deduped]
```

---

## Step 4 — Security gate

If the diff touches auth, sessions, user data, or public endpoints → `security-reviewer` MUST
explicitly confirm:

- Full OWASP checklist
- No critical vulnerability
- Rate limiting present if applicable

If `security-reviewer` returns `REQUEST_REDESIGN` on these areas → global verdict =
`REQUEST_REDESIGN` with no exception.

Update `tasks/current_task.md`: status=IDLE
