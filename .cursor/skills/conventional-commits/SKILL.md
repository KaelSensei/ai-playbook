---
name: conventional-commits
description:
  How to write conventional commit messages. Use when committing changes, reviewing commit history,
  or when the user asks about commit message format.
---

# Conventional Commits

A standard for writing commit messages that are human-readable, machine-parseable, and useful for
changelogs and releases.

## When to use this skill

- Every time you run `git commit`.
- When reviewing commit messages in a PR.
- When the user asks "how should I write this commit message?"

## Format

```
type(scope): subject

body (optional)

footer (optional)
```

### Type (required)

| Type        | When to use                                             | Example                                  |
| ----------- | ------------------------------------------------------- | ---------------------------------------- |
| `feat:`     | New feature or functionality                            | `feat: add search reset button`          |
| `fix:`      | Bug fix                                                 | `fix: resolve image loading crash`       |
| `docs:`     | Documentation only                                      | `docs: update installation guide`        |
| `refactor:` | Code change that neither fixes a bug nor adds a feature | `refactor: extract utils from component` |
| `test:`     | Adding or updating tests                                | `test: add unit tests for parser`        |
| `chore:`    | Maintenance, config, dependencies                       | `chore: update eslint config`            |
| `perf:`     | Performance improvement                                 | `perf: cache database queries`           |
| `style:`    | Formatting, whitespace (no logic change)                | `style: fix indentation in module`       |
| `ci:`       | CI/CD configuration changes                             | `ci: add GitHub Actions workflow`        |
| `build:`    | Build system or external dependencies                   | `build: upgrade webpack to v5`           |
| `revert:`   | Revert a previous commit                                | `revert: revert feat: add X`             |

### Scope (optional)

A noun describing the section of the codebase:

- `feat(auth): add OAuth2 login`
- `fix(api): handle timeout errors`

### Subject (required)

- Imperative mood: "add", "fix", "update" (not "added", "fixes", "updating").
- Lowercase first letter.
- No period at the end.
- Max ~72 characters.

### Body (optional)

- Explain **why**, not **what** (the diff shows what).
- Wrap at 72 characters per line.
- Separate from subject with a blank line.

### Footer (optional)

- `BREAKING CHANGE: description` for breaking changes.
- `Closes #123` or `Fixes #456` to reference issues.

## Examples

**Simple:**

```
feat: add export-context command for AI handoff
```

**With body:**

```
fix: prevent crash when database file is missing

The app crashed on first launch because the database file did not exist
yet. Added a check to create it before opening.
```

**Breaking change:**

```
feat: change config format from JSON to YAML

BREAKING CHANGE: config.json is no longer supported; migrate to config.yaml.
```

## Quick rules

- One commit per logical change.
- Don't mix unrelated changes in one commit.
- Prefer `feat:` for new features (even small ones) over `chore:`.
- Use `docs:` for documentation-only changes (no code).
- If in doubt between `fix:` and `refactor:`: does it change behavior? → `fix:`. Does it not? →
  `refactor:`.
