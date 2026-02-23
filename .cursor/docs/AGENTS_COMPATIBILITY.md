## Agents Compatibility – Cursor, Claude & Others

This playbook is **Cursor-first**, but its concepts (rules, commands, skills, MCP) are intentionally
designed to be usable by other AI agents such as **Claude Code** or custom MCP clients.

This document explains what is Cursor-specific and what is agent-agnostic, and how to reuse the
playbook outside Cursor.

---

### 1. What is Cursor-specific?

- The **directory name** `.cursor/` and the special handling of:
  - `.cursor/rules/*.mdc` as always-on rules.
  - `.cursor/commands/**/*.md` as slash commands (e.g. `/feature`, `/fix`).
  - `.cursor/skills/*/SKILL.md` as agent skills.
- Cursor automatically:
  - Loads rules for every conversation.
  - Executes commands when you type `/command`.
  - Loads skills on demand based on the task.

Other agents do **not** automatically understand `.cursor/` semantics, but they can still consume
the content as structured documentation.

---

### 2. What is agent-agnostic?

The **content itself** is tool-agnostic:

- Rules (`.mdc`) are just markdown files that describe constraints and policies.
- Commands (`.md`) are just **procedures**: numbered steps for how an AI should work.
- Skills (`SKILL.md`) are just **knowledge modules**: checklists and instructions for specific
  tasks.
- MCP config (`.cursor/mcp.json`) is just a standard MCP configuration file used by any MCP-capable
  client.

Any AI agent that can read markdown can:

- Load rules as "global constraints".
- Treat commands as playbook checklists.
- Load skills as reference knowledge.

---

### 3. Using this playbook with Claude Code

Claude Code has its own conventions (`CLAUDE.md`, `.claude/skills`, hooks, etc.), but you can still
benefit from this playbook:

- **Rules**
  - Option 1: Keep `.cursor/rules/*.mdc` as-is and instruct Claude (in `CLAUDE.md`) to treat them as
    project-wide rules.
  - Option 2: Copy or adapt specific rules (e.g. `security.mdc`, `version-management.mdc`) into
    Claude-specific rule files or skills.

- **Commands**
  - Claude does not currently execute `.cursor/commands/*.md` as slash commands.
  - You can still:
    - Use them as **manual checklists** when working in Claude.
    - Convert frequently used workflows into Claude skills or custom automation.

- **Skills**
  - The content of `.cursor/skills/*/SKILL.md` can be reused as Claude skills by:
    - Copying the markdown into `.claude/skills/<name>/SKILL.md`, or
    - Referencing the repo in your `CLAUDE.md` and instructing Claude to read those files on demand.

- **MCP**
  - The MCP configuration in `.cursor/mcp.json` is standard MCP and can be used by **any**
    MCP-compatible client, including Claude Code, as long as the client is pointed at this config.

In short: Claude won’t "run" `.cursor` automatically, but it can **reuse the same rules, commands,
and skills as structured guidance.**

---

### 4. Reliability goals for `.cursor/`

To keep `.cursor/` reliable across tools:

- All files are **plain markdown or JSON**, no custom formats.
- Rules and skills avoid Cursor-only instructions where possible and focus on:
  - Behavior constraints (rules).
  - Knowledge and checklists (skills).
- Commands clearly describe **what** to do in each step, so non-Cursor agents can follow them as a
  script even if the `/command` trigger is not supported.

For advanced integration (e.g. auto-running commands in Claude or other tools), you can:

- Build thin adapters that:
  - Read `.cursor/commands/*.md`.
  - Execute equivalent steps using that tool’s APIs.
  - Reuse rules and skills as-is.

This keeps `.cursor/` as the **single source of truth** for AI behavior, while allowing multiple
agents (Cursor, Claude Code, custom MCP clients) to participate.
