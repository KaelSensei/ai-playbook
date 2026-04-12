---
name: customization
description:
  How to customize playbook behavior using .customize.yaml without editing playbook files directly.
  Covers agent persona overrides, command extensions, rule adjustments, and project-specific
  settings. Customizations survive playbook updates.
---

# Customization Skill — User Overrides Without Forking

A pattern for letting users customize playbook behavior (agent personas, command behavior, rule
adjustments) via a single `.customize.yaml` file that survives playbook updates. Inspired by
BMAD-METHOD's customization pattern.

## When to use this skill

- When a user wants to customize agent behavior without editing playbook files.
- When setting up a project with specific conventions that differ from playbook defaults.
- When onboarding a team that needs consistent customization across members.
- When referenced by `/start`, `/init-project`, or `/adopt-legacy`.

## How this skill is used

**Users do not invoke skills directly.** The AI reads `.customize.yaml` during context loading (Step
1 of any command) and applies overrides automatically.

---

## The Problem

When users edit playbook files directly to customize behavior:

- Updates to the playbook overwrite their changes (if using submodule or CLI update).
- Different team members have different local edits — no consistency.
- It's unclear what was customized vs what's default.

## The Solution: `.customize.yaml`

A single YAML file at the project root that declares overrides. The playbook reads this file during
context loading and applies customizations on top of defaults.

### File location

```
project-root/
  .customize.yaml          # Project-level customization (committed to repo)
  .customize.local.yaml    # Personal overrides (gitignored, per-developer)
```

**Resolution order** (last wins):

1. Playbook defaults (`.agents/` files)
2. `.customize.yaml` (project-level, shared)
3. `.customize.local.yaml` (personal, gitignored)

---

## Configuration Sections

### 1. Project Settings

```yaml
project:
  name: 'My SaaS App'
  description: 'Multi-tenant project management tool'
  tech_stack: 'TypeScript, React, PostgreSQL, Prisma'
  architecture: 'hexagonal'
  default_branch: 'main'
  commit_style: 'conventional' # conventional | angular | custom
```

### 2. Agent Persona Overrides

Customize how agents communicate without changing their capabilities:

```yaml
agents:
  # Override communication style for all agents
  global:
    tone: 'concise' # concise | detailed | teaching
    verbosity: 'low' # low | medium | high
    emoji: false # disable emoji in responses
    language: 'en' # response language

  # Override specific agent personas (for multi-agent setups)
  tech-lead:
    name: 'Alex' # rename the persona
    tone: 'detailed'
    extra_context: |
      This project uses a monorepo with pnpm workspaces.
      Always check which package you're in before making changes.

  dev-senior-a:
    name: 'Sam'
    focus: 'backend' # hint for task routing
```

### 3. Command Behavior Overrides

Adjust how commands behave without editing command files:

```yaml
commands:
  feature:
    # Always use Full Flow (never Quick Flow)
    default_flow: 'full' # quick | full | auto (default: auto)
    # Always run /ready-check before implementing
    require_ready_check: true
    # Skip doc updates (e.g., for prototype branches)
    skip_docs: false

  fix:
    default_flow: 'auto'
    # Always use debugging-methodology skill
    always_deep: false

  review-pr:
    # Always run adversarial review
    default_depth: 'adversarial' # standard | adversarial | auto (default: auto)

  spec:
    # Minimum number of P1 user stories
    min_p1_stories: 2
    # Auto-include security implications section
    require_security_section: true

  brainstorm:
    # Always use party mode
    default_party: false
```

### 4. Rule Adjustments

Override specific rule behaviors:

```yaml
rules:
  # Relax auto-commit for prototype branches
  version_management:
    auto_push: true # set to false to commit without pushing
    require_branch: true # set to false for solo/prototype work

  # Adjust documentation requirements
  documentation:
    auto_update: true
    require_user_guide: false # skip USER_GUIDE.md updates

  # Constitution overrides (use with caution)
  constitution:
    # Relax specific articles for prototyping
    relaxed_articles: [] # e.g., [4, 6] to relax spec-before-impl and testing
```

### 5. Custom Conventions

Project-specific conventions the AI should follow:

```yaml
conventions:
  # File naming
  components: 'PascalCase' # PascalCase | camelCase | kebab-case
  utilities: 'camelCase'
  tests: '*.test.ts' # test file naming pattern

  # Code style
  max_file_length: 300 # warn if file exceeds this
  prefer_named_exports: true
  error_handling: 'typed' # typed | try-catch | result

  # PR and review
  pr_template: 'default' # default | minimal | detailed
  require_tests: true
  min_review_findings: 3 # minimum findings for adversarial review
```

### 6. Extra Context

Additional context the AI should know about this project:

```yaml
context:
  # Loaded into every command's Step 1
  always: |
    This project serves financial institutions. All data handling must
    comply with SOC2 requirements. PII must never be logged.

  # Loaded only for specific command categories
  workflow: |
    We deploy on Fridays (yes, really). Always check the deploy calendar
    before suggesting a merge to main.

  security: |
    We use Vault for secrets management. Never suggest .env files for
    production credentials.
```

---

## How Commands Read Customizations

During Step 1 (Load Context) of any command, the AI should:

1. Check for `.customize.yaml` in the project root.
2. Check for `.customize.local.yaml` in the project root.
3. Apply overrides on top of playbook defaults (local overrides win).
4. Respect the customizations throughout the command execution.

Example: If `.customize.yaml` sets `commands.feature.default_flow: "full"`, then `/feature` should
always use Full Flow regardless of complexity assessment.

---

## Template File

Projects using the playbook can create a `.customize.yaml` from this minimal template:

```yaml
# AI Playbook Customization
# See: .agents/skills/customization/SKILL.md for all options

project:
  name: ''
  tech_stack: ''

agents:
  global:
    tone: 'concise'
    emoji: false

commands: {}

rules: {}

conventions: {}

context:
  always: ''
```

---

## Best Practices

- **Commit `.customize.yaml`** — It's project configuration, shared across the team.
- **Gitignore `.customize.local.yaml`** — It's personal preferences, not shared.
- **Don't over-customize** — The playbook defaults are sensible. Only override what you need.
- **Document why** — Add comments to non-obvious overrides so teammates understand the reasoning.
- **Review after updates** — When updating the playbook, check if new features added options to
  `.customize.yaml`.

## Anti-patterns

- Using `.customize.yaml` to disable security rules. Don't.
- Putting implementation details in `context.always`. Use docs instead.
- Overriding everything — if you disagree with most defaults, fork the playbook instead.
- Relaxing constitution articles without team discussion.
