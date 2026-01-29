## Annex – Cursor Commands Overview

This annex lists all available Cursor commands. Commands are grouped under
`.cursor/commands/<category>/` (see
[.cursor/docs/COMMANDS_STRUCTURE.md](.cursor/docs/COMMANDS_STRUCTURE.md)). Each command follows the
shared rules in `.cursor/rules/*.mdc`.

### Folder structure

- **bootstrap/** – start, continue, init-project, adopt-legacy
- **git/** – add-commit-push, git, create-branch, feature-branch, merge-branch-into-main,
  merge-branch-into-dev
- **workflow/** – feature, fix, refactor, beautify, clean-code
- **quality/** – audit-code, magic-wand, cleanup-repo
- **docs/** – create-user-guide, update-user-guide, create-command
- **devops/** – devops
- **ideation/** – brainstorm

### All commands

| Command                        | Description                                                                           |
| ------------------------------ | ------------------------------------------------------------------------------------- |
| **Bootstrap**                  |                                                                                       |
| `/start`                       | Bootstrap project context, load rules and key docs, pick next task.                   |
| `/continue`                    | Resume work on this project; reload context and pick next pending task.               |
| `/init-project [description]`  | Scaffold a new project from scratch (README, .gitignore, optional playbook).          |
| `/adopt-legacy [scope]`        | Onboard an existing/legacy codebase: analyze, document, optionally add playbook.      |
| **Git**                        |                                                                                       |
| `/add-commit-push [message]`   | Run checks, stage, conventional commit, push current branch.                          |
| `/git [message]`               | Same as `/add-commit-push`.                                                           |
| `/create-branch`               | Interactively create a new branch (feature/fix/refactor/docs).                        |
| `/feature-branch <branch>`     | Create and normalize a feature branch with remote tracking.                           |
| `/merge-branch-into-main [b]`  | Safely merge a branch into `main` with pre-merge checks.                              |
| `/merge-branch-into-dev [b]`   | Safely merge a branch into `dev`.                                                     |
| **Workflow**                   |                                                                                       |
| `/feature <description>`       | Plan and implement new functionality end-to-end.                                      |
| `/fix <issue>`                 | Diagnose and fix a specific issue with security and regression checks.                |
| `/refactor <description>`      | Non-functional improvements (structure, clarity) without changing behavior.           |
| `/beautify <target>`           | Improve UI/UX for a component or screen.                                              |
| `/clean-code [target]`         | Remove dead code, unused variables, technical debt in a focused area.                 |
| **Quality**                    |                                                                                       |
| `/audit-code [target]`         | Analyze code quality, security, and adherence to project standards.                   |
| `/magic-wand [issue]`          | Deep expert-level debugging when normal approaches fail.                              |
| `/cleanup-repo`                | Reorganize repo structure (docs, scripts, assets) into a clean layout.                |
| **Docs**                       |                                                                                       |
| `/create-user-guide`           | Generate or regenerate user-facing documentation.                                     |
| `/update-user-guide`           | Add or update sections in `USER_GUIDE.md`.                                            |
| `/create-command <name> [...]` | Generate a new Cursor command file following project structure.                       |
| **Devops**                     |                                                                                       |
| `/devops <task>`               | Design or update CI/CD and infrastructure (GitHub Actions, Docker, Kubernetes, etc.). |
| **Ideation**                   |                                                                                       |
| `/brainstorm [topic]`          | AI-assisted feature ideation and planning workflow.                                   |

> For full behavior, see each command’s markdown file under `.cursor/commands/<category>/`.
