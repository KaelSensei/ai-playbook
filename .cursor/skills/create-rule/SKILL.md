---
name: create-rule
description:
  How to write and structure a Cursor rule (.mdc). Use when the user wants to create a new rule, set
  coding standards, or configure AI behavior for a project.
---

# Creating Cursor Rules

Create project rules in `.cursor/rules/` to give the AI persistent context and constraints.

## When to use this skill

- User asks to add a rule, coding standard, or project convention.
- User asks about `.cursor/rules/` or `.mdc` files.
- You need to enforce behavior across all conversations (e.g. "always use TypeScript", "never commit
  to main").

## How this skill is used

**Users do not invoke skills directly.** Skills are reference knowledge that the AI loads
automatically when it detects a matching task, or when a command explicitly says "use the
`create-rule` skill."

- **Automatic:** The AI loads this skill when the user asks to create a rule or mentions `.mdc`
  files.
- **Referenced by:** No specific command -- this is general-purpose expertise.

## Rule file format

Rules are `.mdc` files with YAML frontmatter:

```
.cursor/rules/
  my-rule.mdc
```

```markdown
---
description: One-line description of what this rule does
globs: **/*.ts        # optional – file pattern for scoped rules
alwaysApply: false    # true = always loaded; false = loaded when matching files are open
---

# Rule Title

Rule content: what the AI must do or avoid.
```

### Frontmatter fields

| Field         | Required | Notes                                                            |
| ------------- | -------- | ---------------------------------------------------------------- |
| `description` | Yes      | Short summary; helps the agent decide whether to load this rule. |
| `alwaysApply` | Yes      | `true` = global; `false` = scoped to `globs`.                    |
| `globs`       | No       | Glob pattern(s) for file-scoped rules (e.g. `**/*.py`).          |

### When to use `alwaysApply: true`

- Security policies, commit conventions, documentation rules.
- Anything that must apply **regardless** of which file is open.

### When to use `alwaysApply: false` + `globs`

- Language or framework conventions (e.g. React patterns for `**/*.tsx`).
- File-specific formatting or structure rules.

## Steps to create a rule

1. **Determine purpose**: What should the rule enforce or teach?
2. **Determine scope**: Always apply, or only for certain files?
3. **Choose a filename**: `kebab-case.mdc` (e.g. `typescript-standards.mdc`).
4. **Write frontmatter**: Set `description`, `alwaysApply`, and optionally `globs`.
5. **Write rule body**: Clear, actionable instructions. Use headings and bullet lists.
6. **Save** to `.cursor/rules/<filename>.mdc`.

## Best practices

- **Be specific**: "Use `const` over `let`" is better than "write good code".
- **One concern per rule**: Don't mix security and formatting in one file.
- **Keep rules short**: The agent loads them into context; long rules waste tokens.
- **Reference other rules** if needed: "See also `security.mdc`."
- **No secrets**: Never put tokens, keys, or credentials in rules.

## Examples

**Global rule** (`alwaysApply: true`):

```markdown
---
description: Never commit directly to main or master
alwaysApply: true
---

# Branch Protection

- Never commit directly to `main` or `master`.
- Always use feature branches.
```

**Scoped rule** (`alwaysApply: false`, with `globs`):

```markdown
---
description: React component conventions
globs: **/*.tsx
alwaysApply: false
---

# React Patterns

- Use functional components with hooks.
- Prefer named exports.
```
