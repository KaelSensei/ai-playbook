---
name: release-notes
description:
  How to generate release notes from commits and create a GitHub release. Use when preparing a
  release, writing CHANGELOG entries, or running /release.
---

# Writing Release Notes

How to turn conventional commits into release notes and GitHub releases.

## When to use this skill

- When running `/release [version]`.
- When updating `CHANGELOG.md` manually or via `/changelog`.
- When the user asks "what should the release notes say?"

## How this skill is used

**Users do not invoke skills directly.** Skills are reference knowledge that the AI loads
automatically when it detects a matching task, or when a command explicitly says "use the
`release-notes` skill."

- **Automatic:** The AI loads this skill when preparing a release or updating a changelog.
- **Referenced by:** `/release` -- the command delegates note formatting and CHANGELOG conventions
  to this skill.

## Deriving notes from commits

1. **Get commits since last release:**

   ```bash
   git log <last-tag>..HEAD --pretty=format:"- %s (%h)" --no-merges
   ```

2. **Group by type:**
   - **Features** (`feat:`): New functionality.
   - **Fixes** (`fix:`): Bug fixes.
   - **Other** (`docs:`, `refactor:`, `chore:`, `perf:`, etc.): Group or omit as needed.

3. **Skip noise:**
   - Merge commits (already filtered with `--no-merges`).
   - Pure formatting/style commits (unless relevant).
   - CI-only changes (unless they affect users).

## Release notes format

```markdown
## v1.2.0 – 2026-01-23

### Features

- Add export-context command for AI handoff (abc1234)
- Add /release command for GitHub releases (def5678)

### Fixes

- Fix crash when database file is missing (9ab0123)

### Other

- Update ESLint config (456def7)
- Improve documentation structure (789abc0)
```

### Rules

- **Features first**, then fixes, then other.
- Use imperative mood (same as commit subjects).
- Include short commit hash for traceability.
- Add a date next to the version.
- If there are **breaking changes**, add a `### Breaking Changes` section at the top.

## CHANGELOG.md format

```markdown
# Changelog

## [Unreleased]

- (pending changes go here until next release)

## [1.2.0] – 2026-01-23

### Added

- Export-context command for AI handoff

### Fixed

- Crash when database file is missing

## [1.1.0] – 2026-01-15

...
```

### Keep-a-changelog conventions

- Use `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security` headings.
- Newest release at the top.
- `[Unreleased]` section for unreleased work.

## GitHub release

When using `gh release create`:

```bash
gh release create v1.2.0 \
  --title "v1.2.0" \
  --notes "$(cat release-notes.md)" \
  --target main
```

Or use `--generate-notes` for GitHub's auto-generated notes (less structured but fast).

## Tips

- Write release notes for **users**, not developers. Focus on what changed, not how.
- Link to PRs or issues where helpful.
- If the release is large, add a 1-sentence summary at the top.
