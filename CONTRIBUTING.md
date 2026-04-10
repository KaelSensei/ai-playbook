# Contributing

Thanks for helping improve the AI Playbook. This document is short on purpose — read it once and you
should have everything you need.

If anything here is unclear or out of date, open an issue or PR to fix it.

---

## Ground rules

1. **Never commit directly to `main`.** Always work on a branch and open a PR.
2. **One concern per PR.** A PR that adds a rule, fixes a typo, and renames a skill is three PRs.
3. **No secrets, credentials, or `.env` files.** The CI check and pre-commit hooks will not catch
   everything — you are responsible.
4. **Keep it tool-agnostic.** This playbook is consumed by Claude Code, Cursor, and other agents. Do
   not hard-code paths, model names, or features that only work in one tool unless the change is
   explicitly scoped to a setup that targets that tool.

---

## What you can contribute

The playbook has four extension points. Pick the right one for what you want to add.

| I want to…                                        | Where it goes                  | Example                           |
| ------------------------------------------------- | ------------------------------ | --------------------------------- |
| Enforce a behavior across every conversation      | `.agents/rules/*.mdc`          | `security.mdc`, `ethskills.mdc`   |
| Add a new slash workflow (`/something`)           | `.agents/commands/<category>/` | `.agents/commands/git/release.md` |
| Package domain expertise the AI loads on demand   | `.agents/skills/<skill-name>/` | `.agents/skills/security-review/` |
| Add a pre-configured multi-agent team for a stack | `.agents/setups/<setup-name>/` | `.agents/setups/dev-squad-v2/`    |

See [CONCEPTS.md](CONCEPTS.md) for the difference between rules, commands, and skills.

**Before you start:** check that what you want to add does not already exist, and that it is generic
enough to be reused. Project-specific rules belong in the project, not here.

---

## Development workflow

```bash
# 1. Fork and clone
git clone https://github.com/<your-username>/ai-playbook.git
cd ai-playbook

# 2. Install
npm install
npm ci --prefix cli

# 3. Branch
git checkout -b <type>/<short-description>
# types: feature, fix, docs, refactor, chore, ci

# 4. Make your changes

# 5. Run the same checks CI will run
npm run format:check
npm run lint

# 6. If format:check fails, auto-fix:
npm run format

# 7. Commit (conventional commits)
git commit -m "feat: add skill for postgres migrations"

# 8. Push and open a PR against main
git push -u origin <your-branch>
gh pr create --base main
```

---

## Branch naming

Lowercase, hyphens only, short and descriptive.

| Type     | Pattern                        | Example                            |
| -------- | ------------------------------ | ---------------------------------- |
| Feature  | `feature/<short-description>`  | `feature/postgres-migration-skill` |
| Bug fix  | `fix/<short-description>`      | `fix/broken-cli-cursor-reference`  |
| Refactor | `refactor/<short-description>` | `refactor/extract-skill-loader`    |
| Docs     | `docs/<short-description>`     | `docs/update-concepts`             |
| Chore    | `chore/<short-description>`    | `chore/bump-prettier`              |
| CI       | `ci/<short-description>`       | `ci/add-cli-build-step`            |

---

## Commit messages

Follow [Conventional Commits](https://www.conventionalcommits.org/). The prefix determines the type
of change and is enforced socially (not by a hook).

| Prefix      | Meaning                                     |
| ----------- | ------------------------------------------- |
| `feat:`     | New feature, rule, command, skill, or setup |
| `fix:`      | Bug fix                                     |
| `docs:`     | Documentation only                          |
| `refactor:` | No behavior change                          |
| `test:`     | Adding or fixing tests                      |
| `chore:`    | Tooling, deps, config                       |
| `perf:`     | Performance improvement                     |
| `style:`    | Formatting only                             |
| `ci:`       | Changes to CI configuration                 |

Write the subject line in the imperative ("add", not "added"), keep it under 72 characters, and use
the body to explain _why_ — not _what_ (the diff already shows that).

---

## Quality bar

Every PR must:

- [ ] Pass `npm run format:check` and `npm run lint` locally before pushing
- [ ] Pass the `Lint & format` job in CI
- [ ] Stay focused on a single concern
- [ ] Update relevant docs (`README.md`, `CONCEPTS.md`, `COMMANDS.md`, setup READMEs) when behavior
      or structure changes
- [ ] Include a reviewable test plan in the PR description

PRs that add new rules, commands, skills, or setups must also:

- [ ] Include a realistic usage example
- [ ] Be written in clear, professional English
- [ ] Avoid duplicating existing playbook functionality

---

## Reviewing

- Be kind, be specific, be fast.
- Ask for changes with reasons, not commands.
- Approve when the PR meets the quality bar — not when it is perfect.

---

## Questions?

Open a [discussion](https://github.com/KaelSensei/ai-playbook/discussions) or an issue with the
`question` label.
