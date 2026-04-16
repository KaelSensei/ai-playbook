# AI Playbook Concepts

This document explains the four core building blocks of the AI Playbook: **Rules**, **Commands**,
**Skills**, and **Setup Bundles** — plus a brief overview of **MCP (Model Context Protocol)** and
how everything fits together.

---

## 1. Rules (`.agents/rules/*.mdc`)

### What are rules?

Rules are persistent instructions that tell the AI assistant **how to behave** in every
conversation. They are loaded automatically when you open the project — no slash command needed.

Think of rules as the AI's **operating manual** for your project.

### Where do they live?

```
.agents/rules/
  general-principles.mdc     # Project philosophy and mental model
  technical-stack.mdc        # Languages, frameworks, build tools
  security.mdc               # Security policies and merge safety
  documentation.mdc          # What docs to update and when
  version-management.mdc     # Git workflow, commit conventions, auto-push
  ethskills.mdc              # (Optional) Ethereum-specific knowledge & guardrails for onchain apps
```

### How do they work?

Each `.mdc` file has YAML frontmatter that controls when the rule is loaded:

```markdown
---
description: Short summary of the rule
alwaysApply: true # or false
globs: '**/*.ts' # only for scoped rules
---

# Rule Title

Instructions for the AI...
```

| Mode                           | Loaded when                                         |
| ------------------------------ | --------------------------------------------------- |
| `alwaysApply: true`            | Every conversation, regardless of open files.       |
| `alwaysApply: false` + `globs` | Only when files matching the glob pattern are open. |

### When to create a new rule

