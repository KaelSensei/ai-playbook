# Installing a Setup Bundle Into Another Project

This guide covers the practical "I'm sitting in a different repo and want the
poc/dev/web2/web3/pm/legacy bundle from this playbook" workflow.

> **Need the base playbook only (rules + commands + skills, no agent team)?** Use the CLI or
> submodule flow in [INSTALLATION.md](../../INSTALLATION.md) instead. This guide is for the
> opinionated bundles under `.agents/setups/`.

## TL;DR

```bash
# One-time: clone the playbook somewhere stable
git clone https://github.com/KaelSensei/ai-playbook.git ~/tools/ai-playbook

# In your target project (new or existing)
cd /path/to/your-project
bash ~/tools/ai-playbook/.agents/setups/<setup-name>/install.sh
```

Replace `<setup-name>` with one of:

| Setup              | Best for                                           |
| ------------------ | -------------------------------------------------- |
| `poc-squad-v1`     | Throwaway POCs, demos, weekend spikes              |
| `dev-squad-v2`     | TypeScript / React with strict TDD and pair review |
| `web2-agents-v1`   | Full-stack SaaS (13 agents)                        |
| `web3-agents-v3`   | Smart contracts, DeFi (10 agents)                  |
| `pm-ba-squad-v2`   | Specs, user stories, BDD (3 agents)                |
| `legacy-agents-v1` | Legacy modernization (14 agents)                   |

## What the installer does

Every `install.sh` is idempotent and copies files **out of the playbook and into your target
project**. After install the target is self-contained — you can delete the playbook clone and the
installed setup keeps working.

Per setup it writes:

- `.claude/agents/*.md` — agent personas
- `.claude/commands/*.md` — slash commands (`/poc`, `/brief`, `/feature`, etc. depending on setup)
- `.claude/skills/<skill>/SKILL.md` — any base playbook skills the setup pulls in (e.g.
  `clean-code`)
- `CLAUDE.md` at the project root — only if one does not already exist
- `tasks/` — created empty (setups that use a task system)

Pass a different target directory as the first argument to install into `.cursor/` instead:

```bash
bash ~/tools/ai-playbook/.agents/setups/poc-squad-v1/install.sh .cursor
```

See [`.agents/docs/AGENTS_COMPATIBILITY.md`](../docs/AGENTS_COMPATIBILITY.md) for how each setup
degrades on Cursor (most lose sub-agent personas and hooks).

---

## Scenario 1 — Brand-new GitHub repo

```bash
# 1. Create the local repo
mkdir -p ~/projects/my-new-thing
cd ~/projects/my-new-thing
git init -b main

# 2. Create it on GitHub and wire the remote
gh repo create my-new-thing --private --source=. --remote=origin

# 3. Install the setup
bash ~/tools/ai-playbook/.agents/setups/poc-squad-v1/install.sh

# 4. Bootstrap commit on a branch (never commit to main directly)
git checkout -b chore/bootstrap-poc-squad
git add .claude CLAUDE.md
git commit -m "chore: bootstrap poc-squad-v1"
git push -u origin chore/bootstrap-poc-squad
gh pr create --base main --title "chore: bootstrap poc-squad-v1" --body "Install POC Squad agents + commands."
gh pr merge --squash --delete-branch

# 5. Start working
git checkout main && git pull
git checkout -b feature/first-idea
claude   # then inside Claude Code: /poc <your idea>
```

## Scenario 2 — Existing repo

```bash
cd ~/projects/existing-repo
git checkout main && git pull

# 1. Create a dedicated branch for the install (docs discipline rule)
git checkout -b chore/add-<setup-name>

# 2. Run the installer
bash ~/tools/ai-playbook/.agents/setups/dev-squad-v2/install.sh

# 3. Inspect what changed
git status
git diff -- CLAUDE.md          # only relevant if CLAUDE.md already existed

# 4. Commit + PR
git add .claude CLAUDE.md tasks
git commit -m "chore: add dev-squad-v2 AI playbook setup"
git push -u origin chore/add-dev-squad-v2
gh pr create --base main --title "chore: add dev-squad-v2 AI playbook setup"
```

**If the repo already has a `CLAUDE.md`:** the installer leaves it alone. Open the setup's own
`CLAUDE.md` (at `~/tools/ai-playbook/.agents/setups/<setup-name>/CLAUDE.md`) and merge the sections
you need into your existing file by hand — usually the **Agent Team**, **Flows**, and **Hard rules**
sections.

**If the repo already has `.claude/agents/` or `.claude/commands/`:** the installer overwrites files
with the same name. Review with `git diff` before committing. To keep an existing custom command,
rename it first.

---

## Shell alias (optional, recommended)

If you install setups often, drop an alias in `~/.bashrc` / `~/.zshrc`:

```bash
alias ai-install='bash ~/tools/ai-playbook/.agents/setups'

# Usage:
#   ai-install/poc-squad-v1/install.sh
#   ai-install/dev-squad-v2/install.sh .cursor
```

Or one alias per setup:

```bash
alias install-poc='bash ~/tools/ai-playbook/.agents/setups/poc-squad-v1/install.sh'
alias install-dev='bash ~/tools/ai-playbook/.agents/setups/dev-squad-v2/install.sh'
```

---

## Updating an installed setup

The installer copies files, so installed setups **do not update automatically** when the playbook
changes. To pick up new versions:

```bash
# 1. Update your playbook clone
cd ~/tools/ai-playbook && git pull

# 2. In the target project, re-run on a branch
cd /path/to/your-project
git checkout -b chore/update-<setup-name>
bash ~/tools/ai-playbook/.agents/setups/<setup-name>/install.sh
git diff                       # review overwritten files
git add -u && git commit -m "chore: update <setup-name> to latest"
```

If you've customized any of the installed agent/command files, `git diff` will show the conflicts —
resolve them the same way you'd resolve any merge.

---

## Troubleshooting

### `install.sh: Permission denied`

The scripts ship with the executable bit set in git (`100755`). If you see this on a fresh clone,
your filesystem or a git config option has stripped it. Either run via `bash install.sh` (what this
guide does throughout) or re-enable with:

```bash
chmod +x .agents/setups/*/install.sh
```

### `⚠ clean-code not found at .../skills`

The installer expects the sibling base playbook at `.agents/skills/`. This happens when you copied
only a single setup folder somewhere and ran it without the full playbook clone nearby. Fix: run the
installer from a **full clone** of the playbook — the script resolves skill paths relative to its
own location.

### Windows (Git Bash / WSL)

All commands in this guide work in Git Bash and WSL. In PowerShell or cmd.exe, you'll need
`bash install.sh` (not `./install.sh`). Symlink-based install flows (Option 2 in
[INSTALLATION.md](../../INSTALLATION.md)) need Windows Developer Mode, but setup bundles copy files
so they work without it.

---

## When not to use a setup bundle

Setup bundles are opinionated. If none of the archetypes fit — or you're just adding AI rules to an
existing team with its own conventions — install only the **base playbook** instead:

```bash
npx ai-playbook-cli@latest install
```

See [INSTALLATION.md](../../INSTALLATION.md) for the submodule and CLI flows.
