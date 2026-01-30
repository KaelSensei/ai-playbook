## Annex – Cursor Commands Overview

This annex lists all available Cursor commands provided by the AI Playbook, with a short description
for each.  
Each command is defined in `.cursor/commands/<name>.md` and follows the shared rules in
`.cursor/rules/*.mdc`.

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
| `/audit-code [target]`         | Analyze code quality, security, and adherence to project standards for the selected scope.                                       |
| `/brainstorm [topic]`          | Run an AI-assisted product/feature ideation and planning workflow, turning ideas into actionable tasks.                          |
| `/devops <task>`               | Design or update CI/CD and infrastructure (GitHub Actions, Docker, Kubernetes, etc.) in a security-first way.                    |
| `/magic-wand [issue]`          | Perform deep, expert-level debugging and problem-solving when normal commands are not enough.                                    |
| `/create-command <name> [...]` | Generate a new Cursor command file that matches the project’s command structure and rules.                                       |
| `/add-commit-push [message]`   | Run project checks, stage all changes, create a conventional commit (using the optional message), and push the current branch.   |
| `/git [message]`               | Same as `/add-commit-push`: stage, conventional commit, and push to the current branch.                                          |
| `/create-user-guide`           | Generate or regenerate user-facing documentation so end users know how to use the app.                                           |
| `/update-user-guide`           | Add or update sections in `USER_GUIDE.md` to keep it in sync with the app (e.g. after a new feature).                            |

> For full behavior, see each command’s markdown file in `.cursor/commands/`.
