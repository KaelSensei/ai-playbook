# Docker Claude + RTK Sandbox

Reproducible Ubuntu dev environment with [Claude Code](https://docs.claude.com/en/docs/claude-code)
and [RTK](https://github.com/rtk-ai/rtk) (the token-killing CLI proxy) pre-wired. **No secrets in
the image** — authentication happens at runtime, so this is safe to publish in a public repo.

## Why this exists

- **Isolated** — agent work runs in a container, not on your host
- **Reproducible** — same image, same tool versions, every time
- **Token-mastered** — RTK transparently compresses common shell-command output by 60–90% before it
  reaches Claude's context
- **Skill-ready** — mounts the `ai-playbook` repo and exposes its `.agents/skills/`,
  `.agents/commands/`, `.agents/rules/`, `.agents/setups/` to Claude Code inside the container

## Prerequisites

- Docker Desktop (macOS / Windows) or Docker Engine + `docker compose` plugin (Linux / WSL2)
- `make` (optional but recommended — falls back to plain `docker compose` commands if you skip it)

## Quickstart

```bash
cd boilerplates/docker-claude-rtk
cp .env.example .env

# To dogfood the ai-playbook itself, point WORKSPACE at the repo root:
echo "WORKSPACE=../.." >> .env

make build
make shell
```

Inside the container:

```bash
claude        # first run prompts for login (OAuth in browser, or paste API key)
rtk gain      # token-savings dashboard
exit          # leave
```

`make shell` again later — the `claude-config` volume keeps you logged in.

## Authentication — three options

| Mode                 | How                                                                                                                    | When to pick it                                                                    |
| -------------------- | ---------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| **OAuth (default)**  | Just run `claude` in the container, follow the device-code prompt. Login is saved in the `claude-config` named volume. | You have a Claude Pro/Max plan and want to use it.                                 |
| **API key**          | Add `ANTHROPIC_API_KEY=sk-ant-...` to `.env`. Picked up automatically by Claude Code.                                  | Headless / CI use. Billed via the API console.                                     |
| **Reuse host login** | In `compose.yaml`, replace `claude-config:/home/dev/.claude` with `~/.claude:/home/dev/.claude`.                       | You already have Claude Code installed on the host and don't want to log in twice. |

## Using your playbook skills inside the container

If `WORKSPACE` points to a directory that contains a `.agents/` folder, the entrypoint symlinks the
following into `~/.claude/` automatically:

- `.agents/skills/` → `~/.claude/skills/`
- `.agents/commands/` → `~/.claude/commands/`
- `.agents/rules/` → `~/.claude/rules/`
- `.agents/setups/` → `~/.claude/setups/`

Edit a skill on the host → it's instantly available to Claude inside the container. No rebuild
needed.

## Common commands

| Command        | What it does                                               |
| -------------- | ---------------------------------------------------------- |
| `make build`   | Build the image (idempotent)                               |
| `make shell`   | Drop into bash inside the container                        |
| `make claude`  | Launch Claude Code directly                                |
| `make gain`    | Show RTK token-savings stats                               |
| `make doctor`  | Run `claude doctor` (Claude Code diagnostics)              |
| `make rebuild` | Rebuild from scratch (no cache)                            |
| `make down`    | Stop & remove the container                                |
| `make clean`   | Stop & remove **volumes too** (you'll need to log back in) |

Without `make`:

```bash
USER_UID=$(id -u) USER_GID=$(id -g) docker compose build
docker compose run --rm claude bash
```

### Windows / PowerShell

If you're on native Windows without WSL2 or GNU make, use the PowerShell fallback:

```powershell
cd boilerplates\docker-claude-rtk
Copy-Item .env.example .env
.\make.ps1 build
.\make.ps1 shell
```

All `make` targets are mirrored: `build`, `shell`, `claude`, `gain`, `doctor`, `rebuild`, `down`,
`clean`. WSL2 is still the smoother experience (faster bind-mount I/O, native Linux tooling), but
`make.ps1` gets you running without it.

## What's inside the image

- `ubuntu:24.04`
- Node 20 LTS (NodeSource)
- `@anthropic-ai/claude-code` (latest at build time)
- `rtk` (installed via the official `install.sh` from `rtk-ai/rtk`)
- `git`, `ripgrep`, `jq`, `build-essential`, `tini`
- Non-root user `dev` (UID/GID matched to your host via build args, so bind-mounted files keep
  correct ownership)

RTK's Bash hook is wired into Claude Code at build time (`rtk init -g`), then re-asserted on
container start in case the named volume shadowed the build-time settings.

## Caveats

- **RTK only intercepts the Bash tool.** Claude Code's built-in `Read` / `Grep` / `Glob` tools don't
  pass through the Bash hook, so they aren't proxied. To get RTK's compression on those workflows,
  use shell equivalents (`cat`, `rg`, `find`) or call `rtk read` / `rtk grep` / `rtk find` directly.
  See the [RTK README](https://github.com/rtk-ai/rtk#how-it-works) for details.
- **Browser-based OAuth in a headless container** uses the device-code flow — Claude prints a URL,
  you open it on your host, paste back. Works fine but isn't quite as smooth as native install.
- **Windows hosts**: run `make` commands from WSL2, not from PowerShell. Docker Desktop's WSL2
  backend handles bind-mounts correctly; native Windows volumes may have slow I/O on the workspace.

## Updating

```bash
make rebuild        # picks up latest claude-code + rtk
```

Image is unpinned by design — rebuild whenever you want the newest versions. To pin, edit
`Dockerfile` and replace the `npm install -g @anthropic-ai/claude-code` and RTK install lines with
version-locked equivalents.
