---
name: git-branch-naming
description:
  Branch naming conventions, prefixes, and normalization rules. Use when creating branches,
  validating branch names, or enforcing naming standards.
---

# Git Branch Naming Conventions

How to name, normalize, and validate Git branches consistently.

## When to use this skill

- When running `/create-branch` or `/feature-branch`.
- When `/feature` or `/fix` needs to create a branch automatically.
- When reviewing branch names for consistency.

## Required prefixes

| Prefix      | When to use                             | Example                    |
| ----------- | --------------------------------------- | -------------------------- |
| `feature/`  | New functionality                       | `feature/add-search-reset` |
| `fix/`      | Bug fixes                               | `fix/image-loading-crash`  |
| `refactor/` | Code restructuring (no behavior change) | `refactor/extract-utils`   |
| `docs/`     | Documentation-only changes              | `docs/update-readme`       |
| `chore/`    | Maintenance, config, tooling            | `chore/update-eslint`      |

If a name has no prefix, ask the user which type it is and prepend the correct prefix.

## Naming rules

- **Lowercase only** -- convert uppercase to lowercase.
- **Hyphens** to separate words -- replace spaces and underscores with `-`.
- **No special characters** -- keep only `a-z`, `0-9`, `-`, and `/`.
- **Concise but descriptive** -- 2-5 words after the prefix.
- **Never** use protected names: `main`, `master`, `dev`, `develop`, `release`.

## Normalization steps

Given raw input (e.g. `"Add Search Reset Button"`):

1. Trim whitespace.
2. Convert to lowercase.
3. Replace spaces and underscores with hyphens.
4. Remove characters that are not `a-z`, `0-9`, `-`.
5. Collapse multiple consecutive hyphens into one.
6. Strip leading/trailing hyphens.
7. Prepend prefix if missing (after asking user for type).

**Result:** `feature/add-search-reset-button`

## Validation checklist

- [ ] Not empty after normalization.
- [ ] Not a protected branch name.
- [ ] Starts with a valid prefix (`feature/`, `fix/`, `refactor/`, `docs/`, `chore/`).
- [ ] Does not already exist locally (`git branch --list <name>`).
- [ ] Does not already exist remotely (`git branch -r --list origin/<name>`).

If the branch already exists, offer to switch to it or choose a different name.

## Examples

| Raw input                     | Normalized                        |
| ----------------------------- | --------------------------------- |
| `add export feature`          | `feature/add-export-feature`      |
| `Fix_Image_Loading`           | `fix/image-loading`               |
| `feature/stats-dashboard`     | `feature/stats-dashboard` (as-is) |
| `update readme`               | `docs/update-readme`              |
| `REFACTOR extract DB queries` | `refactor/extract-db-queries`     |
