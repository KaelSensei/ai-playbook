<div align="center">
  <h1>Token Optimization Guide</h1>
  <p>How to reduce LLM token usage for AI-assisted development</p>
</div>

---

### 1. Problem: noisy dev commands = wasted tokens

Modern AI dev tools (Cursor, Claude Code, Gemini CLI, etc.) stream shell output directly into the
model context. Common commands like `git status`, `cargo test`, `npm test`, `ls -la`, and `grep` can
produce hundreds or thousands of tokens per run.

As highlighted in
[Patrick Szymkowiak’s post](https://www.linkedin.com/posts/patrick-szymkowiak_ai-devtools-rust-share-7429085715440852992-uf-V/)
and the [RTK (Rust Token Killer) README](https://github.com/rtk-ai/rtk):

- 60–90% of tokens consumed by dev workflows often come from **noise** (progress bars, repeated
  logs, successful tests, boilerplate diffs).
- In real sessions, that can mean **tens of millions of tokens** per month that add little value.

This guide explains how to reduce that waste when using this AI Playbook, especially with Cursor.

---

### 2. Solution A – Use RTK (Rust Token Killer)

[RTK (Rust Token Killer)](https://github.com/rtk-ai/rtk) is a single Rust binary that acts as a
**CLI proxy**. It filters and compresses command outputs before they reach the LLM context.

RTK is explicitly designed for AI devtools and is documented as compatible with:

- Claude Code
- Cursor
- Gemini CLI
- Aider
- Codex
- Windsurf
- Cline

See the RTK website for details: [`https://www.rtk-ai.app`](https://www.rtk-ai.app).

#### 2.1. What RTK actually does

From the RTK README:

- **Smart filtering** – strips progress bars, repeated lines, and boilerplate
- **Grouping** – clusters similar items (errors by file/rule, files by directory)
- **Truncation** – keeps the important context, drops redundant sections
- **Deduplication** – collapses repeated log lines with counts

Example savings (from the official docs):

- `git status` → ~80% fewer tokens
- `git diff` → ~75% fewer tokens
- `cargo test` / `npm test` / `pytest` / `go test` → ~90% fewer tokens (failures only)
- `ls` / `tree` / `grep` / `rg` → ~70–80% fewer tokens

#### 2.2. Install and verify RTK

Follow the official installation instructions in the RTK repo:

- RTK README: [`https://github.com/rtk-ai/rtk`](https://github.com/rtk-ai/rtk)
- Install guide: [`INSTALL.md`](https://github.com/rtk-ai/rtk/blob/master/INSTALL.md)

RTK is a **cross‑platform** CLI:

- **Linux / macOS**
  - Recommended: use the install script from the README (see upstream docs for latest command).
  - Alternative: build from source with `cargo install --git https://github.com/rtk-ai/rtk`.
- **Windows**
  - Use the pre‑built Windows binary from the RTK releases page:
    [`https://github.com/rtk-ai/rtk/releases`](https://github.com/rtk-ai/rtk/releases)  
    (e.g. `rtk-x86_64-pc-windows-msvc.zip`), or build from source with Cargo.
  - Add the extracted `rtk.exe` directory to your `PATH` so that `rtk --version` works in a shell.

Typical steps (simplified, see upstream docs for the latest version):

```bash
# 1. Check if rtk is already installed
rtk --version
rtk gain

# 2. Quick install (Linux/macOS only, from RTK README)
curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh

# 3. Verify installation
rtk gain          # Should show token savings stats
rtk git status    # Should show compact git status
```

> **Security note:** Always review installation scripts and binaries before running them, especially
> in production or enterprise environments. See RTK’s `SECURITY.md` and `ARCHITECTURE.md` for
> details on their security posture.

#### 2.3. Using RTK with this AI Playbook (Cursor)

Once `rtk` is available on your `PATH`, you can use it manually **or** let the AI playbook prefer it
for noisy commands.

Manual usage examples:

```bash
# Files and search
rtk ls .
rtk read src/main.rs
rtk grep "TODO" src

# Git
rtk git status
rtk git diff
rtk git log -n 10

# Tests and builds
rtk cargo test
rtk test cargo test          # Failures only, extra aggressive
rtk err npm run build        # Errors/warnings only

# Analytics
rtk gain                     # See token savings and history
rtk gain --graph             # ASCII graph of last 30 days
```

Playbook integration:

- The new rule `.cursor/rules/token-optimization.mdc` instructs AI agents using this playbook to:
  - Detect RTK once per session (`rtk --version`) when about to run a **noisy** command.
  - Prefer `rtk` wrappers (e.g. `rtk git status`, `rtk cargo test`) when RTK is available.
  - Gracefully fall back to plain commands when RTK is missing or a feature is unsupported.

This keeps the behavior correct while significantly reducing the tokens spent on shell output.

#### 2.4. Using RTK with Claude Code (optional)

RTK has first‑class support for Claude Code via hooks:

- `rtk init -g` installs a **PreToolUse hook** that rewrites commands transparently:
  - `git status` → `rtk git status`
  - `cargo test` → `rtk cargo test`
  - `npm test` → `rtk test npm test`
  - `ls` → `rtk ls`

See the “Auto‑Rewrite Hook” section in the RTK README for full details:

- [`https://github.com/rtk-ai/rtk`](https://github.com/rtk-ai/rtk)

This is optional for the AI Playbook itself, but useful if you also use Claude Code alongside
Cursor.

---

### 3. Solution B – Playbook‑level token hygiene (no extra tools)

Even without RTK, you can significantly reduce token usage with a few habits baked into this
playbook and its rules.

Key practices (reinforced in `.cursor/rules/token-optimization.mdc`):

- **Prefer focused shell commands**
  - Use `git status -sb` for quick status instead of the verbose default.
  - Limit listings and logs with flags (`-n`, `--max-count`, depth options).
- **Use Cursor tools instead of noisy shell exploration**
  - `Grep` / `Glob` / semantic search are tuned to return only what is needed.
  - Avoid running `ls -la` or `find` on large trees just to “see what’s there”.
- **Summarize test and build output**
  - Run full tests, but don’t paste entire logs back into the chat.
  - Quote only the failing tests and key error messages; explain the rest in your own words.
- **Show minimal code snippets**
  - Prefer small, focused code references instead of dumping full files.
  - Avoid re‑pasting the same large block unless it changed or is central to the discussion.

These patterns are **tool‑agnostic** and apply to Cursor, Claude Code, and any other agent using the
playbook.

---

### 4. How this fits into the AI Playbook

- **Rules**:
  - `.cursor/rules/token-optimization.mdc` defines cross‑cutting behavior for token usage.
  - It is loaded automatically (via `alwaysApply: true`) for all sessions.
- **Commands**:
  - Existing commands (`/feature`, `/fix`, `/git`, etc.) do not change their external API.
  - Internally, agents following the rules should:
    - Prefer RTK wrappers for noisy shell commands when available.
    - Apply token‑hygiene patterns when reading files, running searches, and summarizing results.
- **MCP**:
  - RTK is a **local CLI binary**, not an MCP server; it runs wherever your shell runs.
  - You do **not** need to modify `.cursor/mcp.json` to use RTK with this playbook.
- **Security and reliability**:
  - Token optimization must **never** skip essential checks (tests, lint, security review).
  - The goal is to **compress noise**, not to avoid work.

If you adopt RTK and follow these guidelines, you should see:

- Longer uninterrupted sessions in Cursor and other tools
- Fewer rate‑limit interruptions
- Lower token costs for the same (or better) development workflows

---

### 5. References

- LinkedIn post (French, summary of the problem and RTK metrics):  
  [`https://www.linkedin.com/posts/patrick-szymkowiak_ai-devtools-rust-share-7429085715440852992-uf-V/`](https://www.linkedin.com/posts/patrick-szymkowiak_ai-devtools-rust-share-7429085715440852992-uf-V/)
- RTK repository (Rust Token Killer):  
  [`https://github.com/rtk-ai/rtk`](https://github.com/rtk-ai/rtk)
- RTK website:  
  [`https://www.rtk-ai.app`](https://www.rtk-ai.app)
