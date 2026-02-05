# Gaps and Recommendations

This document lists what the AI Playbook could add to be more complete: **agent skills**, **missing
commands**, and small structural improvements.

---

## 1. Agent Skills (Missing)

**What they are:** Cursor supports **Agent Skills** — reusable expertise packaged in `SKILL.md`
files. Skills live in `.cursor/skills/<skill-name>/SKILL.md` (project) or `~/.cursor/skills/`
(user). The agent can discover and invoke them (e.g. `/skill-name`) for domain-specific tasks.

**Current state:** This repo has **no** `.cursor/skills/` folder. Rules and commands define
behavior, but skills would add portable “expert” behaviors that can load on demand.

**Recommended skills to add:**

| Skill name / path                      | Purpose                                                                                                                                                            |
| -------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `.cursor/skills/create-rule/`          | How to write and structure a Cursor rule (`.mdc`); when to use alwaysApply, how to reference other rules.                                                          |
| `.cursor/skills/create-command/`       | Deep expertise for creating a new command: structure, steps, integration with rules, where to put it (bootstrap/git/workflow/etc.). Complements `/create-command`. |
| `.cursor/skills/security-review/`      | Checklist and reasoning for security review before merge: no new untrusted network calls, no unsafe eval, dependency audit, secrets.                               |
| `.cursor/skills/conventional-commits/` | When to use feat/fix/docs/refactor/chore, how to write a good subject and body, how to reference issues.                                                           |
| `.cursor/skills/release-notes/`        | How to derive release notes from commits (conventional commits), what to include in GitHub release body, link to CHANGELOG.                                        |

**How to add:** Create `.cursor/skills/<name>/SKILL.md` with a short description, when to use the
skill, and step-by-step instructions (and optional scripts). See
[Cursor Agent Skills docs](https://cursor.com/docs/context/skills).

---

## 2. Commands That Could Be Added

| Command idea              | Category  | Purpose                                                                                                                                                               |
| ------------------------- | --------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `/test` or `/run-tests`   | workflow  | Run the project’s test suite (e.g. `npm test`, `pytest`), report results, fail the “task” if tests fail. Ensures tests are run before considering a feature/fix done. |
| `/review` or `/review-pr` | quality   | Review current branch diff (or a PR): security, style, docs, adherence to rules. Output a short checklist or comment.                                                 |
| `/changelog`              | docs      | Update `CHANGELOG.md` from recent commits (conventional commits). Complements `/release` (which creates the GitHub release).                                          |
| `/dependency-audit`       | quality   | Run dependency checks (e.g. `npm audit`, `pip audit`) and summarize vulnerabilities; suggest fixes.                                                                   |
| `/rollback` or `/revert`  | git       | Guide a safe revert: choose commit or range, create revert commit, no force-push to shared branches.                                                                  |
| `/sync-playbook`          | bootstrap | When using submodule/CLI: pull latest playbook, re-run install if needed, report what changed.                                                                        |

**Priority:** `/test` and `/review` would reinforce “don’t merge without tests and a quick review.”
`/changelog` pairs well with `/release`. `/dependency-audit` fits the security-first stance.

---

## 3. Small Structural Improvements

- **README or INSTALLATION:** Add one line that the playbook can optionally include **Cursor Agent
  Skills** in `.cursor/skills/` and link to this doc.
- **COMMANDS.md / USER_GUIDE.md:** When skills exist, add a short “Skills” section listing
  `.cursor/skills/*` and when the agent might use them.
- **COMMANDS_STRUCTURE.md:** If you add a `quality/` or `workflow/` command that runs tests, note
  that “run tests” is a first-class step in the workflow.

---

## 4. Summary

| Gap              | Suggestion                                                                                                             |
| ---------------- | ---------------------------------------------------------------------------------------------------------------------- |
| **Agent skills** | Add `.cursor/skills/` with create-rule, create-command, security-review, conventional-commits, release-notes.          |
| **Commands**     | Add `/test`, `/review` (or `/review-pr`), `/changelog`, optionally `/dependency-audit`, `/rollback`, `/sync-playbook`. |
| **Docs**         | Mention skills in README/INSTALLATION; add a “Skills” subsection where relevant.                                       |

Implementing skills and 2–3 of the high-value commands would make the playbook more complete and
consistent with its own rules (e.g. “run checks before commit”, “security review before merge”).
