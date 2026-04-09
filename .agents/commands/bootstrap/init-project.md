# Init Project Command – Create a New Project from Scratch

When `/init-project [description]` is invoked, scaffold a new project with a clean structure,
README, .gitignore, and optional AI Playbook integration so the repo is ready for development.

---

## Step 1: Load Context & Follow Rules

1. Assume the **current directory** (or user-specified path) as the project root
2. Load and respect all Cursor rules from `.cursor/rules/*.mdc` (if present)
3. If no rules exist yet, apply security and version-management best practices by default

---

## Step 2: Understand the Project

1. Parse the optional description after `/init-project` (e.g. "Next.js app", "Python CLI", "Rust
   library")
2. If no description: **ask** the user for:
   - Project type (web app, CLI, library, API, etc.)
   - Language/runtime (Node, Python, Go, Rust, etc.)
   - Preferred structure (monorepo, single package, etc.)
3. Infer or confirm:
   - Default branch name (`main` or `master`)
   - Whether to add this AI Playbook (submodule/symlink/copy) into the new project

---

## Step 3: Scaffold Structure

1. **Do not overwrite** existing files without confirmation
2. Create minimal structure:
   - `README.md` – project name, one-line description, how to run/build
   - `.gitignore` – language/project-specific (e.g. node_modules, **pycache**, target/, .env)
   - Optional: `CHANGELOG.md`, `LICENSE`, `.editorconfig`
3. If applicable, add minimal config files:
   - Node: `package.json` (name, version, scripts, type)
   - Python: `pyproject.toml` or `requirements.txt` + optional `src/`
   - Go: `go.mod`
   - Rust: `Cargo.toml`
4. Create placeholder dirs only if needed (e.g. `src/`, `docs/`, `tests/`)

---

## Step 4: Optional – Add AI Playbook

1. If the user wants this playbook in the new project:
   - Suggest: submodule, or `npx ai-playbook-cli@latest install`, or manual copy
   - Do **not** commit secrets or copy `.cursor/mcp.json` into the new repo
2. If submodule: add `.ai-playbook` and symlink `.cursor/rules`, `.cursor/commands`, `.cursor/docs`
3. Document in README how to run/build and (if applicable) how the playbook was added

---

## Step 5: Initial Commit (Optional)

1. If the directory is already a git repo: suggest an initial commit with message like
   `chore: init project`
2. If not: suggest `git init` and first commit
3. Follow version-management rules: no force push, conventional commit style

---

## Cursor Behavior Rules

- **Do not overwrite** existing files without explicit user confirmation
- **Keep scaffolding minimal** – README, .gitignore, one or two config files
- **Security**: never add real secrets, API keys, or credentials
- **Playbook**: recommend adding this playbook but do not assume; document the option

---

## Usage

- `/init-project` – Interactive: ask project type and language, then scaffold
- `/init-project Next.js app` – Scaffold a minimal Next.js-style project
- `/init-project Python CLI with Click` – Scaffold a minimal Python CLI layout

Use when starting a **new** repo from scratch. For an **existing** codebase, use `/adopt-legacy`
instead.
