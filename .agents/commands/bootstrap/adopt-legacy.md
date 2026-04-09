# Adopt Legacy Command – Onboard an Existing or Legacy Codebase

When `/adopt-legacy [scope]` is invoked, analyze an existing codebase, document its structure and
conventions, and optionally add this AI Playbook (rules + commands) so the assistant can work safely
and consistently on the project.

---

## Step 1: Load Context & Follow Rules

1. Assume the project root as the working directory
2. If `.cursor/rules/*.mdc` exist, load and respect them; otherwise proceed with security-first
   defaults
3. Identify repository structure: language(s), build system, entry points, tests

---

## Step 2: Analyze the Codebase

1. **Scan** (without making destructive changes):
   - Root config files (package.json, pyproject.toml, Cargo.toml, go.mod, etc.)
   - Directory layout (src/, app/, lib/, tests/, scripts/)
   - Existing docs (README, CONTRIBUTING, ARCHITECTURE, etc.)
   - CI/CD (e.g. `.github/workflows/`, Makefile, scripts)
2. **Summarize**:
   - Tech stack and versions
   - Conventions (naming, style, test framework)
   - Known pain points (no tests, no docs, mixed styles)
3. If scope provided (e.g. `/adopt-legacy frontend`), focus analysis on that area

---

## Step 3: Document Structure and Conventions

1. Create or update project documentation:
   - **README.md** – ensure it describes how to run, build, and test
   - **ARCHITECTURE.md** or **.cursor/docs/** – high-level structure, main modules, data flow
   - **PROGRESS.md** or **CHANGELOG.md** – optional; suggest format if missing
2. Capture conventions in a short “Conventions” section or file (e.g. branch naming, commit style,
   where to put new code)
3. Do **not** refactor or rewrite code in this step; document only

---

## Step 4: Add or Adapt AI Playbook

1. **If `.cursor/` is missing or minimal**:
   - Recommend adding this AI Playbook (submodule, CLI install, or copy)
   - Add only rules and commands; do **not** copy `.cursor/mcp.json` (sensitive)
2. **If project already has rules**:
   - Suggest merging or extending with playbook rules (security, version-management, docs)
   - Preserve project-specific rules (e.g. tech stack, allowed domains)
3. **Optional**: Add a short `.cursor/docs/PROJECT_CONTEXT.md` that summarizes stack, conventions,
   and “how we work” for the AI

---

## Step 5: Suggest Next Steps (No Mandatory Changes)

1. Propose a small, safe first task (e.g. add tests for one module, document one API, fix one lint
   rule)
2. Suggest using `/start` for daily work and `/feature`, `/fix`, `/refactor` for changes
3. If critical gaps (e.g. no tests, no CI): list them and suggest incremental improvements
4. Do **not** force large refactors or rewrites; adopt incrementally

---

## Cursor Behavior Rules

- **Analyze and document first** – no destructive or large-scale code changes
- **Respect existing structure** – work with the current layout and conventions where possible
- **Security** – never introduce secrets or unsafe patterns; tighten .gitignore if needed
- **Playbook** – recommend adding rules/commands; do not overwrite existing .cursor without
  confirmation

---

## Usage

- `/adopt-legacy` – Analyze full repo and suggest docs + playbook integration
- `/adopt-legacy frontend` – Focus on frontend area only
- `/adopt-legacy docs` – Focus on documenting structure and conventions

Use for **existing or legacy** projects. For a **new** repo from scratch, use `/init-project`
instead.
