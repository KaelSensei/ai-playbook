# AI Playbook Concepts

This document explains the three core building blocks of the AI Playbook: **Rules**, **Commands**,
and **Skills** — plus a brief overview of **MCP (Model Context Protocol)** and how everything fits
together.

---

## 1. Rules (`.cursor/rules/*.mdc`)

### What are rules?

Rules are persistent instructions that tell the AI assistant **how to behave** in every
conversation. They are loaded automatically when you open the project in Cursor — no slash command
needed.

Think of rules as the AI's **operating manual** for your project.

### Where do they live?

```
.cursor/rules/
  general-principles.mdc     # Project philosophy and mental model
  technical-stack.mdc         # Languages, frameworks, build tools
  security.mdc                # Security policies and merge safety
  documentation.mdc           # What docs to update and when
  version-management.mdc      # Git workflow, commit conventions, auto-push
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

## 2. Commands (`.cursor/commands/<category>/*.md`)

### What are commands?

Commands are **slash-triggered workflows** that the AI executes step by step. When you type
`/feature add search bar`, the AI reads `feature.md` and follows every step in order.

Think of commands as the AI's **playbook of procedures**.

### Where do they live?

```
.cursor/commands/
  bootstrap/     # /start, /continue, /init-project, /adopt-legacy
  git/           # /git, /create-branch, /create-pr, /release
  workflow/      # /feature, /fix, /refactor, /beautify, /clean-code
  quality/       # /audit-code, /magic-wand, /cleanup-repo
  docs/          # /create-user-guide, /update-user-guide, /export-context
  devops/        # /devops
  ideation/      # /brainstorm
```

### How do they work?

The user types `/command-name <arguments>` in the Cursor chat. The AI:

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

## 3. Skills (`.cursor/skills/<name>/SKILL.md`)

### What are skills?

Skills are **domain expertise** packaged as reusable markdown files. They teach the AI **how to do
something specific** — like writing a conventional commit, performing a security review, or
generating release notes.

Think of skills as the AI's **reference manuals** for specialized tasks.

### Where do they live?

```
.cursor/skills/
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
- Skills can be project-level (`.cursor/skills/`) or user-level (`~/.cursor/skills/`).

---

## 4. MCP (Model Context Protocol)

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
.cursor/mcp.json    # Project-level MCP config (gitignored — contains tokens)
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
- Configuration lives in `.cursor/mcp.json` (gitignored).
- Security rule: **no new MCP servers without explicit approval** (per `security.mdc`).

---

## 5. How Everything Fits Together

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

1. **Rules** are loaded → AI knows the project's constraints and standards.
2. User types a **command** (e.g. `/feature add dark mode`) → AI follows the steps.
3. During execution, AI loads relevant **skills** (e.g. `conventional-commits` for the commit step).
4. If MCP is configured, AI can call **external tools** (e.g. create a GitHub PR).
5. AI commits, pushes, and updates docs (per rules).

### Quick reference

| Building block | File location                      | Trigger         | Purpose               |
| -------------- | ---------------------------------- | --------------- | --------------------- |
| Rule           | `.cursor/rules/*.mdc`              | Auto / glob     | Enforce constraints   |
| Command        | `.cursor/commands/<category>/*.md` | `/command-name` | Execute workflow      |
| Skill          | `.cursor/skills/<name>/SKILL.md`   | On demand       | Provide expertise     |
| MCP config     | `.cursor/mcp.json`                 | When tools used | Connect external APIs |

---

## Further Reading

- [Cursor Rules Documentation](https://cursor.com/docs/context/rules)
- [Cursor Commands Documentation](https://cursor.com/docs/context/commands)
- [Cursor Agent Skills Documentation](https://cursor.com/docs/context/skills)
- [Model Context Protocol Specification](https://modelcontextprotocol.io/)
- [COMMANDS.md](COMMANDS.md) — Full list of playbook commands
- [.cursor/docs/COMMANDS_STRUCTURE.md](.cursor/docs/COMMANDS_STRUCTURE.md) — Command folder
  organization
