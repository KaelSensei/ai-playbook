---
name: review
description: >
  Parallel legacy-aware review. All agents review simultaneously. Special check: is the legacy
  behavior preserved? Are characterization tests passing?
argument-hint: '[files, PR number, or empty for last commit]'
---

# /review

Update `tasks/current_task.md`: status=REVIEW

---

## Step 1 — Determine the input and verify tests

| Argument  | Action              |
| --------- | ------------------- |
| PR number | `gh pr diff [N]`    |
| Files     | Read those files    |
| `staged`  | `git diff --cached` |
| None      | `git diff HEAD~1`   |

**Critical check before review:**

```bash
[runner]  # all tests must pass

# If characterization tests exist for the touched modules:
[runner] tests/characterization/  # ALL must pass
```

If any characterization tests fail → stop. A red characterization test = changed behavior = possible
regression. Do not proceed without analysis.

---

## Step 2 — Identify the type of change

Read the diff. Categorize:

| Type                 | What changes               | Review mode                      |
| -------------------- | -------------------------- | -------------------------------- |
| Pure refactoring     | Structure without behavior | Verify behavior preserved        |
| New code (Strangler) | Addition around the legacy | Verify that the legacy is intact |
| Bug fix              | Corrected behavior         | Verify the regression test       |
| New feature          | New behavior               | Standard review                  |

Communicate the identified type to the agents in their prompt.

---

## Step 3 — Spawn all agents in parallel

Load `team--skill-review` for all agents. Spawn ALL agents from the `## Agent Team` table
simultaneously:

```
You are [AGENT_PERSONA].
Load context docs and skills per Agent Team table.
Load team--skill-review.

Identified change type: [type]
Module(s) involved: [from legacy-map.md if mapped]
Characterization tests in place: [yes/no/list]

Review from your disciplinary angle.

Legacy-specific points of attention:
- If refactoring: is the behavior strictly preserved?
- If Strangler: is the legacy unchanged?
- If bug fix: is there a regression test?
- If feature: are there characterization tests on the legacy being touched?

[diff / code]

Follow the team--skill-review format exactly.
```

---

## Step 4 — Legacy security gate

On legacy code, the most common vulnerabilities are:

- SQL injection from string concatenation
- Hardcoded secrets discovered during refactoring
- Obsolete dependencies exposed

`security-reviewer` must confirm:

- OWASP checklist + legacy-specific checklist complete
- No secret discovered and left in place
- No injection introduced or exposed

---

## Step 5 — Merge verdicts

```markdown
# Code Review (Legacy-Aware)

## Verdicts

| Agent                   | Verdict   |
| ----------------------- | --------- |
| legacy-analyst          | [verdict] |
| characterization-tester | [verdict] |
| refactoring-guide       | [verdict] |
| dev-senior-a            | [verdict] |
| dev-senior-b            | [verdict] |
| tech-lead               | [verdict] |
| architect               | [verdict] |
| security-reviewer       | [verdict] |
| data-engineer           | [verdict] |

**Global verdict: APPROVE | APPROVE_WITH_CHANGES | REQUEST_REDESIGN**

## Characterization Tests

- In place: yes / no
- All passing: yes / no

## Blockers

## Improvements

## Nits
```

Update `tasks/current_task.md`: status=IDLE
