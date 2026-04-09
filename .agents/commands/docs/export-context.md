# Export Context Command – Compress context window into markdown for another AI agent

When `/export-context [output-path]` is invoked, summarize the current context window (rules, key
docs, relevant files, task, repo state) into a **single compressed markdown** file so another AI
agent can load it and get up to speed. The output is structured for fast parsing and minimal token
use.

Reference: `.cursor/rules/security.mdc`, `.cursor/rules/documentation.mdc`,
`.cursor/rules/version-management.mdc`.

---

## Step 1: Load project context

1. Assume the project root as the working directory.
2. Load and respect all Cursor rules from `.cursor/rules/*.mdc`.
3. Identify what is currently in “context”: open/relevant files, recent conversation or task
   description, branch, and key docs (README, PROGRESS, CHANGELOG, architecture if present).

---

## Step 2: Gather context to summarize

Collect (do not paste full file contents; extract only what another agent needs):

1. **Project**
   - Repo root, project name or purpose (from README or task).
   - Current branch: `git branch --show-current`.
   - Tech stack / stack hints (from README, package.json, or rules).

2. **Rules in effect**
   - For each `.cursor/rules/*.mdc`: file name + 1-line purpose (e.g. “security: no untrusted
     network, no eval”).
   - No full rule text; only a short summary line per rule.

3. **Key files and paths**
   - List of file paths that are central to the current task (e.g. “entrypoint”, “main config”,
     “feature X implementation”). One line per path with a few-word note.
   - No file bodies; paths and roles only.

4. **Current task / goal**
   - In 2–5 short bullets: what the user asked for, what is being built or fixed, and what “done”
     looks like.
   - If there are open questions or decisions, list them in one line each.

5. **Decisions or constraints**
   - Any architecture or tech decisions relevant to the task (from conversation or docs).
   - Constraints (e.g. “offline-only”, “no new deps”, “must pass existing tests”).

6. **Repo structure (optional, compact)**
   - Only if useful: top-level dirs and 1-line role (e.g. `src/` – app code, `tests/` – tests).
   - Omit if obvious from project type.

---

## Step 3: Compress into structured markdown

1. Write a **single markdown document** with the sections above.
2. **Compression rules:**
   - Use short headings, bullet lists, and keywords; avoid long prose.
   - No full file contents; only summaries, paths, and one-line descriptions.
   - No secrets, tokens, or credentials (per security.mdc).
   - No pasted code blocks unless a single critical snippet is necessary (and then keep it minimal).
3. Aim for **dense, scannable** text so another agent can ingest it quickly (e.g. under ~2–4k tokens
   for a typical project).
4. Add a short “How to use this” at the top: “Load this file into another AI agent to restore
   project and task context.”

---

## Step 4: Write output file

1. **Default path:** `.cursor/context-summary.md` (under project root). If the user passed
   `[output-path]`, use that path instead (still under project root unless they give an absolute
   path).
2. Write the compressed markdown to that file.
3. Confirm to the user: “Wrote context summary to `<path>`. You can pass this file to another AI
   agent to restore context.”
4. Suggest adding `context-summary.md` (or the chosen name) to `.gitignore` if the summary might
   contain task-specific or temporary notes that should not be committed.

---

## Step 5: Optional commit

- This command **does not** commit or push by default (the summary is for handoff, not necessarily
  for version control).
- If the user wants to commit the summary, they can run `/git` or `git add` / `git commit` /
  `git push` themselves.
- If the project’s rules require committing new files and the user has not said “do not commit”, you
  may offer: “Should I add and commit this file? (e.g. `docs: add context summary for handoff`)”.

---

## Cursor behavior rules

- **Never** include secrets, API keys, or credentials in the exported markdown.
- **Always** keep the summary compressed: summaries and bullets, not full file dumps.
- **Always** structure sections so another agent can parse them (clear headings, lists).
- If the context is huge, **prioritize** current task, active rules, and key file paths; trim or
  drop the rest.

---

## Usage

- `/export-context` – Write compressed context summary to `.cursor/context-summary.md`.
- `/export-context CONTEXT_SUMMARY.md` – Write to `CONTEXT_SUMMARY.md` in project root.
- Use the generated file as input to another AI agent (e.g. new chat, different tool) to restore
  project and task context quickly.

---

## Integration

- Complements `/start` and `/continue` (which load context into the current session).
- Use `/export-context` when you need to **hand off** context to another agent or session without
  re-pasting long conversations or file lists.
