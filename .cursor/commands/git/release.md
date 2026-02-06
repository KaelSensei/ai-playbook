# Release Command – Release Notes and GitHub Release

When `/release [version]` is invoked, generate release notes from commits since the last tag and
create a GitHub release.

**Skills used:** `release-notes` (notes format, CHANGELOG conventions, GitHub release flags),
`conventional-commits` (commit type grouping).

**Prerequisite:** GitHub CLI (`gh`) must be installed and authenticated (`gh auth status`).

---

## Step 1: Load Context

1. Assume project root as working directory
2. Load rules from `.cursor/rules/*.mdc`
3. Read `CHANGELOG.md` and `package.json` (version) if present
4. Verify `gh auth status` -- if not authenticated, **stop and instruct** the user

---

## Step 2: Determine Version

1. Fetch tags: `git fetch --tags origin && git tag -l --sort=-v:refname`
2. If user provided `[version]`: normalize to `vX.Y.Z`
3. If not: suggest next version from last tag or `package.json`, **ask user to confirm**
4. Define commit range: `<last-tag>..HEAD`

---

## Step 3: Generate Release Notes

Use the **`release-notes` skill** to:

1. Get commits: `git log <last-tag>..HEAD --pretty=format:"- %s (%h)" --no-merges`
2. Group by conventional commit type (features, fixes, other)
3. Format using the release notes template from the skill
4. Optionally write to `release-notes.md` for user review

---

## Step 4: Create Tag

If tag does not already exist:

```bash
git tag -a v1.0.1 -m "Release v1.0.1"
git push origin v1.0.1
```

---

## Step 5: Create GitHub Release

```bash
gh release create v1.0.1 --title "v1.0.1" --notes-file release-notes.md
```

Optional flags: `--draft`, `--target main`, `--generate-notes`.

If `gh` is missing or auth fails: **stop and report**.

---

## Step 6: Update Local Docs

If project keeps `CHANGELOG.md`:

1. Move "Unreleased" entries under new version heading (per `release-notes` skill format)
2. If `package.json` has version field, bump it
3. Commit: `chore: bump version to X.Y.Z for release`

---

## Step 7: Confirm

1. Verify: `gh release view v1.0.1`
2. Report: version released, link to GitHub release, remind to pull tags

---

## Cursor Behavior Rules

- Do not create a release without a clear version (ask if missing)
- Use `release-notes` skill for formatting
- Never force-push or overwrite an existing tag
- If `gh` is missing, stop and instruct -- do not guess credentials
- Release from `main` unless user specifies another branch

---

## Usage

- `/release` -- Auto-detect version, generate notes, create release
- `/release 1.2.0` -- Create release v1.2.0
- `/release v2.0.0` -- Create release v2.0.0
