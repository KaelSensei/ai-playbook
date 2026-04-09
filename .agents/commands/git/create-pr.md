# Create PR Command – Open a pull request from current branch to target branch

When `/create-pr <target-branch>` is invoked, open a pull request from the **current branch** (head)
to the **target branch** (base). Example: `/create-pr dev` creates a PR from current branch into
`dev`.

Reference:

- `.cursor/rules/version-management.mdc`
- `.cursor/rules/security.mdc`
- `.cursor/rules/documentation.mdc`

---

## Step 1: Load project context

1. Assume the project root as the working directory
2. Load and respect all Cursor rules from `.cursor/rules/*.mdc`
3. Identify the current Git branch and the remote (e.g. `origin`)

---

## Step 2: Parse and validate

1. **Parse the target branch** from the user input after `/create-pr` (e.g. `dev`, `main`).
2. **Require a target branch**: If none was provided, stop and ask: “Which branch do you want to
   open the PR into? (e.g. `dev`, `main`)”
3. **Resolve target branch**:
   - Use the name as given if it looks like a branch (no leading slash, no URLs).
   - Normalize to lowercase if your conventions use lowercase branch names.
4. **Current branch**:
   - Get with: `git branch --show-current`
   - If current branch is `main` or `master`, **warn** that creating a PR from the default branch is
     unusual; continue only if the user clearly intends it (e.g. for a “reverse” PR).

---

## Step 3: Ensure current branch is pushed

1. Check whether the current branch has uncommitted changes:
   - If yes, **stop and tell the user** to commit and push first (or use `/git`), then run
     `/create-pr <target>` again.
2. Check if the current branch exists on the remote and is up to date:
   - `git status` (e.g. “Your branch is ahead of 'origin/…' by N commits”)
   - If the branch is not pushed or is ahead of the remote, **push it**:
     - `git push -u origin $(git branch --show-current)` (if upstream not set)
     - or `git push origin $(git branch --show-current)`
3. If push fails (e.g. branch protection), report the error and stop.

---

## Step 4: Open the pull request

1. **If GitHub CLI (`gh`) is available**:
   - Run:
     ```bash
     gh pr create --base <target-branch> --head $(git branch --show-current)
     ```
   - If `gh` prompts for title/body, use a sensible default title (e.g. “PR: <current-branch> →
     <target-branch>”) and empty or minimal body, unless the user has specified otherwise.
   - Report success and print the PR URL (e.g. from `gh pr view --web` or command output).
2. **If `gh` is not available**:
   - Build the GitHub PR URL. You need:
     - Repository: from `git remote get-url origin` (e.g. `github.com/owner/repo` → `owner/repo`)
     - Current branch (head)
     - Target branch (base)
   - Standard GitHub “new PR” URL:
     - `https://github.com/<owner>/<repo>/compare/<base>...<head>?expand=1`
   - Example: `https://github.com/owner/repo/compare/dev...feature/my-feature?expand=1`
   - **Output this URL** and tell the user to open it in the browser to create the PR.
3. **Other hosts (GitLab, Bitbucket, etc.)**:
   - If `git remote -v` clearly points to GitLab/Bitbucket, output the equivalent “new merge
     request” / “new PR” URL pattern for that host and suggest the user open it manually, or use the
     host’s CLI if the project documents one.

---

## Step 5: Confirm and document

1. Confirm to the user:
   - “PR opened: <current-branch> → <target-branch>” and the URL, or
   - “Open this URL to create the PR: <url>”
2. If the command added or changed anything in the repo (it usually does not), update `COMMANDS.md`
   or project docs as per `.cursor/rules/documentation.mdc`.

---

## Cursor behavior rules

- **Never** push or create a PR without the user having requested it via this command (or
  equivalent).
- **Always** require a target branch for `/create-pr`; do not guess `main` or `dev`.
- **Always** ensure the current branch is pushed before opening or linking to the PR.
- Prefer **`gh pr create`** when available; otherwise provide the **correct compare URL** for the
  host.

---

## Usage

- `/create-pr dev` — Create a PR from current branch into `dev`
- `/create-pr main` — Create a PR from current branch into `main`
- `/create-pr` — No target given → ask: “Which branch do you want to open the PR into? (e.g. `dev`,
  `main`)”

---

## Integration with other commands

- Use **`/git`** or **`/add-commit-push`** first if you have uncommitted changes, then
  **`/create-pr <target>`**.
- After the PR is created, use **`/merge-branch-into-dev`** or **`/merge-branch-into-main`** (or the
  repo’s merge process) to merge when the PR is approved.
