# Start Command - Project Bootstrap

When `/start` is invoked, immediately execute these steps:

## Step 1: Project Context

1. Assume the project root directory as the working context
2. Use the project-level rules in `.cursor/rules/*.mdc`
3. Identify the project structure and type (web app, mobile app, library, etc.)

## Step 2: Load Core Documentation

1. Read and internalize these files (if they exist), in this order:
   - `README.md`
   - Project-specific architecture documentation
   - Development plan or roadmap documentation
   - Progress tracking documentation (e.g., `PROGRESS.md`, `CHANGELOG.md`)
   - Deployment documentation (if applicable)
2. Then load Cursor rules from `.cursor/rules/*.mdc`
3. Set the working context to the project root

## Step 3: Bootstrap Project Context

1. From the docs above, infer:
   - The current milestone or phase
   - The next concrete feature or fix
2. Prefer:
   - Steps listed as next in development plan documentation
   - Explicit TODO / next items in progress documentation

## Step 4: Summarize and Start Working

Without asking for confirmation:

1. Summarize:
   - Overall goal: **Project purpose and key constraints**
   - Current milestone and any relevant constraints
2. List all documents that were loaded
3. Choose the **next concrete task** based on the docs (feature, bugfix, refactor, or deployment
   work)
4. Immediately start implementing that task, following:
   - The tech‑stack rules (project-specific technical constraints)
   - The security rules (no unsafe network behavior, no dynamic code)
   - The version‑management rules (commit + push after each meaningful chunk of work)

## Usage

Type `/start` in the Cursor chat when opening a project in a new session.

**Examples:**

- `/start` -- Load project context and begin working on the next task

**Typical flow:**

```
User: /start
AI:   Loaded README.md, PROGRESS.md, architecture docs.
      Current milestone: v1.2 -- search improvements.
      Next task: add search reset button.
      Starting implementation now...
```

**When to use:**

- First time opening a project in Cursor
- Starting a new work session
- After a long break from the project

**Related commands:**

- `/continue` -- Similar but lighter; for resuming after a short break
- `/feature <description>` -- For implementing a specific feature you already have in mind
