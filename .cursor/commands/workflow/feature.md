# Feature Command – New Functionality Workflow

When `/feature <feature description>` is invoked, immediately execute the following steps.

---

## Step 1: Load Project Context & Follow All Rules

1. Assume the project root as the working directory
2. **Load and strictly follow ALL Cursor rules** from `.cursor/rules/*.mdc`:
   - `security.mdc` - Security requirements
   - `technical-stack.mdc` - Technical stack patterns
   - `documentation.mdc` - Documentation update requirements
   - `version-management.mdc` - Git commit/push workflow
3. Read relevant documentation:
   - `README.md`
   - `PROGRESS.md`
   - Task or requirement documents
   - Architecture and design documents
4. **Identify the current Git branch** (do not assume it is a feature branch yet)
5. **Check for attachments** (images, screenshots, mockups, diagrams):
   - Analyze any visual references provided
   - Extract design intentions, UI layouts, or flows from images
   - Use attachments to clarify requirements and expected behavior
   - If attachments conflict with description, **ask for clarification**

---

## Step 2: Ensure Feature Branch (Mandatory)

**Before any feature work**, ensure you are on a feature branch, not `main` or `master`.

1. **Check current branch**: `git branch --show-current`
2. **If current branch is `main` or `master`**:
   - **Stop** and create a feature branch first using the **`/feature-branch`** workflow:
     - Derive a branch name from the feature description: `feature/<kebab-case>` (e.g.
       `/feature add search reset button` → `feature/add-search-reset-button`).
     - Run the steps from `/feature-branch`:
       - `git checkout main` (or `master`), `git pull origin main`
       - `git checkout -b <branch-name>`
       - `git push -u origin <branch-name>`
     - Tell the user: "Created feature branch `<branch-name>`. Proceeding with feature work."
   - Then continue with Step 3.
3. **If already on a feature branch** (e.g. `feature/...`, `fix/...`, `docs/...`):
   - Proceed directly to Step 3.

**Rule:** Never implement a new feature on `main` or `master`. Always create or use a feature branch
and name it after the feature.

---

## Step 3: Understand and Define the Feature

1. Parse the feature description provided after `/feature`
2. **Incorporate context from any attached images or screenshots**:
   - UI mockups or design references
   - Workflow diagrams
   - Example screens or behavior demonstrations
   - Error states or edge cases shown visually
3. Clearly define:
   - What new behavior is being added
   - What is explicitly out of scope
4. Identify impacted layers:
   - UI components (if applicable)
   - Database schema/queries (if applicable)
   - External data sources (APIs, scraping, etc.)
   - Caching mechanisms
   - TypeScript / JavaScript utilities
   - Other project-specific layers
5. If requirements or scope are unclear (even with attachments), **stop and ask before coding**

---

## Step 4: Architecture & Design Validation

Before writing code:

1. Ensure the feature does **not violate existing architecture**
2. Confirm:
   - Separation of concerns is preserved (UI, data layer, external sources, etc.)
   - Project-specific architectural constraints are maintained
   - Data storage remains single source of truth (when applicable)
   - No shortcuts or hacks are introduced
3. For database changes:
   - Consider migration strategy for existing data
   - Ensure indexes are added for new queries
4. **Validate design consistency** if UI mockups were provided:
   - Check alignment with existing design system
   - Ensure responsive design principles are followed
   - Verify accessibility considerations
5. If the feature conflicts with architecture, **propose an alternative first**

---

## Step 5: Security & MCP Validation (Mandatory)

Before implementation:

1. Treat all new features as **security-sensitive**
2. Review the feature for:
   - New network calls (respect project-defined allowed domains)
   - File system access (respect project constraints)
   - SQL injection risks in new queries (if applicable)
   - User input validation
   - Dependency additions
3. Use security reasoning to:
   - Detect backdoors or hidden logic
   - Prevent supply-chain and dependency attacks
   - Ensure no malicious patterns are introduced
4. If security implications are unclear, **stop and ask before proceeding**

---

## Step 6: Implement the Feature

1. Implement the feature incrementally
2. **Follow visual specifications** from attachments if provided
3. Keep logic explicit, readable, and auditable
4. Avoid clever or condensed code
5. Document any non-obvious behavior inline
6. Do not introduce new dependencies unless strictly necessary and justified

---

## Step 7: Validate Feature Behavior

1. Reason through the new behavior end-to-end
2. Confirm:
   - Existing functionality is unaffected
   - Edge cases are handled explicitly
   - **Visual output matches provided mockups/screenshots** (if applicable)
3. Add or update tests where appropriate
4. If tests are deferred, explain why and what will be tested later

---

## Step 8: Update Documentation & Changelog (Required)

Before committing, **automatically** update (as per `documentation.mdc` rule):

1. **Project progress documentation** (e.g., PROGRESS.md, CHANGELOG.md):
   - Add the new feature to completed list with `[x]` checkbox
   - Update "Last updated" timestamp if present
2. **CHANGELOG.md** (create if missing):
   - Add entry under "## [Unreleased]" or new version
   - Format: `- Added: <feature description>`
3. **USER_GUIDE.md** (user-facing guide):
   - Add or update the section that describes the new feature in user-facing steps (how to use it)
   - Update "Last updated" at the top; create the file with `/create-user-guide` if it does not
     exist
4. **Architecture docs**: If database schema, external data sources, or major UI structure changed
5. **README.md**: If usage or build instructions changed

**Do NOT ask** - update docs and changelog automatically. This is mandatory.

---

## Step 9: Commit & Push (Required – Must Execute)

After completing the feature (or a meaningful incremental step), you **must** run git add, commit,
and push. **Do not consider the feature complete until you have pushed.**

1. **Run project checks first** (if they exist): e.g. `npm run check`, `npm run format`, lint,
   tests.
2. **Stage, commit, and push:**

```bash
git add -A
git commit -m "feat: <clear description of the new feature>"
git push origin $(git branch --show-current)
```

- Never push directly to `main` or `master`
- Always push to the current feature branch
- Large features may be split into multiple incremental commits
- **You must execute these commands**; do not stop after Step 8 without committing and pushing

---

## Cursor Behavior Rules

- **Always ensure a feature branch first** – if on `main` or `master`, create one via
  `/feature-branch` (name from feature description) before implementing.
- Features must be intentional and scoped
- **Always check for and analyze attachments** before starting implementation
- Never mix fixes or refactors into a feature commit
- If a bug is discovered while implementing a feature, pause and suggest `/fix`
- If structural cleanup is needed, pause and suggest `/refactor`
- Every `/feature` must result in at least one commit and one push unless explicitly blocked; the
  feature is not complete until changes are pushed

---

## Usage

Use `/feature <description>` to:

- **First:** If you are on `main` or `master`, the command creates a feature branch (via
  `/feature-branch`) named from the feature (e.g. `feature/add-search-reset-button`) before any
  implementation.

- Add new screens or UI components
- Add new database queries or schema changes
- Add new external data source integrations
- Introduce new user-visible behavior
- Extend functionality while maintaining project architecture
- Implement designs from mockups or screenshots (attach images for context)
