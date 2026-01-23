# AI Playbook

This repository contains a **shared AI playbook** used across multiple projects to standardize how AI assistants (Cursor, Claude, etc.) contribute to codebases.

It defines:
- Reusable **Cursor rules (`.mdc`)**
- Structured **AI commands** (`/start`, `/feature`, `/fix`, `/refactor`, etc.)
- **Security-first policies** (MCP validation, backdoor prevention, supply-chain awareness)
- **Version and branch discipline** for AI-generated commits

The goal is to ensure AI-assisted development is:
- **Consistent** across projects
- **Safe** by default
- **Auditable** and reviewable
- **Explicit in intent** (feature vs fix vs refactor)

---

## Why This Exists

Copy-pasting AI rules between projects does not scale and leads to:
- Silent behavior drift
- Inconsistent security guarantees
- Uncontrolled AI changes

This repository acts as a **single source of truth** for AI behavior and is meant to be included in projects via **Git submodules or symlinks**.

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

## Typical Usage

- Added as a **git submodule** in projects
- Linked to `.cursor/rules/`
- Read automatically by AI assistants
- Updated independently of application code

---

## Design Principles

- Security > correctness > performance > convenience
- Explicit intent over implicit behavior
- Minimal magic, maximal auditability
- AI should behave like a **senior engineer**, not an autocomplete engine

---

## Versioning

Changes to AI behavior are versioned and must be consciously pulled into projects.
Breaking changes are documented.

---

## Resources

### Official Documentation

- **[Cursor Commands Documentation](https://cursor.com/fr/docs/context/commands)** - Official Cursor documentation on creating and using custom commands
  - Learn how commands work
  - Understand command structure and syntax
  - See examples of effective commands

### Community Examples

- **[cursor-commands Repository](https://github.com/hamzafer/cursor-commands/tree/main/.cursor/commands)** - Community-maintained collection of Cursor command examples
  - Real-world command implementations
  - Additional command patterns and workflows
  - Inspiration for creating your own commands

---

## License

Internal / private by default.  
Adapt as needed.
