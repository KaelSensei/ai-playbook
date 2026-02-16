<div align="center">
  <img src="assets/ai-playbook-cover.png" alt="AI Playbook" width="600"/>
</div>

# AI Playbook

This repository contains a **shared AI playbook** used across multiple projects to standardize how
AI assistants (Cursor, Claude, etc.) contribute to codebases.

It defines:

- Reusable **Cursor rules (`.mdc`)** — persistent behavior constraints
- Structured **AI commands** (`/start`, `/feature`, `/fix`, `/refactor`, etc.) — slash-triggered
  workflows
- **Agent skills** (`.cursor/skills/`) — on-demand domain expertise (security review, conventional
  commits, release notes, etc.)
- **Security-first policies** (MCP validation, backdoor prevention, supply-chain awareness)
- **Version and branch discipline** for AI-generated commits

For a detailed explanation of rules, commands, skills, and MCP, see [CONCEPTS.md](CONCEPTS.md).

The goal is to ensure AI-assisted development is:

- **Consistent** across projects
- **Safe** by default
- **Auditable** and reviewable
- **Explicit in intent** (feature vs fix vs refactor)

For guidance on reducing LLM token usage (especially for shell commands and search), see
[TOKEN_OPTIMIZATION.md](TOKEN_OPTIMIZATION.md).

---

## Why This Exists

Copy-pasting AI rules between projects does not scale and leads to:

- Silent behavior drift
- Inconsistent security guarantees
- Uncontrolled AI changes

This repository acts as a **single source of truth** for AI behavior and is meant to be included in
projects via **Git submodules or symlinks**.

Each project can pin a specific version of the playbook and upgrade intentionally.

---

## What This Repo Is (and Is Not)

**This repo is:**

- A reusable AI behavior baseline
- Tool-agnostic (Cursor, Claude, future agents)
- Security-focused and production-oriented

**This repo is NOT:**

- Project-specific documentation
- Application code
- A framework or SDK

---

## Installation

### Option 1: Git Submodule (Recommended for Teams)

**Best for teams, long-term projects, and version-controlled AI behavior.**

```bash
# Add as Git submodule
git submodule add https://github.com/YOUR_USERNAME/ai-playbook.git .ai-playbook

# Create symlinks
mkdir -p .cursor
ln -s ../.ai-playbook/.cursor/rules .cursor/rules
ln -s ../.ai-playbook/.cursor/commands .cursor/commands
ln -s ../.ai-playbook/.cursor/docs .cursor/docs
```

**Benefits:**

- ✅ Update rules in one place, pull into all projects
- ✅ Version-control AI behavior (huge win!)
- ✅ Pin specific versions per project
- ✅ No npm/node dependencies
- ✅ This is what serious infra teams do

**Updating:**

```bash
git submodule update --remote .ai-playbook
```

### Option 2: CLI Tool (Quick Setup)

**Best for quick setup and individual developers.**

```bash
# Install in your project (creates symlinks)
npx ai-playbook-cli@latest install

# Or copy files directly
npx ai-playbook-cli@latest install --type copy
```

**Next Steps:**

1. Verify installation: `npx ai-playbook-cli@latest status`
2. Open your project in Cursor
3. Start using commands like `/start`, `/feature`, `/fix`
4. See [INSTALLATION.md](INSTALLATION.md) for detailed setup and troubleshooting

### Option 3: Manual Copy

For one-off installations without Git submodules:

```bash
git clone https://github.com/YOUR_USERNAME/ai-playbook.git .ai-playbook
cp -r .ai-playbook/.cursor .cursor
```

For detailed installation, deployment, and development instructions, see
[INSTALLATION.md](INSTALLATION.md).

## Getting Started

After installing the playbook (submodule, CLI, or manual copy), open your project in Cursor and
start using commands in the chat:

### 1. Bootstrap your session

```
/start
```

The AI loads your project docs, rules, and progress tracking, then picks up the next task and begins
working. Use this at the start of each new session.

### 2. Implement features and fixes

```
/feature add dark mode toggle
/fix image loading crash on Android
/refactor extract database utilities
```

Each command follows a full workflow: branch creation, implementation, validation, documentation
update, and commit+push.

### 3. Manage Git

```
/git                              # stage, commit, push (auto-generates message)
/create-branch                    # interactive branch creation
/create-pr dev                    # open PR from current branch into dev
/merge-branch-into-main           # safe merge with security review
/release 1.2.0                    # generate release notes + GitHub release
```

