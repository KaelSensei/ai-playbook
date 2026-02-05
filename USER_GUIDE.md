## AI Playbook – User Guide

This guide explains how to use the AI Playbook commands in a typical development workflow when
working in Cursor (or another AI-assisted editor).

The high-level rules are:

- Always work on **branches**, not directly on `main`/`master`.
- After you (or the AI) have **solved, fixed, or developed** something, you **must**: `git add`,
  `git commit`, and `git push`.
- Keep documentation up to date, especially `USER_GUIDE.md`, `COMMANDS.md`, and any project-specific
  docs.

See `COMMANDS.md` for the full command catalog. This guide focuses on how they fit together.

---

## 1. Getting Started on a Project

Use these commands when first attaching the AI Playbook to a project:

- `/start` – Load project context, rules, and key docs; pick the next task.
- `/continue` – Resume work, reload context, and continue with pending tasks.
- `/init-project [description]` – Scaffold a new project (README, `.gitignore`, optional playbook).
- `/adopt-legacy [scope]` – Onboard an existing/legacy codebase (analyze, document, optionally add
  the playbook).

Typical first steps:

1. Install or link the playbook (see `INSTALLATION.md`).
2. Open the project in Cursor.
3. Run `/start` to load rules and context.

---

## 2. Feature Workflow

Use this pattern whenever you add **new functionality**.

1. **Create a feature branch**
   - If you’re on `main`/`master`, never implement features there.
   - Use one of:
     - `/feature-branch feature/<description>`
     - `/create-branch` (interactive; choose a `feature/...` name)

2. **Implement the feature**
   - Use `/feature <description>` to run the full feature workflow:
     - Load context and rules.
     - Ensure you’re on a **feature branch** (if on `main`, it will create one via `/feature-branch`
       named from the description).
     - Understand and design the feature.
     - Implement it with security and architecture checks.
     - Update docs (`PROGRESS.md`, `CHANGELOG.md`, `USER_GUIDE.md`, architecture, `README.md`).

3. **Commit and push (mandatory)**
   - Either follow Step 9 of `/feature`, or run `/git [message]`:
     - Run project checks (e.g. `npm run check`, tests, lint).
     - `git add -A`
     - `git commit -m "feat: <clear description>"`
     - `git push origin $(git branch --show-current)`
   - The feature is **not done** until changes are pushed.

4. **Open a PR and merge**
   - `/create-pr <target-branch>` (e.g. `/create-pr dev` or `/create-pr main`) to open a pull
     request from the current branch.
   - Use `/merge-branch-into-dev [branch]` or `/merge-branch-into-main [branch]` to guide safe
     merges when ready (or follow your normal PR review flow).

5. **Release (optional)**
   - Use `/release [version]` to generate release notes from commits since the last tag and create a
     GitHub release (requires `gh`).

---

## 3. Fix Workflow

Use this pattern for **bug fixes** or small patches.

1. **Create a fix branch**
   - Use `/feature-branch fix/<description>` or `/create-branch` and choose a `fix/...` name.

2. **Implement the fix**
   - Use `/fix <issue description>`:
     - Load context and rules.
     - Analyze attachments (logs, screenshots) if provided.
     - Perform targeted, minimal changes.
     - Validate behavior and security.

3. **Commit and push (mandatory)**
   - Follow Step 6 of `/fix` or run `/git [message]`:
     - Run project checks.
     - `git add -A`
     - `git commit -m "fix: <clear description>"`
     - `git push origin $(git branch --show-current)`
   - A fix is **not complete** until it is committed and pushed.

4. **PR and merge**
   - `/create-pr <target-branch>` to open a PR.
   - `/merge-branch-into-dev` / `/merge-branch-into-main` for safe merges.

---

## 4. Documentation & User Guide Updates

The playbook treats documentation as a **first-class requirement**:

- After any **new feature**, update:
  - Project progress docs (`PROGRESS.md`, `CHANGELOG.md`, or equivalent).
  - `USER_GUIDE.md` (explain how end users access and use the new behavior).
  - Architecture docs if structure or data flow changed.
- For this playbook repo itself:
  - Keep `COMMANDS.md` and this `USER_GUIDE.md` in sync with changes to commands and rules.

Helpful commands:

- `/create-user-guide` – Generate or regenerate a project’s user-facing guide.
- `/update-user-guide` – Add or update sections in `USER_GUIDE.md` (e.g. after a feature).
- `/create-command <name> [...]` – Generate a new command file following project structure.

When you change how the AI should behave for a project, make sure `USER_GUIDE.md` reflects that
behavior so humans understand the flow.

---

## 5. Other Useful Commands (Brief)

- **Quality & cleanup**
  - `/audit-code [target]` – Analyze quality, security, and standards.
  - `/cleanup-repo` – Reorganize repository structure (docs, scripts, assets).
  - `/magic-wand [issue]` – Deep debugging when normal approaches fail.
- **DevOps**
  - `/devops <task>` – Design or update CI/CD, infrastructure, and pipelines.
- **Ideation**
  - `/brainstorm [topic]` – Generate and refine ideas, and turn them into actionable tasks.

For the full command catalog and per-command details, see `COMMANDS.md`.
