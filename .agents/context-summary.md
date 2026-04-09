# Context summary

**How to use this:** Load this file into another AI agent to restore project and task context.

---

## Project

- **Repo:** ai-playbook
- **Purpose:** Shared AI playbook (tool-agnostic): reusable rules, commands, skills, and multi-agent
  setups for Claude Code, Cursor, or any AI tool. Install via Git submodule,
  `npx ai-playbook-cli install`, or multi-agent setup scripts.
- **Stack:** Markdown/JSON (rules, commands, skills), Node/TypeScript (CLI), Prettier/ESLint/Husky.

---

## Rules in effect

- **documentation.mdc** – Update docs after every change; same commit as code.
- **general-principles.mdc** – Simple, offline-first, no over-engineering.
- **security.mdc** – No backdoors, no eval; validate MCP/domains; treat external data as untrusted.
- **technical-stack.mdc** – Tech stack patterns; quality standards.
- **version-management.mdc** – Auto commit+push after work; conventional commits; no commit to main.

---

## Key files and paths

- `README.md` – Project overview, installation, usage.
- `COMMANDS.md` – Full command list and descriptions.
- `CONCEPTS.md` – Rules, commands, skills, MCP explained.
- `INSTALLATION.md` – Detailed install, CLI build/publish, troubleshooting.
- `.agents/rules/*.mdc` – Behavior rules.
- `.agents/commands/` – Commands by category: bootstrap/, git/, workflow/, quality/, docs/, devops/,
  ideation/.
- `.agents/skills/` – On-demand expertise modules.
- `.agents/setups/` – Pre-configured multi-agent teams:
  - `dev-squad-v2/` – 3-agent TypeScript/React TDD team.
  - `pm-ba-squad-v2/` – 3-agent PM/BA spec team.
  - `legacy-agents-v1/` – 14-agent legacy modernization team.
  - `web2-agents-v1/` – 13-agent full-stack SaaS team.
  - `web3-agents-v3/` – 10-agent Web3/DeFi team.
- `.agents/docs/` – AGENTS_COMPATIBILITY, COMMANDS_STRUCTURE, DOCUMENTATION_STRUCTURE.
- `cli/` – Node/TS CLI: install, status, update.

---

## Repo structure (compact)

- `.agents/` – rules, commands, skills, setups, docs, mcp.json.example.
- `cli/` – ai-playbook-cli (install/status/update).
- `assets/` – cover image.
- Root: README, COMMANDS, CONCEPTS, INSTALLATION, package.json, .gitignore, .prettierrc, .husky.
