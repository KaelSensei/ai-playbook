# Autonomous Setup — run the playbook unattended on your own machine

This guide shows how to configure a machine (a laptop you leave running, a personal server, a
container) so you can kick off a task with a command like `/auto` and walk away while the agent
works.

It is written so **the same setup works across several AI CLIs**:

- **Claude Code** — the primary target of the playbook.
- **Codex CLI** (OpenAI) — for users who prefer OpenAI models.
- **Cursor** — supported for interactive use only (Cursor has no unattended CLI mode today).
- **Optional extras** — Gemini CLI, Aider.

> ⚠️ Safety first. "Unattended" does not mean "unbounded". Read the [Safety Model](#safety-model)
> section before you let any agent run without a human in front of the keyboard.

---

## Contents

1. [What you get](#what-you-get)
2. [Safety model](#safety-model)
3. [Prerequisites](#prerequisites)
4. [Tokens you will need](#tokens-you-will-need)
5. [Quickstart — one script](#quickstart--one-script)
6. [Manual setup, step by step](#manual-setup-step-by-step)
7. [Per-tool configuration](#per-tool-configuration)
8. [Running a task unattended](#running-a-task-unattended)
9. [Security checklist](#security-checklist)
10. [Troubleshooting](#troubleshooting)

---

## What you get

After running this setup on a Linux or macOS machine you will have:

- One or more AI CLIs installed and authenticated (at least one of: Claude Code, Codex CLI, Gemini
  CLI, Aider).
- A local `.env.local` with your tokens, **never committed**.
- A documented tool allowlist so the CLI does not stop every 10 seconds to ask for permission.
- A clear, reversible way to kick off a run (`/auto [task]` on Claude Code, equivalent entry points
  on the others) and come back to a draft PR plus a status log.

---

## Safety model

Autonomous runs are opt-in power. The rules below are non-negotiable for every tool in this guide:

1. **Never on `main`.** Every run happens on a new `feature/auto-<slug>` branch.
2. **Never auto-merge.** Runs open a **draft** PR. A human merges. Always.
3. **No destructive ops.** No `rm -rf`, no `git reset --hard` on shared history, no infra or prod
   deploys, no schema drops.
4. **Bounded permissions.** The tool allowlist covers the CLIs needed to build, test, commit, and
   open a PR. Nothing else.
5. **Bounded scope.** The agent only touches files the task implies. No opportunistic refactors of
   unrelated modules.
6. **Secrets stay out.** Tokens live in `.env.local`, never echoed to logs, commits, PR bodies, or
   issue comments.
7. **One resolve cycle.** If the review reports blockers, the agent gets at most one fix pass before
   escalating to a human-readable note and stopping.

The `/auto` command shipped in `.agents/setups/dev-squad-v2/` enforces rules 1-7 at the prompt
level. This guide extends the same contract to the other tools.

---

## Prerequisites

On the host that will run the agent:

- **OS**: Linux (Debian/Ubuntu/Arch tested) or macOS. Windows users: use WSL2.
- **Shell**: `bash` 4.x+ or `zsh` 5.x+.
- **Node.js**: 20 LTS or newer (needed by Claude Code, Codex CLI, Gemini CLI).
- **git**: 2.30+.
- **GitHub CLI (`gh`)**: 2.40+, authenticated (`gh auth status` must be green).
- **Optional**: `python3` 3.10+ if you want Aider.

Check in one pass:

```bash
bash --version && node --version && git --version && gh --version
```

---

## Tokens you will need

Create each token with the **minimum scope** the agent actually uses. Do not reuse a personal admin
token.

| Token               | Used by                     | Minimum scope                                                                                                                                           | Where to create                               |
| ------------------- | --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------- |
| `GITHUB_TOKEN`      | `gh`, `git push`, `/auto`   | Classic: `repo` (read/write), `read:org`. Fine-grained: repo-scoped `Contents:RW`, `Pull requests:RW`. **Do not grant admin, workflow-edit, or merge.** | <https://github.com/settings/tokens>          |
| `ANTHROPIC_API_KEY` | Claude Code                 | Standard API key; set spending caps in the Anthropic console.                                                                                           | <https://console.anthropic.com/settings/keys> |
| `OPENAI_API_KEY`    | Codex CLI, Aider (optional) | Standard API key; set usage limits in the OpenAI dashboard.                                                                                             | <https://platform.openai.com/api-keys>        |
| `GEMINI_API_KEY`    | Gemini CLI (optional)       | Standard API key.                                                                                                                                       | <https://aistudio.google.com/apikey>          |

A few rules that matter more than they look:

- **Never paste any of these into a repo file.** They live only in `.env.local`, which is gitignored
  by this project.
- **Separate tokens per machine.** The laptop and the always-on box should not share the same GitHub
  token, so you can revoke one without killing the other.
- **Set an expiration** when the provider allows it (90 days is a reasonable default).
- **Cap spending** on API provider dashboards. Runaway agents exist. Your wallet should not trust
  your prompt.

---

## Quickstart — one script

From the root of this repo, on your target machine:

```bash
cp scripts/env.example .env.local
chmod 600 .env.local
$EDITOR .env.local     # fill in only the tokens you want to use
bash scripts/setup-autonomous.sh
```

`scripts/setup-autonomous.sh` is idempotent. It will:

1. Verify prerequisites.
2. Verify that `.env.local` exists and has at least one provider token filled in.
3. Offer to install the CLIs you ticked in `.env.local` (each install is skipped if already
   present).
4. Validate each CLI can see its token.
5. Print a short summary of what is ready and what was skipped.

The script installs **no secrets** and copies **no files** outside this repo. It will never touch
`main`, `git config`, or remote git state.

---

## Manual setup, step by step

If you prefer not to run the script, here is the equivalent manual flow.

### 1. Create `.env.local`

```bash
cp scripts/env.example .env.local
chmod 600 .env.local
```

Edit it and fill in only the tokens you intend to use. Every other entry can stay blank.

### 2. Export the variables in your shell

```bash
set -a
source .env.local
set +a
```

You may want to wire this into your `~/.bashrc` / `~/.zshrc` on a dedicated box, but do **not** do
that on a shared workstation — prefer loading per-shell.

### 3. Install only the tools you need

See [Per-tool configuration](#per-tool-configuration) below.

### 4. Authenticate `gh`

```bash
gh auth login --with-token <<< "$GITHUB_TOKEN"
gh auth status
```

---

## Per-tool configuration

### Claude Code (primary)

Install:

```bash
npm install -g @anthropic-ai/claude-code
```

Authenticate (either works):

- `ANTHROPIC_API_KEY` exported in your environment from `.env.local`.
- Or: `claude` once, interactive login through the browser.

Pre-authorize tools. Create or edit `.claude/settings.json` in the project you want to run `/auto`
in. Example safe allowlist (commit only as `.claude/settings.example.json` if you commit at all):

```json
{
  "permissions": {
    "allow": [
      "Bash(git:*)",
      "Bash(gh:*)",
      "Bash(node:*)",
      "Bash(npm:*)",
      "Bash(pnpm:*)",
      "Bash(yarn:*)",
      "Bash(npx:*)",
      "Bash(ls:*)",
      "Bash(cat:*)",
      "Bash(grep:*)",
      "Bash(rg:*)",
      "Read",
      "Write",
      "Edit",
      "Glob",
      "Grep"
    ],
    "deny": ["Bash(rm -rf *)", "Bash(git push --force*)", "Bash(gh pr merge*)", "Bash(sudo *)"]
  }
}
```

Run a task unattended (from the project root):

```bash
claude --print "/auto add a /health endpoint returning 200 OK"
```

`/auto` will follow the flow shipped by `dev-squad-v2` and leave a status log at
`tasks/auto-<slug>.md`.

### Codex CLI (OpenAI)

Install:

```bash
npm install -g @openai/codex
```

Authenticate:

- Export `OPENAI_API_KEY` from `.env.local`.

Codex CLI has its own subset of tools. There is no port of `/auto` to Codex yet — you get
interactive chat with file/shell access. Treat runs as semi-supervised: start the task, check in
every few minutes, and never leave it with broader permissions than the Claude Code allowlist above.

### Cursor

Cursor is an editor, not a headless CLI. Use it for supervised sessions. The playbook's rules,
commands, and skills still work inside Cursor — see
[`.agents/docs/AGENTS_COMPATIBILITY.md`](.agents/docs/AGENTS_COMPATIBILITY.md) for what does and
does not carry over from Claude Code.

For unattended use, stick to Claude Code or Codex CLI.

### Gemini CLI (optional)

```bash
npm install -g @google/gemini-cli
```

Export `GEMINI_API_KEY`. Same caveat as Codex: no `/auto` parity. Use for targeted tasks.

### Aider (optional, Python)

```bash
pip install --user aider-chat
```

Aider uses whichever API key you export (`ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, etc.). It is a
strong interactive pair, not an unattended orchestrator — same guidance as Codex.

---

## Running a task unattended

Minimum checklist before you walk away:

1. You are on a **clean tree**, on `main`, fully synced with the remote.
2. `.env.local` is loaded in the shell you are about to launch from.
3. The project has a `.claude/settings.json` (or equivalent) with the allowlist above.
4. You tested `/auto` at least once **while watching** on a throwaway task.
5. Your provider dashboards have spending caps set.

Then:

```bash
cd /path/to/your/project
claude --print "/auto <task description>"
```

Come back. Open the draft PR. Read `tasks/auto-<slug>.md`. Merge or ask for changes.

---

## Security checklist

Before you declare victory, tick all of these:

- [ ] `.env.local` is **not** tracked (`git ls-files --error-unmatch .env.local` should fail).
- [ ] `.env.local` permissions are `600` (`stat -c '%a' .env.local`).
- [ ] No token appears in your shell history
      (`history | grep -Ei 'sk_|ghp_|anthropic' || echo clean`).
- [ ] GitHub token has no `admin:*`, no `workflow`, no `delete_repo` scope.
- [ ] API provider spending caps are set.
- [ ] `.claude/settings.json` does not allow `git push --force`, `gh pr merge`, or `sudo`.
- [ ] You have a way to kill the run (tmux / systemd / `pkill -f claude`).
- [ ] You know which branch the run will work on and have reviewed the `/auto` safety rails.

---

## Troubleshooting

**`gh` fails with 401 / 403.** Token scope is too narrow or expired. Recreate with the minimum scope
in the [tokens table](#tokens-you-will-need).

**Claude Code asks for permission every few seconds.** Your `.claude/settings.json` allowlist is
missing the command being run. Add it and restart the CLI. Prefer an allowlist pattern like
`Bash(npm:*)` over globbing the whole shell.

**`/auto` halted with `reason: spec too ambiguous`.** That is working as designed. Read
`tasks/auto-<slug>.md`, refine the task description, run again.

**A run pushed something I did not expect.** Revoke the `GITHUB_TOKEN` immediately, then inspect the
branch. `/auto` never force-pushes and never targets `main`, so the blast radius is bounded to one
`feature/auto-<slug>` branch and one draft PR.

**I want to stop a run in progress.** On the host: `pkill -f claude` (or the equivalent for the CLI
you launched). No git state is lost — Claude Code commits atomically between phases.
