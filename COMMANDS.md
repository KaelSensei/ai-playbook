## Annex – Cursor Commands Overview

This annex lists all available Cursor commands. Commands are grouped under
`.cursor/commands/<category>/` (see
[.cursor/docs/COMMANDS_STRUCTURE.md](.cursor/docs/COMMANDS_STRUCTURE.md)). Each command follows the
shared rules in `.cursor/rules/*.mdc`.

| Command                        | Description                                                                                                                      |
| ------------------------------ | -------------------------------------------------------------------------------------------------------------------------------- |
| `/start`                       | Bootstrap project context, load rules and key docs, and prepare the assistant to work on this repo.                              |
| `/feature <description>`       | Plan and implement new functionality end-to-end, following architecture, security, and documentation rules.                      |
| `/fix <issue>`                 | Diagnose and fix a specific issue or bug, with mandatory security and regression checks.                                         |
| `/refactor <description>`      | Perform non-functional code improvements (structure, clarity, maintainability) without changing behavior.                        |
| `/beautify <target>`           | Improve UI/UX for a given component or screen while preserving behavior and performance.                                         |
| `/clean-code [target]`         | Remove dead code, unused variables, debug leftovers, and other technical debt in a focused area.                                 |
| `/cleanup-repo`                | Reorganize repository structure (docs, scripts, assets, test data) into a clean, maintainable layout.                            |
| `/continue`                    | Resume work on this project by reloading context and picking up the next pending task.                                           |
| `/feature-branch <branch>`     | Create and normalize a new feature branch with safe naming conventions and remote tracking.                                      |
| `/create-branch`               | Interactively create a new branch (feature/fix/refactor/docs) from an up-to-date base branch.                                    |
| `/merge-branch-into-main [b]`  | Safely merge a completed branch into `main` with pre-merge checks, security review, and documentation updates.                   |
| `/merge-branch-into-dev [b]`   | Guide a safe merge workflow from a feature branch into `dev`, mirroring the main-merge safety checklist.                         |
| `/create-pr <target-branch>`   | Open a pull request from the current branch into the given target branch (e.g. `dev`, `main`). Uses `gh` or outputs compare URL. |
| `/release [version]`           | Generate release notes from commits since last tag and create a GitHub release (requires `gh`).                                  |
| `/audit-code [target]`         | Analyze code quality, security, and adherence to project standards for the selected scope.                                       |
| `/brainstorm [topic]`          | Run an AI-assisted product/feature ideation and planning workflow, turning ideas into actionable tasks.                          |
| `/devops <task>`               | Design or update CI/CD and infrastructure (GitHub Actions, Docker, Kubernetes, etc.) in a security-first way.                    |
| `/magic-wand [issue]`          | Perform deep, expert-level debugging and problem-solving when normal commands are not enough.                                    |
| `/create-command <name> [...]` | Generate a new Cursor command file that matches the project's command structure and rules.                                       |
| `/add-commit-push [message]`   | Run project checks, stage all changes, create a conventional commit (using the optional message), and push the current branch.   |
| `/git [message]`               | Same as `/add-commit-push`: stage, conventional commit, and push to the current branch.                                          |
| `/create-user-guide`           | Generate or regenerate user-facing documentation so end users know how to use the app.                                           |
| `/update-user-guide`           | Add or update sections in `USER_GUIDE.md` to keep it in sync with the app (e.g. after a new feature).                            |
| `/export-context [path]`       | Summarize the context window into a compressed markdown file for use by another AI agent (handoff).                              |