- You want to enforce a standard **across all conversations** (e.g. "always use TypeScript").
- You want to scope behavior to certain files (e.g. "React patterns for `*.tsx`").
- The instruction should survive between sessions (rules persist, chat messages don't).

### Key points

- Rules are **passive** — they shape behavior but don't trigger actions.
- Multiple rules can be active at the same time.
- Rules should be **short and focused** (one concern per file).
- Never put secrets in rules.

---

## 2. Commands (`.agents/commands/<category>/*.md`)

### What are commands?

Commands are **slash-triggered workflows** that the AI executes step by step. When you type
`/feature add search bar`, the AI reads `feature.md` and follows every step in order.

Think of commands as the AI's **playbook of procedures**.

### Where do they live?

```
.agents/commands/
  bootstrap/     # /start, /continue, /init-project, /adopt-legacy
  git/           # /git, /create-branch, /create-pr, /release
  workflow/      # /feature, /fix, /refactor, /beautify, /clean-code
  quality/       # /audit-code, /magic-wand, /cleanup-repo
  docs/          # /create-user-guide, /update-user-guide, /export-context
  devops/        # /devops
  ideation/      # /brainstorm
```

### How do they work?

The user types `/command-name <arguments>` in the chat. The AI:

1. Loads the command's markdown file.
2. Reads each numbered step.
3. Executes them in order (read files, write code, run shell commands, update docs, commit).

### When to create a new command

- You repeat the same multi-step workflow often.
- You want to standardize a process so the AI always follows the same steps.
- The workflow involves rules from multiple `.mdc` files.

### Key points

- Commands are **active** — they trigger a sequence of actions.
- Commands **reference rules** (e.g. "follow `security.mdc`") but don't replace them.
- Commands **reference skills** for domain knowledge (e.g. "use `security-review` skill" for the
  security checklist, "use `conventional-commits` skill" for the commit message).
- Commands should end with a commit+push step (per `version-management.mdc`).
- See [COMMANDS.md](COMMANDS.md) for the full list.

---

## 3. Skills (`.agents/skills/<name>/SKILL.md`)

### What are skills?

Skills are **domain expertise** packaged as reusable markdown files. They teach the AI **how to do
something specific** — like writing a conventional commit, performing a security review, or
generating release notes.

Think of skills as the AI's **reference manuals** for specialized tasks.

### Where do they live?

```
.agents/skills/
  create-rule/             # How to write .mdc rules
  create-command/          # How to create new commands
  security-review/         # Security checklist before merge
  conventional-commits/    # Commit message format and types
  release-notes/           # How to generate release notes
  git-branch-naming/       # Branch naming conventions
  code-audit/              # Code quality audit checklist
  debugging-methodology/   # Root-cause analysis for persistent bugs
  repo-organization/       # File/folder conventions for repos
```

Each skill folder contains a `SKILL.md` with YAML frontmatter:

```markdown
---
name: skill-name
description: When to use this skill (one line).
---

# Skill Title

Detailed instructions, checklists, examples...
```

### How do they work?

Skills are **loaded on demand** by the AI when it detects a relevant task. For example:

- Writing a commit → loads `conventional-commits` skill.
- Reviewing a branch before merge → loads `security-review` skill.
- Creating a new rule → loads `create-rule` skill.

Skills can also be referenced explicitly in commands (e.g. "use the `security-review` skill before
merging").

### Rules vs. Skills — what's the difference?

| Aspect       | Rules                         | Skills                          |
| ------------ | ----------------------------- | ------------------------------- |
| **Purpose**  | Enforce behavior constraints  | Provide domain expertise        |
| **Loading**  | Automatic (always or by glob) | On demand (when task matches)   |
| **Tone**     | "You must..." / "Never..."    | "Here's how to..." / "Steps..." |
| **Scope**    | Project-wide or file-scoped   | Task-scoped                     |
| **Examples** | "Never commit to main"        | "How to write a commit message" |

**Rule of thumb:** If it's a constraint → rule. If it's knowledge → skill.

### When to create a new skill

- You find yourself explaining the same process to the AI repeatedly.
- A command needs specialized knowledge that would bloat the command file.
- You want to share expertise across multiple commands.

### Key points

- Skills are **passive knowledge** — they don't trigger actions on their own.
- Skills complement commands (commands say **what** to do, skills say **how**).
- Skills should be concise and actionable (checklists, step-by-step, examples).
- Skills can be project-level (`.claude/skills/`, `.cursor/skills/`) or user-level
  (`~/.claude/skills/`).

---

## 4. Setup Bundles (`.agents/setups/<name>/`)

### What are setup bundles?

Setup bundles are **installable packages** for a specific workflow or project archetype. A setup can
bundle agent personas, setup-local commands, setup-local skills, docs, and optional hooks.

Think of setups as the AI playbook's **pre-arranged team kits**.

### Where do they live?

```
.agents/setups/
  dev-squad-v2/        # TypeScript / React team workflow
  pm-ba-squad-v2/      # Product / business analysis workflow
  legacy-agents-v1/    # Legacy modernization workflow
  web2-agents-v1/      # Full-stack SaaS workflow
  web3-agents-v3/      # Smart-contract / protocol workflow
```

Each setup contains its own installable package, typically under `.claude/` plus a small
`install.sh`.

### How do they work?

When you install a setup, it copies a ready-made team package into your project tool directory
(`.claude/`, `.cursor/`, or another target path). That package may include:

- Agent personas
- Setup-local commands
- Setup-local skills
- Hooks
- Template docs such as `project-architecture.md` or `constants.md`

### Skills vs. Setup Bundles

| Aspect       | Skill                                   | Setup bundle                                 |
| ------------ | --------------------------------------- | -------------------------------------------- |
| **Purpose**  | Add one piece of expertise              | Install a whole workflow package             |
| **Scope**    | Narrow, task-scoped                     | Broad, project/workflow-scoped               |
| **Contents** | One `SKILL.md` plus optional references | Personas, commands, skills, hooks, templates |
| **Usage**    | Loaded on demand during a task          | Installed once into a project                |

**Rule of thumb:** if you need reusable know-how, create a **skill**. If you need a prebuilt team
package for one kind of project, create a **setup bundle**.

### Important distinction

- The base playbook lives in `.agents/rules/`, `.agents/commands/`, and `.agents/skills/`.
- Setup bundles live in `.agents/setups/` and may contain their **own** commands and skills.
- Setup-local skills are not a replacement for the base playbook skill catalog. They belong to that
  setup's workflow.

See [.agents/docs/AGENTS_COMPATIBILITY.md](.agents/docs/AGENTS_COMPATIBILITY.md) for what parts of a
setup bundle actually work in Claude Code vs Cursor.

---

## 5. MCP (Model Context Protocol)

### What is MCP?

MCP (Model Context Protocol) is an **open standard** that lets AI assistants connect to external
tools and data sources through a uniform interface. Instead of building custom integrations for
every tool, MCP provides a single protocol that any AI client can use.

Think of MCP as a **USB-C port for AI** — one standard plug, many devices.

### How does it relate to this playbook?

The AI Playbook itself does **not** require MCP. However, projects that use the playbook can
optionally configure MCP servers to give the AI access to external tools:

| MCP server example | What it provides                                   |
| ------------------ | -------------------------------------------------- |
| GitHub MCP         | Read/write issues, PRs, reviews via AI             |
| Database MCP       | Query databases directly from the chat             |
| Filesystem MCP     | Advanced file operations beyond Cursor's built-ins |
| API MCP (custom)   | Call internal APIs or services                     |

### Where is MCP configured?

```
.agents/mcp.json    # Project-level MCP config (gitignored — contains tokens)
```

This file maps MCP server names to their endpoints and credentials. It is **never committed** to Git
because it typically contains personal access tokens.

### MCP concepts

| Concept       | Description                                                  |
| ------------- | ------------------------------------------------------------ |
| **Server**    | A process that exposes tools/resources via the MCP protocol. |
| **Tool**      | An action the AI can call (e.g. "create GitHub issue").      |
| **Resource**  | Data the AI can read (e.g. "list of open PRs").              |
| **Transport** | How client and server communicate (stdio, SSE, HTTP).        |

### Key points

- MCP is **optional** — the playbook works without it.
- MCP servers can expose **tools** (actions) and **resources** (data) to the AI.
- Configuration lives in `.agents/mcp.json` (gitignored).
- Security rule: **no new MCP servers without explicit approval** (per `security.mdc`).

---

## 6. How Everything Fits Together

```
┌─────────────────────────────────────────────────────────┐
│                     AI Playbook                         │
│                                                         │
│  ┌─────────┐   ┌──────────┐   ┌────────┐   ┌───────┐  │
│  │  Rules   │   │ Commands │   │ Skills │   │  MCP  │  │
│  │ (.mdc)   │   │  (.md)   │   │(SKILL) │   │(.json)│  │
│  └────┬─────┘   └────┬─────┘   └───┬────┘   └───┬───┘  │
│       │              │             │             │       │
│  Always loaded   Triggered by   Loaded when    Optional │
│  or by glob      /slash-cmd     task matches   external │
│       │              │             │           tools     │
│       ▼              ▼             ▼             │       │
│  ┌──────────────────────────────────────────────┘       │
│  │               AI Assistant                           │
│  │  Combines rules + commands + skills + MCP            │
│  │  to execute tasks consistently and safely            │
│  └──────────────────────────────────────────────────────┘
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Typical flow

If you are using the **base playbook only**, the AI combines shared rules, commands, and skills.

If you install a **setup bundle**, that bundle adds a project-specific package on top: personas,
setup-local commands, setup-local skills, and sometimes hooks.

1. **Rules** are loaded → AI knows the project's constraints and standards.
2. User types a **command** (e.g. `/feature add dark mode`) → AI follows the steps.
3. During execution, AI loads relevant **skills** (e.g. `conventional-commits` for the commit step).
4. If MCP is configured, AI can call **external tools** (e.g. create a GitHub PR).
5. AI commits, pushes, and updates docs (per rules).

### Quick reference

| Building block | File location                      | Trigger         | Purpose                         |
| -------------- | ---------------------------------- | --------------- | ------------------------------- |
| Rule           | `.agents/rules/*.mdc`              | Auto / glob     | Enforce constraints             |
| Command        | `.agents/commands/<category>/*.md` | `/command-name` | Execute workflow                |
| Skill          | `.agents/skills/<name>/SKILL.md`   | On demand       | Provide expertise               |
| Setup bundle   | `.agents/setups/<name>/`           | Installed once  | Provide a full workflow package |
| MCP config     | `.agents/mcp.json`                 | When tools used | Connect external APIs           |

---

## 7. Further Reading

- [Cursor Rules Documentation](https://cursor.com/docs/context/rules)
- [Cursor Commands Documentation](https://cursor.com/docs/context/commands)
- [Cursor Agent Skills Documentation](https://cursor.com/docs/context/skills)
- [Model Context Protocol Specification](https://modelcontextprotocol.io/)
- [.agents/docs/AGENTS_COMPATIBILITY.md](.agents/docs/AGENTS_COMPATIBILITY.md): what parts of the
  base playbook vs setup bundles work in each tool
- [COMMANDS.md](COMMANDS.md) — Full list of playbook commands
- [.agents/docs/COMMANDS_STRUCTURE.md](.agents/docs/COMMANDS_STRUCTURE.md) — Command folder
  organization
