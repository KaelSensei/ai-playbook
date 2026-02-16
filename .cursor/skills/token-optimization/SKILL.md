---
name: token-optimization
description:
  Lightweight, RTK-free token hygiene patterns for shell commands, searches, and code display.
---

# Token Optimization (Lightweight Mode)

Practical patterns to reduce LLM token usage **without requiring RTK or any external proxy**. This
skill is the "light compressor" counterpart to the RTK integration described in
`TOKEN_OPTIMIZATION.md`.

## When to use this skill

- When running noisy shell commands from an AI agent (tests, builds, git, large listings).
- When exploring a large codebase via search tools.
- When the user asks to "optimize token usage" but has **not** installed RTK (or prefers not to).
- As a baseline even when RTK is available, to keep explanations compact and focused.

## How this skill is used

**Users do not invoke skills directly.** This skill is loaded automatically when:

- The agent is about to run commands that typically produce a lot of output (git, tests, linters,
  `ls`, etc.).
- The agent is scanning many files or large search results.
- Commands or rules explicitly reference "token optimization" or "token hygiene".

This skill works **together** with the rule `.cursor/rules/token-optimization.mdc`:

- The rule defines global behavior (when to care about tokens, optional RTK usage).
- This skill provides **concrete patterns and examples** for staying lightweight even without RTK.

---

## 1. Shell command patterns (no RTK)

### 1.1 Prefer scoped, compact variants

When you need shell output, choose the least noisy form that still answers the question:

- **Git**
  - Use `git status -sb` rather than plain `git status` for quick overviews.
  - Limit logs: `git log -n 10 --oneline` instead of a full log with diffs.
  - Narrow diffs: `git diff path/to/file` instead of repo-wide diffs when you only need one file.

- **Listings**
  - Avoid `ls -la` or `tree` at the repo root unless strictly necessary.
  - Prefer listing **specific directories** (`ls src/feature-x`) rather than the entire project.

- **Tests and builds**
  - Run the full command (e.g. `npm test`, `cargo test`, `pytest`) but:
    - In explanations, focus on **failing tests and key errors**.
    - Do **not** paste the entire test log unless the user explicitly asks for it.

### 1.2 Avoid redundant or purely decorative output

- Do not re-run commands repeatedly to "refresh" output unless state has actually changed.
- Avoid commands whose output you are not going to use:
  - Instead of `ls` + `cat`, go directly to `Read`/`Grep` on the relevant file.
  - Avoid progress-bar-heavy commands when a quieter alternative exists.

---

## 2. Search and file-reading patterns

### 2.1 Scope searches aggressively

When using Cursor tools (`Grep`, `Glob`, semantic search), prefer:

- **Narrow paths**:
  - Search in `src/` or `cli/` instead of the entire repo when you know the rough area.
  - Avoid searching `.git`, `dist`, `node_modules`, and other large/generated directories.

- **Filtered types**:
  - Use `glob` / `type` filters (e.g. `*.ts`, `*.md`) when the language or file type is known.

- **Head limits and pagination**:
  - Use `head_limit` to cap the number of matches returned.
  - If you need more, paginate or refine the pattern instead of asking for “everything”.

### 2.2 Read only what you need

- Prefer reading:
  - **Single files** over entire directories.
  - **Relevant sections** of a file (specific function/class/region) instead of the whole file when
    possible.
- When a file is large:
  - Start with key sections (e.g. entry points, exported functions, or sections around a match).
  - Only expand to more context if necessary for understanding or refactoring.

---

## 3. Answer formatting: summarize, don’t dump

Even when you must run noisy commands or read large files, you control what gets **echoed back to
the user**.

### 3.1 Summarize logs and command output

- Default behavior:
  - Provide a **short natural-language summary** of what happened.
  - Include only the **most relevant lines** from logs or command output (e.g. the error message and
    a few lines of context).
- Only paste large log sections when:
  - The user explicitly requests “full logs” or “full output”.
  - The exact shape of the output is itself the subject of debugging.

### 3.2 Minimal code snippets

- When showing code to the user:
  - Prefer focused snippets (a single function, class, or small region).
  - Avoid dumping whole files unless the user specifically asks for them.
  - Avoid re-pasting the same large snippet multiple times; refer back to earlier references when
    possible.

---

## 4. Choosing between RTK and the lightweight mode

- **With RTK installed**:
  - Follow `.cursor/rules/token-optimization.mdc` to prefer `rtk` wrappers for noisy commands.
  - Still apply all the behavioral patterns from this skill when summarizing and presenting results.

- **Without RTK (or by user choice)**:
  - Do **not** attempt to use `rtk` commands.
  - Rely entirely on the patterns in this skill plus the global rule to:
    - Minimize the number of noisy commands.
    - Scope searches and file reads.
    - Keep answers concise and focused.

In both cases, token optimization must **never** skip essential safety steps (tests, linting, or
security checks). The goal is to **compress noise**, not to reduce quality.
