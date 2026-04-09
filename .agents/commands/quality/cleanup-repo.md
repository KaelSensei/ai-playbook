# Cleanup Repo Command – Repository Organization and Structure Cleanup

When `/cleanup-repo` is invoked, analyze, organize, and clean up the repository structure.

**Skills used:** `repo-organization` (where files belong and reorganization patterns).

---

## Step 1: Load Context

1. Assume project root as working directory
2. Load rules from `.cursor/rules/*.mdc`
3. Read `README.md`, progress docs, `.cursor/docs/DOCUMENTATION_STRUCTURE.md` (if exists)
4. Identify current Git branch (should be a refactor branch, not `main`)

---

## Step 2: Analyze Current Structure

1. Scan the repository for all files and directories
2. Use the **`repo-organization` skill** to identify:
   - Files in wrong locations (docs in root, scripts scattered, etc.)
   - Duplicate or unused files
   - Missing standard directories
3. Summarize findings to the user

---

## Step 3: Plan Reorganization

1. Map current paths to target paths (per `repo-organization` skill conventions)
2. Check for file references that will need updating (README links, imports, scripts)
3. Verify no critical files will break (build configs, CI, package.json)
4. Present the plan to the user before proceeding

---

## Step 4: Security Check

Before moving files:

1. Verify files are not referenced in build or CI configs
2. Verify `.gitignore` will not be affected
3. Do not move essential root-level config files (per `repo-organization` skill)

---

## Step 5: Execute

1. Create target directories as needed
2. Move files with `git mv` (preserves history)
3. Delete unused/temporary files
4. Update all references (README links, import paths, script paths)
5. Verify no broken links remain

---

## Step 6: Update Documentation

1. Update `README.md` with new file paths
2. Update progress docs with reorganization entry
3. Update or create structure documentation

---

## Step 7: Validate

1. Check `git status` -- verify no unintended deletions
2. Verify build/scripts still work
3. Search for old paths that may still be referenced

---

## Step 8: Commit & Push

```bash
git add -A
git commit -m "refactor: reorganize repository structure"
git push origin $(git branch --show-current)
```

---

## Cursor Behavior Rules

- Use `git mv` to preserve file history
- Always update references after moving files
- Ask before moving files you are unsure about
- Consult `repo-organization` skill for where files belong
- Every `/cleanup-repo` must result in a commit unless explicitly blocked

---

## Usage

- `/cleanup-repo` -- Analyze and organize the entire repository
