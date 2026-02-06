---
name: repo-organization
description:
  File and folder conventions for organizing a repository. Use when running /cleanup-repo or
  deciding where to put files.
---

# Repository Organization

Conventions for organizing files and folders in a clean, maintainable repository.

## When to use this skill

- When running `/cleanup-repo`.
- When deciding where to put a new file.
- When the user asks "where should this file go?"

## Standard directory layout

```
project-root/
  docs/                       # Documentation (non-code)
    setup/                    # Setup and configuration guides
    deployment/               # Deployment instructions
    development/              # Developer guides, troubleshooting
    architecture/             # Architecture docs, diagrams
  scripts/                    # Utility scripts (bash, powershell, node)
    setup/                    # Setup/install scripts
    utils/                    # Helper scripts
  src/                        # Application source code
    assets/                   # Images, fonts, icons
  test-data/                  # Test fixtures and sample data
  .cursor/                    # AI playbook (rules, commands, skills, docs)
```

## Where files belong

| File type                     | Location                              |
| ----------------------------- | ------------------------------------- |
| README, LICENSE, CHANGELOG    | Project root                          |
| Package manager config        | Project root (package.json, go.mod)   |
| Build/tool config             | Project root (.eslintrc, tsconfig)    |
| `.gitignore`, `.editorconfig` | Project root                          |
| Setup/install guides          | `docs/setup/` or `docs/installation/` |
| Deployment guides             | `docs/deployment/`                    |
| Architecture docs             | `docs/architecture/`                  |
| Troubleshooting guides        | `docs/development/`                   |
| Shell/PowerShell scripts      | `scripts/` or `scripts/setup/`        |
| Node utility scripts          | `scripts/utils/`                      |
| App icons and images          | `src/assets/` or `assets/`            |
| Test fixtures / sample data   | `test-data/`                          |
| AI rules (.mdc)               | `.cursor/rules/`                      |
| AI commands (.md)             | `.cursor/commands/<category>/`        |
| AI skills (SKILL.md)          | `.cursor/skills/<name>/`              |

## Files that must stay in root

These files are expected in the project root by tooling:

- `package.json`, `go.mod`, `Cargo.toml`, `pyproject.toml`
- `tsconfig.json`, `.eslintrc.*`, `.prettierrc.*`
- `.gitignore`, `.editorconfig`
- `README.md`, `LICENSE`, `CHANGELOG.md`
- `Dockerfile`, `docker-compose.yml`
- CI config (`.github/workflows/`, `.gitlab-ci.yml`)

Do **not** move these into subfolders.

## Reorganization checklist

When moving files:

- [ ] Use `git mv` (not `mv`) to preserve history.
- [ ] Search for references to moved files (README links, imports, scripts).
- [ ] Update all references after moving.
- [ ] Verify build/scripts still work after moves.
- [ ] Check `.gitignore` still covers the right paths.
- [ ] Do not move files referenced by CI/CD configs without updating those configs.

## Common reorganization patterns

```
Before (scattered)              After (organized)
CONFIG.md                  -->  docs/setup/CONFIG.md
INSTALL_INSTRUCTIONS.md    -->  docs/installation/INSTALL_INSTRUCTIONS.md
DEPLOYMENT.md              -->  docs/deployment/DEPLOYMENT.md
TESTING.md                 -->  docs/development/TESTING.md
setup.ps1                  -->  scripts/setup/setup.ps1
fix-script.ps1             -->  scripts/utils/fix-script.ps1
```

## What to delete

- Old backup files (`*.bak`, `*.old`, `*_copy`).
- Temporary files (`*.tmp`, `.DS_Store`, `Thumbs.db`).
- Duplicate files.
- Files no longer referenced anywhere.
- Empty directories.
