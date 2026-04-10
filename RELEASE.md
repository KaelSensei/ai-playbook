# Releasing

This document describes how versions and releases work in the AI Playbook. If you're a contributor,
read [CONTRIBUTING.md](CONTRIBUTING.md) first. This file is for maintainers cutting a release.

---

## Two-tier versioning

The repository contains two artifacts that are versioned **independently**:

| Artifact              | Version source        | Distribution       | Semver rules        |
| --------------------- | --------------------- | ------------------ | ------------------- |
| **Playbook**          | Git tag (`v0.2.0`, …) | Git submodule, CLI | See below           |
| **`ai-playbook-cli`** | `cli/package.json`    | npm                | Standard npm semver |

Projects consuming the playbook typically pin a git tag as a submodule or check out a specific
commit; the CLI is consumed via `npx ai-playbook-cli@<version>`. The two can evolve on different
schedules.

---

## Playbook semver rules

The playbook is **content**, not code, so semver maps to behavior-shaping impact rather than API
surface. Use the following rubric when picking the next version.

### MAJOR (`1.0.0` → `2.0.0`)

Bump MAJOR when a change **breaks existing installations**. Examples:

- Removing or renaming a rule, command, or skill that projects depend on
- Changing a command's workflow in a way that invalidates existing usage (e.g. `/feature` no longer
  creates a branch)
- Restructuring `.agents/` in a way that breaks the symlink / submodule layout
- Dropping support for a target AI tool (Claude Code, Cursor, etc.)

### MINOR (`0.2.0` → `0.3.0`)

Bump MINOR for **additive, backwards-compatible** changes:

- New rule, command, skill, or multi-agent setup
- New option on an existing command
- Significantly improved documentation that changes how the playbook is positioned
- CLI feature additions (when the CLI version is kept in lockstep with the playbook, not independent
  — which is **not** the current model)

### PATCH (`0.2.0` → `0.2.1`)

Bump PATCH for **bug fixes, typos, or clarifications**:

- Fixing a broken link
- Fixing a command that silently did the wrong thing
- Correcting a rule that caused the AI to behave incorrectly
- Fixing a script in a multi-agent setup's `install.sh`

### Pre-1.0.0

While we're below `1.0.0`, we reserve the right to make breaking changes in MINOR bumps. This is a
deliberate choice — the playbook is still finding its shape. Once we hit `1.0.0`, MAJOR bumps will
be used strictly.

---

## Release process

### Prerequisites

- You are on `main` with a clean working tree
- All PRs intended for this release are merged
- CI is green on `main`
- You have push access and `gh` is authenticated

### Steps

1. **Pick the version.**

   Apply the rubric above. Err on the side of a bigger bump — users can always ignore extra caution,
   but they can't unread a silent breaking change.

2. **Update `CHANGELOG.md`.**

   Move everything under `## [Unreleased]` into a new `## [X.Y.Z] — YYYY-MM-DD` section. Leave
   `[Unreleased]` empty with the standard scaffolding. Update the link references at the bottom of
   the file:

   ```markdown
   [Unreleased]: https://github.com/KaelSensei/ai-playbook/compare/vX.Y.Z...HEAD
   [X.Y.Z]: https://github.com/KaelSensei/ai-playbook/compare/vPREV...vX.Y.Z
   ```

   Commit with a conventional message:

   ```bash
   git commit -m "chore(release): prepare vX.Y.Z"
   ```

3. **Open and merge the release PR.**

   ```bash
   git push -u origin chore/release-vX.Y.Z
   gh pr create --base main --title "chore(release): prepare vX.Y.Z" --body "Release notes: see CHANGELOG.md"
   ```

   Wait for CI to go green and merge the PR.

4. **Tag the release commit.**

   After the PR merges:

   ```bash
   git checkout main
   git pull origin main
   git tag -a vX.Y.Z -m "Release vX.Y.Z"
   git push origin vX.Y.Z
   ```

5. **GitHub Release.**

   The `.github/workflows/release.yml` workflow fires on `v*` tag pushes and creates a GitHub
   Release automatically, using the `[X.Y.Z]` section of `CHANGELOG.md` as the release body. Check
   the Releases page and edit the notes if anything looks off.

### Rollback

If something is wrong with a tagged release:

1. **Do not delete the tag.** Tags are part of the public contract; deleting one can break
   downstream submodule pins.
2. Cut a PATCH release with the fix, referencing the broken release in the CHANGELOG notes.

The only case where a tag should be deleted is if the tag is less than one hour old and provably has
zero downstream consumers. Even then, prefer a PATCH.

---

## Releasing `ai-playbook-cli`

The CLI has its own lifecycle and is **not tied to playbook version tags**. To cut a CLI release:

1. Bump `cli/package.json` `version` (npm semver rules).
2. Update `CHANGELOG.md` with a CLI-specific entry under `### Added` / `### Fixed`, prefixed `cli: `
   so it's scannable.
3. Commit, merge, and let CI verify the test suite passes.
4. From `main`:
   ```bash
   cd cli
   npm publish
   ```
   The `prepublishOnly` script runs `npm run build` automatically.
5. Tag the CLI release separately using `cli-vX.Y.Z` to avoid colliding with playbook tags:
   ```bash
   git tag -a cli-vX.Y.Z -m "CLI release vX.Y.Z"
   git push origin cli-vX.Y.Z
   ```

See [`cli/PUBLISH.md`](cli/PUBLISH.md) for the full npm publish checklist.

---

## What does _not_ trigger a release

- Fixing a typo in a README
- Reformatting files (prettier / eslint)
- Updating tooling versions that are not part of the published surface
- Internal refactors of `.github/` workflows

Batch these into the next real release instead of cutting one just for them.
