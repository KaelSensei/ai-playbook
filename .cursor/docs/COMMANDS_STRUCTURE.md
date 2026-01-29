# Commands Folder Structure

Commands are organized under `.cursor/commands/` by category. Slash command names are unchanged
(e.g. `/feature`, `/fix`); the folder layout is for maintainability only.

## Folder Layout

```
.cursor/commands/
├── bootstrap/     # Project onboarding and setup
├── git/           # Version control and branching
├── workflow/      # Feature, fix, refactor, beautify, clean-code
├── quality/       # Audit, magic-wand, cleanup-repo
├── docs/          # User guide, create-command
├── devops/        # CI/CD and infrastructure
└── ideation/      # Brainstorm and planning
```

## Categories

| Folder        | Purpose                                                                     |
| ------------- | --------------------------------------------------------------------------- |
| **bootstrap** | Start a session, continue work, init a new project, adopt a legacy codebase |
| **git**       | Add/commit/push, create branch, feature-branch, merge into main/dev         |
| **workflow**  | Feature, fix, refactor, beautify, clean-code                                |
| **quality**   | Audit code, magic-wand (deep debug), cleanup-repo                           |
| **docs**      | Create/update user guide, create new Cursor commands                        |
| **devops**    | CI/CD, Docker, Kubernetes, GitHub Actions                                   |
| **ideation**  | Brainstorm and feature planning                                             |

## File Paths

- Commands live in `.cursor/commands/<category>/<name>.md`.
- The slash command is derived from the filename (e.g. `feature.md` → `/feature`).
- If your Cursor version only discovers top-level `.md` files, use a flat layout or symlink each
  command into `.cursor/commands/` (e.g. `feature.md` → `workflow/feature.md` symlinked as
  `feature.md` in the root of commands).

## Adding a New Command

1. Choose the category (bootstrap, git, workflow, quality, docs, devops, ideation).
2. Create `.cursor/commands/<category>/<command-name>.md` following existing command structure.
3. Update `COMMANDS.md` in the repo root with the new command and description.
