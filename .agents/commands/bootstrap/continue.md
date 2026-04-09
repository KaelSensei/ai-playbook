# Continue Command - Resume Project Work

When `/continue` is invoked, resume work on **this project** by reloading progress and picking the
next pending task.

## Step 1: Project Context

1. Assume the project root directory as the working context
2. Use project rules from `.cursor/rules/*.mdc`

## Step 2: Read Progress Documentation

1. Read project progress documentation (e.g., `PROGRESS.md`, `CHANGELOG.md`)
2. Read development plan documentation (if present)
3. Optionally skim:
   - Architecture documentation
   - Deployment documentation (if currently in a release/deployment phase)

## Step 3: Load Context

1. From progress documentation, extract:
   - Recently completed items
   - Any explicit "Next" / TODO sections
2. From development plan documentation, identify:
   - The current step
   - The next unfinished step(s)
3. Check git status (conceptually):
   - Current branch
   - Uncommitted files
   - Whether there are local changes related to an in-progress feature

## Step 4: Summarize and Proceed

Without asking for confirmation:

1. State:
   - Current branch name
   - Last commit summary (if available)
2. Summarize:
   - What has just been done (from progress documentation)
   - What is clearly pending (from both docs)
3. Choose the **next concrete, bite-sized task**, prioritizing:
   - Finishing an in-progress feature
   - Small fixes before big refactors
4. Start implementing that task immediately, following:
   - Project-specific architectural rules
   - Technical stack conventions
   - Version-management rules (stage → commit with conventional message → push)

## Expected Files

These may live at the project root or in docs/:

- Progress documentation (e.g., `PROGRESS.md`, `CHANGELOG.md`)
- Development plan documentation
- Architecture documentation
- Deployment documentation (if applicable)

## Usage

Type `/continue` in the Cursor chat when you return to a project after a break.

**Examples:**

- `/continue` -- Resume where you left off

**Typical flow:**

```
User: /continue
AI:   Current branch: feature/add-search-reset
      Last commit: "feat: add search input component"
      Completed: search input, reset button UI.
      Next: wire up reset logic and update tests.
      Starting now...
```

**When to use:**

- Returning to a project after a break (same day or next day)
- After switching between projects
- When you want the AI to pick up where it left off without specifying a task

**Related commands:**

- `/start` -- Heavier bootstrap; for first session or after a long break
- `/feature <description>` -- For a specific feature you already have in mind
