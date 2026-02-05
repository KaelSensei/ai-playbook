# Context summary

**How to use this:** Load this file into another AI agent to restore project and task context.

---

## Project

- **Repo:** ai-playbook
- **Purpose:** Shared AI playbook for Cursor (and other agents): reusable rules, commands, security
  and version discipline. Install via Git submodule or `npx ai-playbook-cli install`.
- **Branch:** `feature/export-context-command`
- **Stack:** Markdown/JSON (rules, commands), Node/TypeScript (CLI), Prettier/ESLint/Husky.

---

## Rules in effect

- **documentation.mdc** – Update docs after every change; PROGRESS/CHANGELOG/USER_GUIDE/README; same
  commit as code.
- **general-principles.mdc** – Simple, offline-first, no over-engineering; project philosophy.
- **security.mdc** – No backdoors, no eval; validate MCP/domains; treat scraped/input data as
  untrusted.
- **technical-stack.mdc** – Tech stack patterns; DB, scraping, images; quality standards.
- **version-management.mdc** – Auto commit+push after solved/fixed/developed; conventional commits;
  no commit to main; “Before you finish” completion check (if files changed → must commit+push).

---

## Key files and paths

- `README.md` – Project overview, installation (submodule, CLI, manual), usage.
- `COMMANDS.md` – Full command list and descriptions; annex to README.
- `INSTALLATION.md` – Detailed install, CLI build/publish, troubleshooting.
- `.cursor/rules/*.mdc` – Rules (alwaysApply); loaded by Cursor.
- `.cursor/commands/` – Commands by category: bootstrap/, git/, workflow/, quality/, docs/, devops/,
  ideation/.
- `.cursor/docs/` – COMMANDS_STRUCTURE.md, DOCUMENTATION_STRUCTURE.md, GAPS_AND_RECOMMENDATIONS.md.
- `cli/` – Node/TS CLI: install, status, update; copies/symlinks .cursor into target project.
- `package.json` (root) – Scripts: format, format:check, lint, check.
- `.cursor/commands/docs/export-context.md` – Command that produces this summary.

---

## Current task / goal

- User ran `/export-context` to generate this compressed context file.
- Goal: allow another AI agent to load this file and continue work on ai-playbook with full context
  (rules, structure, task) without re-pasting conversation or files.

---

## Decisions or constraints

- Work on feature branches; merge to dev then main via commands.
- Every change (code/docs/rules/commands) must end with commit+push unless explicitly blocked.
- No secrets in exported context; keep summaries compressed (paths + one-liners, no full file
  dumps).

---

## Repo structure (compact)

- `.cursor/` – rules, commands (by category), docs, mcp.json.example.
- `cli/` – ai-playbook-cli (install/status/update).
- `assets/` – cover image.
- Root: README, COMMANDS, INSTALLATION, package.json, .gitignore, .prettierrc, .husky.
