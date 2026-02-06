---
name: create-command
description:
  Deep expertise for creating a new Cursor command. Use when the user wants to add a slash command
  to the playbook, or asks how commands are structured.
---

# Creating Cursor Commands

Commands are markdown files in `.cursor/commands/` that define step-by-step workflows the AI
executes when the user types `/command-name`.

## When to use this skill

- User asks to create a new slash command.
- User wants to understand command structure or conventions.
- Complements the `/create-command` command with deeper guidance.

## File location and naming

Commands live under `.cursor/commands/<category>/<name>.md`:

| Category     | Purpose                                         | Examples                          |
| ------------ | ----------------------------------------------- | --------------------------------- |
| `bootstrap/` | Project onboarding, setup, resume               | start, continue, init-project     |
| `git/`       | Version control, branching, PRs, releases       | git, create-branch, release       |
| `workflow/`  | Feature, fix, refactor, beautify, clean-code    | feature, fix, refactor            |
| `quality/`   | Code audit, debugging, repo cleanup             | audit-code, magic-wand            |
| `docs/`      | Documentation generation, user guides, commands | create-user-guide, export-context |
| `devops/`    | CI/CD, infrastructure, pipelines                | devops                            |
| `ideation/`  | Brainstorming, planning                         | brainstorm                        |

**Naming**: kebab-case, lowercase (e.g. `export-context.md` → `/export-context`).

## Required structure

Every command should include these sections:

1. **Title**: `# Command Name – Brief Description`
2. **Trigger line**: `When /command-name is invoked, immediately execute the following steps.`
3. **Step 1: Load project context** – Load rules, read docs, check branch.
4. **Steps 2–N: Command-specific logic** – The actual work.
5. **Validation step** – Verify the work is correct.
6. **Documentation step** – Update PROGRESS, CHANGELOG, USER_GUIDE if relevant.
7. **Commit & push step** – `git add -A`, `git commit -m "type: ..."`, `git push`.
8. **Cursor behavior rules** – Constraints (e.g. "never commit to main").
9. **Usage section** – Examples of how to invoke the command.

## Rules references

Every command should reference the project rules it must follow:

```markdown
Reference:

- `.cursor/rules/security.mdc`
- `.cursor/rules/documentation.mdc`
- `.cursor/rules/version-management.mdc`
```

## After creating a command

1. **Update `COMMANDS.md`**: Add the command to both the summary table and the "All commands" table.
2. **Update `.cursor/docs/COMMANDS_STRUCTURE.md`**: Add it to the correct category.
3. **Commit and push**: `docs: add <command-name> command`.

## Tips

- Read 2–3 existing commands before writing a new one (e.g. `feature.md`, `fix.md`, `git.md`).
- Keep steps numbered and concise; the agent executes them literally.
- If the command modifies files, it must end with commit+push (per `version-management.mdc`).
- If the command is read-only (e.g. `/export-context`), commit is optional.