### 4. Quality and debugging

```
/audit-code src/                  # code quality + security audit
/magic-wand app crashes on start  # deep root-cause analysis
/cleanup-repo                     # reorganize scattered files
/clean-code src/utils/            # remove dead code and clutter
```

### 5. Resume after a break

```
/continue
```

The AI reloads progress, checks the current branch, and picks up where you left off.

### Skills (automatic)

Skills are **not invoked directly**. The AI loads them automatically when a matching task is
detected, or when a command references them (e.g. `/feature` uses the `security-review` and
`git-branch-naming` skills). See [CONCEPTS.md](CONCEPTS.md) for details.

---

## Typical Usage

- Installed via **CLI tool** or **Git submodule**
- Linked to `.cursor/rules/`, `.cursor/commands/`, and `.cursor/skills/`
- Read automatically by AI assistants
- Updated independently of application code

### Project-Specific Configuration

You can add project-specific MCP (Model Context Protocol) server configurations in
`.cursor/mcp.json`:

- **Already in `.gitignore`** - contains sensitive tokens, never committed
- Each developer can have their own `mcp.json` with personal tokens
- The CLI automatically excludes `mcp.json` when installing

See [INSTALLATION.md](INSTALLATION.md) for details.

---

## Design Principles

- Security > correctness > performance > convenience
- Explicit intent over implicit behavior
- Minimal magic, maximal auditability
- AI should behave like a **senior engineer**, not an autocomplete engine

---

## Development

This repository uses ESLint and Prettier for code quality and formatting.

### Setup

```bash
# Install dependencies
npm install

# Format all files
npm run format

# Check formatting
npm run format:check

# Lint TypeScript code (CLI)
npm run lint

# Run all checks
npm run check
```

### Code Quality

- **ESLint**: TypeScript/JavaScript linting for the CLI tool
- **Prettier**: Code formatting for all files (Markdown, JSON, TypeScript, etc.)
- **Pre-commit hooks**: Automatically runs linting and formatting checks before each commit
  - Uses [Husky](https://typicode.github.io/husky/) for Git hooks
  - Uses [lint-staged](https://github.com/lint-staged/lint-staged) to check only staged files
  - Automatically fixes formatting issues when possible

---

## Versioning

Changes to AI behavior are versioned and must be consciously pulled into projects. Breaking changes
are documented.

---

## CLI Commands

The AI Playbook includes a CLI tool for easy installation and management:

```bash
# Install in current project
npx ai-playbook-cli@latest install

# Check installation status
npx ai-playbook-cli@latest status

# Update playbook
npx ai-playbook-cli@latest update
```

See [cli/README.md](cli/README.md) for full CLI documentation.

For installation, deployment, and next steps, see [INSTALLATION.md](INSTALLATION.md).

## Resources

### Official Documentation

- **[Cursor Commands Documentation](https://cursor.com/fr/docs/context/commands)** - Official Cursor
  documentation on creating and using custom commands
  - Learn how commands work
  - Understand command structure and syntax
  - See examples of effective commands

### Community Examples

- **[cursor-commands Repository](https://github.com/hamzafer/cursor-commands/tree/main/.cursor/commands)** -
  Community-maintained collection of Cursor command examples
  - Real-world command implementations
  - Additional command patterns and workflows
  - Inspiration for creating your own commands

- **[AIBlueprint](https://github.com/Melvynx/aiblueprint)** - Similar CLI tool for Claude Code
  configurations
  - Inspiration for CLI structure
  - Example of npx-based installation

- **[TOKEN_OPTIMIZATION.md](TOKEN_OPTIMIZATION.md)** - Practical guide to reducing token usage with
  RTK (Rust Token Killer) and playbook-level token hygiene.

---

## Annex – Commands & Skills

For a consolidated overview of all available Cursor commands in this playbook, see:

- [COMMANDS.md](COMMANDS.md) – summary table of every `/command` and its purpose

For the agent skills bundled with this playbook, see:

- [CONCEPTS.md](CONCEPTS.md) – explains rules, commands, skills, and MCP
- `.cursor/skills/` – skill files the AI loads on demand

---

## License

This project is free to use and reuse for any purpose, including commercial use.  
You are free to:

- Use this playbook in your projects (commercial or non-commercial)
- Modify and adapt it to your needs
- Share it with others
- Include it in proprietary software

No attribution required, though it's appreciated.
