# Release Command – Release Notes from Commits and Create GitHub Release

When `/release [version]` is invoked, generate release notes from all commits since the last release
(tag) and create a new release on GitHub.

**Mechanism:** Uses **GitHub CLI** (`gh`) to create the release. This is not a GitHub Action; it
runs locally. You can optionally automate releases with a GitHub Action that runs on tag push (see
Notes below).

---

## Step 1: Load Project Context & Follow All Rules

1. Assume the project root as the working directory
2. **Load and respect** Cursor rules from `.cursor/rules/*.mdc`:
   - `version-management.mdc` – Git workflow (no force push to main, conventional commits)
   - `documentation.mdc` – Changelog/release note alignment
3. Read `CHANGELOG.md` and `package.json` (version) if present
4. **Prerequisite:** GitHub CLI must be installed and authenticated (`gh auth status`). If not,
   **stop and instruct** the user to install and log in: https://cli.github.com/

---

## Step 2: Determine Last Release and New Version

1. **List existing tags** (releases):

   ```bash
   git fetch --tags origin
   git tag -l --sort=-v:refname
   ```

   - If no tags exist, "last release" = first commit (or root). Use `git log --oneline` and include
     all commits for the first release.

2. **Parse version from command:**
   - If user provided `[version]` (e.g. `v1.2.0` or `1.2.0`), use it (normalize to `v1.2.0`).
   - If not provided:
     - Suggest next version from `package.json` (e.g. bump patch: `1.0.0` → `1.0.1`) or from last
       tag (e.g. `v1.0.0` → `v1.0.1`).
     - **Ask user** to confirm version or provide it.

3. **Define range for release notes:**
   - Last tag: `LAST_TAG` (e.g. `v1.0.0`). If no tags, use `--root` or first commit hash.
   - Range: `LAST_TAG..HEAD` (or `main`) for commits since last release.

---

## Step 3: Generate Release Notes from Commits

1. **Get commits since last release:**

   ```bash
   git log LAST_TAG..HEAD --pretty=format:"- %s (%h)" --no-merges
   ```

   Or use current branch / `main`:

   ```bash
   git log LAST_TAG..origin/main --pretty=format:"- %s (%h)" --no-merges
   ```

2. **Format release notes** (recommended):
   - Group by conventional commit type: `feat:`, `fix:`, `docs:`, `chore:`, etc.
   - Example structure:

   ```markdown
   ## What's Changed

   ### Features

   - feat: add Goals tab and gamification (#123)
   - feat: i18n EN/FR

   ### Fixes

   - fix: Settings scroll and empty state size

   ### Documentation

   - docs: update USER_GUIDE and CHANGELOG
   ```

   - Optionally derive from `CHANGELOG.md` **Unreleased** section if the project keeps it up to
     date; otherwise use commit list.

3. **Write notes to a file** (e.g. `release-notes.md`) so the user can edit before publishing, or
   pass directly to `gh release create`.

---

## Step 4: Create Tag and Push (If Not Already Tagged)

1. **Ensure the release ref exists on the remote:**
   - Typically release from `main`. Check: `git branch --show-current` or require `main` for
     release.

2. **Create the tag locally** (if creating a new release):

   ```bash
   git tag -a v1.0.1 -m "Release v1.0.1"
   git push origin v1.0.1
   ```

   - Or use a lightweight tag if preferred; annotated is recommended for releases.

3. **If tag already exists**, skip tag creation and use existing tag for `gh release create`.

---

## Step 5: Create the Release on GitHub

1. **Create release with GitHub CLI:**

   ```bash
   gh release create v1.0.1 --title "v1.0.1" --notes-file release-notes.md
   ```

   Or with inline notes:

   ```bash
   gh release create v1.0.1 --title "Release v1.0.1" --notes "## What's Changed
   - feat: ...
   - fix: ..."
   ```

2. **Optional flags:**
   - `--draft` – Create as draft so the user can review on GitHub before publishing.
   - `--target main` – If creating from a different branch.
   - `--generate-notes` – Let GitHub auto-generate notes from PRs/commits (alternative to manual
     notes).

3. **If `gh` is not installed or auth fails:**
   - **Stop** and report: user must install GitHub CLI and run `gh auth login`.
   - Provide link:
     https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository

---

## Step 6: Update Local Docs (If Required)

1. If the project keeps `CHANGELOG.md` with an **Unreleased** section:
   - Move "Unreleased" entries under a new `## [v1.0.1]` (or equivalent) and update "Unreleased" for
     next time.
2. If `package.json` has a `version` field, update it to match the release (e.g. `1.0.1`) and
   commit:

   ```bash
   git add package.json CHANGELOG.md
   git commit -m "chore: bump version to 1.0.1 for release"
   git push origin main
   ```

   - Only do this if the project convention is to bump version in repo at release time.

---

## Step 7: Confirm and Report

1. **Verify release exists:** Open `https://github.com/<owner>/<repo>/releases` or run
   `gh release view v1.0.1`.
2. **Report to user:**
   - Version released (e.g. `v1.0.1`).
   - Link to the new release on GitHub.
   - Remind to pull tags elsewhere if needed: `git pull --tags origin`.

---

## Cursor Behavior Rules

- **Do not** create a release or tag without a clear version (ask if missing).
- **Prefer** generating notes from commits; optionally align with `CHANGELOG.md`.
- **Never** force-push or overwrite an existing release tag.
- If `gh` is missing or unauthenticated, **stop and instruct** the user; do not guess credentials.
- Releasing from `main` is recommended unless the user specifies another branch.

---

## Usage

Use `/release [version]` to:

- Generate release notes from commits since the last Git tag.
- Create a new Git tag (if not present) and push it.
- Create a GitHub Release with those notes via GitHub CLI.

**Examples:**

- `/release` – Determine next version from last tag or package.json, generate notes, then ask for
  confirmation before creating tag and release.
- `/release 1.2.0` – Create release `v1.2.0` with notes from commits since last tag.
- `/release v2.0.0` – Same with version `v2.0.0`.

---

## Notes: GitHub Actions (Optional)

Releases can also be automated with **GitHub Actions**:

- **When:** On push of a version tag (e.g. `v*`) or when a "Release" workflow is triggered.
- **What:** A workflow runs that builds artifacts (e.g. APK, binaries), then uses
  `gh release create` (or the GitHub API) to create the release and upload assets.
- **Why:** No need to run `gh` locally; tag push from CI or from local triggers the release.

This command focuses on **local** release creation with `gh`. If the project later adds a
`.github/workflows/release.yml`, the same convention (tags, CHANGELOG, version in package.json) can
be reused there.

---

## Integration with Project Rules

- `.cursor/rules/version-management.mdc` – Tag and release workflow; no force push.
- `.cursor/rules/documentation.mdc` – Keep CHANGELOG and release notes aligned when updating.
