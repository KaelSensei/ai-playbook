## Agents Compatibility – Claude Code, Cursor & Others

This playbook is **tool-agnostic**. Its concepts (rules, commands, skills, MCP) work with any AI
agent that can read markdown: **Claude Code**, **Cursor**, or custom MCP clients.

---

### 1. How different tools consume the playbook

| Tool         | Config directory | Rules                   | Commands             | Skills            | MCP                |
| ------------ | ---------------- | ----------------------- | -------------------- | ----------------- | ------------------ |
| Claude Code  | `.claude/`       | Read as project context | Slash commands       | `.claude/skills/` | `.claude/mcp.json` |
| Cursor       | `.cursor/`       | `.cursor/rules/*.mdc`   | `.cursor/commands/`  | `.cursor/skills/` | `.cursor/mcp.json` |
| Other agents | Any              | Read as markdown        | Follow as checklists | Read as knowledge | Standard MCP       |

### 2. Installing for your tool

Each multi-agent setup includes an `install.sh` that accepts a target directory:

```bash
# For Claude Code (default)
bash install.sh

# For Cursor
bash install.sh .cursor

# For any other tool
bash install.sh .your-tool
```

The installer copies agents, commands, skills, and foundation docs into your chosen directory.

---

### 3. What is tool-agnostic?

The **content itself** is tool-agnostic:

- Rules (`.mdc`) are just markdown files that describe constraints and policies.
- Commands (`.md`) are just **procedures**: numbered steps for how an AI should work.
- Skills (`SKILL.md`) are just **knowledge modules**: checklists and instructions for specific
  tasks.
- MCP config (`mcp.json`) is a standard MCP configuration file used by any MCP-capable client.

Any AI agent that can read markdown can:

- Load rules as "global constraints".
- Treat commands as playbook checklists.
- Load skills as reference knowledge.

---

### 4. Multi-agent setups

The `.agents/setups/` directory contains pre-configured teams:

| Setup              | Purpose                          | Agent count |
| ------------------ | -------------------------------- | ----------- |
| `dev-squad-v2`     | TypeScript/React TDD development | 3           |
| `pm-ba-squad-v2`   | Product specs, BDD stories       | 3           |
| `legacy-agents-v1` | Legacy codebase modernization    | 14          |
| `web2-agents-v1`   | Full-stack SaaS development      | 13          |
| `web3-agents-v3`   | Smart contracts, DeFi            | 10          |

Each setup is self-contained with its own agents, skills, commands, and documentation templates.

---

### 5. Reliability goals

To keep the playbook reliable across tools:

- All files are **plain markdown or JSON**, no custom formats.
- Rules and skills avoid tool-specific instructions and focus on:
  - Behavior constraints (rules).
  - Knowledge and checklists (skills).
- Commands clearly describe **what** to do in each step, so any agent can follow them as a script.
- Install scripts accept a configurable target directory.

This keeps `.agents/` as the **single source of truth** for AI behavior, while allowing multiple
tools (Claude Code, Cursor, custom MCP clients) to consume it.