- **bootstrap/** – start, continue, init-project, adopt-legacy
- **git/** – add-commit-push, git, create-branch, feature-branch, merge-branch-into-main,
  merge-branch-into-dev, create-pr, release
- **workflow/** – feature, fix, refactor, beautify, clean-code
- **quality/** – audit-code, magic-wand, cleanup-repo
- **docs/** – create-user-guide, update-user-guide, create-command, export-context
- **devops/** – devops
- **ideation/** – brainstorm

### All commands

| Command                        | Description                                                                            |
| ------------------------------ | -------------------------------------------------------------------------------------- |
| **Bootstrap**                  |                                                                                        |
| `/start`                       | Bootstrap project context, load rules and key docs, pick next task.                    |
| `/continue`                    | Resume work on this project; reload context and pick next pending task.                |
| `/init-project [description]`  | Scaffold a new project from scratch (README, .gitignore, optional playbook).           |
| `/adopt-legacy [scope]`        | Onboard an existing/legacy codebase: analyze, document, optionally add playbook.       |
| **Git**                        |                                                                                        |
| `/add-commit-push [message]`   | Run checks, stage, conventional commit, push current branch.                           |
| `/git [message]`               | Same as `/add-commit-push`.                                                            |
| `/create-branch`               | Interactively create a new branch (feature/fix/refactor/docs).                         |
| `/feature-branch <branch>`     | Create and normalize a feature branch with remote tracking.                            |
| `/merge-branch-into-main [b]`  | Safely merge a branch into `main` with pre-merge checks.                               |
| `/merge-branch-into-dev [b]`   | Safely merge a branch into `dev`.                                                      |
| `/create-pr <target-branch>`   | Open a PR from current branch into target (e.g. `dev`, `main`).                        |
| `/release [version]`           | Generate release notes from commits since last tag and create a GitHub release (`gh`). |
| **Workflow**                   |                                                                                        |
| `/feature <description>`       | Plan and implement new functionality end-to-end.                                       |
| `/fix <issue>`                 | Diagnose and fix a specific issue with security and regression checks.                 |
| `/refactor <description>`      | Non-functional improvements (structure, clarity) without changing behavior.            |
| `/beautify <target>`           | Improve UI/UX for a component or screen.                                               |
| `/clean-code [target]`         | Remove dead code, unused variables, technical debt in a focused area.                  |
| **Quality**                    |                                                                                        |
| `/audit-code [target]`         | Analyze code quality, security, and adherence to project standards.                    |
| `/magic-wand [issue]`          | Deep expert-level debugging when normal approaches fail.                               |
| `/cleanup-repo`                | Reorganize repo structure (docs, scripts, assets) into a clean layout.                 |
| **Docs**                       |                                                                                        |
| `/create-user-guide`           | Generate or regenerate user-facing documentation.                                      |
| `/update-user-guide`           | Add or update sections in `USER_GUIDE.md`.                                             |
| `/create-command <name> [...]` | Generate a new Cursor command file following project structure.                        |
| `/export-context [path]`       | Compress context window to markdown for another AI agent (handoff).                    |
| **Devops**                     |                                                                                        |
| `/devops <task>`               | Design or update CI/CD and infrastructure (GitHub Actions, Docker, Kubernetes, etc.).  |
| **Ideation**                   |                                                                                        |
| `/brainstorm [topic]`          | AI-assisted feature ideation and planning workflow.                                    |

### Agent Skills

The playbook also includes **agent skills** in `.cursor/skills/`. Skills are loaded on demand when
the AI detects a matching task:

| Skill                   | Purpose                                                       |
| ----------------------- | ------------------------------------------------------------- |
| `create-rule`           | How to write and structure a `.mdc` rule.                     |
| `create-command`        | How to create a new Cursor command.                           |
| `security-review`       | Security checklist before merging a branch.                   |
| `conventional-commits`  | Commit message format (feat/fix/docs/refactor/etc.).          |
| `release-notes`         | How to generate release notes from commits.                   |
| `git-branch-naming`     | Branch naming conventions and normalization rules.            |
| `code-audit`            | Code quality and architecture audit checklist.                |
| `debugging-methodology` | Root-cause analysis for persistent bugs.                      |
| `repo-organization`     | File/folder conventions for repo structure.                   |
| `token-optimization`    | Lightweight, RTK-free token hygiene for commands and context. |

> For full behavior, see each command's markdown file under `.cursor/commands/<category>/`. For
> details on rules, commands, skills, and MCP, see [CONCEPTS.md](CONCEPTS.md).
