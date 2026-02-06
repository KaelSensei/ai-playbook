# Create Command – Generate New Cursor Commands

When `/create-command <command-name> [description]` is invoked, generate a new Cursor command file
following project patterns.

**Skills used:** `create-command` (command structure, required sections, naming, category
placement).

---

## Step 1: Load Context

1. Assume project root as working directory
2. Load rules from `.cursor/rules/*.mdc`
3. Read existing commands in `.cursor/commands/` subfolders to understand patterns
4. Identify current Git branch (should be a feature branch, not `main`)

---

## Step 2: Parse Request

1. Extract command name and optional description
2. Validate per **`create-command` skill**: lowercase, kebab-case, no conflicts
3. Determine category (bootstrap/git/workflow/quality/docs/devops/ideation) -- ask if unclear
4. Target path: `.cursor/commands/<category>/<command-name>.md`

---

## Step 3: Analyze Existing Commands

Load the **`create-command` skill** for:

1. Required structure (title, trigger line, steps, validation, docs, commit, behavior rules, usage)
2. Rules references to include
3. Read 2-3 existing commands for tone and formatting consistency

---

## Step 4: Generate Command File

Create the `.md` file using the template structure from the `create-command` skill. Customize Step
3+ based on the command's specific purpose.

---

## Step 5: Update Docs

1. Add the command to `COMMANDS.md` (both summary table and "All commands" table)
2. Add to `.cursor/docs/COMMANDS_STRUCTURE.md` under the correct category

---

## Step 6: Commit & Push

```bash
git add -A
git commit -m "docs: add <command-name> command"
git push origin $(git branch --show-current)
```

---

## Cursor Behavior Rules

- Follow `create-command` skill for structure and conventions
- Ensure consistency with existing commands
- Every `/create-command` must result in a commit unless explicitly blocked

---

## Usage

- `/create-command test` -- Create a test command
- `/create-command deploy "Deploy to production"` -- Create a deploy command
- `/create-command analyze-code` -- Create an analysis command

---

## External Resources

- [Cursor Commands Documentation](https://cursor.com/fr/docs/context/commands)
- [cursor-commands Repository](https://github.com/hamzafer/cursor-commands/tree/main/.cursor/commands)
- [AIBlueprint](https://github.com/Melvynx/aiblueprint) -- Similar CLI for Claude Code
