#!/usr/bin/env bash
# setup-autonomous.sh — provision a machine to run the ai-playbook agents unattended.
#
# Idempotent. Installs no secrets. Writes nothing outside this repo.
# Does not touch git remote state, does not run any agent, does not push.
#
# Usage:
#   cp scripts/env.example .env.local
#   chmod 600 .env.local
#   $EDITOR .env.local
#   bash scripts/setup-autonomous.sh
#
# See AUTONOMOUS_SETUP.md for the full flow.

set -euo pipefail

# ---------- pretty output -------------------------------------------------

info()  { printf '\033[34m[info]\033[0m  %s\n' "$*"; }
ok()    { printf '\033[32m[ ok ]\033[0m  %s\n' "$*"; }
warn()  { printf '\033[33m[warn]\033[0m  %s\n' "$*" >&2; }
fail()  { printf '\033[31m[fail]\033[0m  %s\n' "$*" >&2; exit 1; }

section() { printf '\n\033[1m== %s ==\033[0m\n' "$*"; }

# ---------- locate repo ---------------------------------------------------

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[ -n "$REPO_ROOT" ] || fail "Run this from inside the ai-playbook git clone."
cd "$REPO_ROOT"

ENV_FILE="$REPO_ROOT/.env.local"

# ---------- prerequisites -------------------------------------------------

section "Prerequisites"

require_cmd() {
  local cmd="$1" hint="$2"
  if command -v "$cmd" >/dev/null 2>&1; then
    ok "$cmd found ($(command -v "$cmd"))"
  else
    fail "$cmd not found. $hint"
  fi
}

require_cmd git  "Install git 2.30+."
require_cmd node "Install Node.js 20 LTS or newer."
require_cmd npm  "Install Node.js 20 LTS (bundles npm)."
require_cmd gh   "Install the GitHub CLI: https://cli.github.com/"

# Node >= 20 soft check.
NODE_MAJOR="$(node -p 'process.versions.node.split(".")[0]')"
if [ "$NODE_MAJOR" -lt 20 ]; then
  warn "Node $NODE_MAJOR detected. Node 20 LTS or newer recommended."
fi

# ---------- env file ------------------------------------------------------

section "Environment file"

if [ ! -f "$ENV_FILE" ]; then
  fail ".env.local not found. Run: cp scripts/env.example .env.local && chmod 600 .env.local"
fi

# Permissions check (POSIX stat varies; try GNU then BSD).
PERMS="$(stat -c '%a' "$ENV_FILE" 2>/dev/null || stat -f '%A' "$ENV_FILE" 2>/dev/null || echo '?')"
if [ "$PERMS" != "600" ]; then
  warn ".env.local permissions are '$PERMS'. Recommend: chmod 600 .env.local"
else
  ok ".env.local permissions are 600"
fi

# Make sure it is ignored by git — refuse to proceed if someone made it trackable.
if git ls-files --error-unmatch .env.local >/dev/null 2>&1; then
  fail ".env.local is TRACKED by git. Stop, untrack it, and rotate any tokens it contains."
fi
ok ".env.local is not tracked by git"

# Load it. Fail closed if parsing fails.
set -a
# shellcheck disable=SC1090
. "$ENV_FILE"
set +a

# ---------- token presence checks ----------------------------------------

section "Token presence"

# These helpers check for *presence*, never print values.
check_token() {
  local name="$1" purpose="$2"
  local val="${!name:-}"
  if [ -n "$val" ]; then
    ok "$name is set (${#val} chars) — $purpose"
    return 0
  else
    warn "$name is empty — $purpose unavailable"
    return 1
  fi
}

HAS_ANY_PROVIDER=0
check_token GITHUB_TOKEN      "GitHub push / PR creation" || true
check_token ANTHROPIC_API_KEY "Claude Code"        && HAS_ANY_PROVIDER=1 || true
check_token OPENAI_API_KEY    "Codex CLI / Aider"  && HAS_ANY_PROVIDER=1 || true
check_token GEMINI_API_KEY    "Gemini CLI"         && HAS_ANY_PROVIDER=1 || true

if [ "$HAS_ANY_PROVIDER" -ne 1 ]; then
  fail "No AI provider token set. Fill at least one of ANTHROPIC_API_KEY / OPENAI_API_KEY / GEMINI_API_KEY in .env.local."
fi

if [ -z "${GITHUB_TOKEN:-}" ]; then
  warn "GITHUB_TOKEN not set — /auto cannot open PRs. Set it in .env.local to enable autonomous runs."
fi

# ---------- gh auth (non-destructive) ------------------------------------

section "GitHub CLI auth"

if [ -n "${GITHUB_TOKEN:-}" ]; then
  if gh auth status >/dev/null 2>&1; then
    ok "gh already authenticated"
  else
    info "gh not authenticated yet. Authenticating with GITHUB_TOKEN..."
    printf '%s\n' "$GITHUB_TOKEN" | gh auth login --with-token
    gh auth status >/dev/null 2>&1 && ok "gh authenticated" || fail "gh auth failed — check token scope."
  fi
else
  warn "Skipping gh auth (no GITHUB_TOKEN)."
fi

# ---------- optional CLI installs ----------------------------------------

section "CLI installs (opt-in only)"

# Each install is skipped if the tool is already on PATH OR the opt-in flag is not 1.
maybe_install_npm() {
  local flag="$1" pkg="$2" bin="$3"
  local enabled="${!flag:-0}"
  if [ "$enabled" != "1" ]; then
    info "Skipping $pkg ($flag != 1 in .env.local)"
    return 0
  fi
  if command -v "$bin" >/dev/null 2>&1; then
    ok "$bin already installed ($(command -v "$bin"))"
    return 0
  fi
  info "Installing $pkg globally via npm..."
  npm install -g "$pkg"
  ok "$pkg installed"
}

maybe_install_npm INSTALL_CLAUDE_CODE "@anthropic-ai/claude-code" "claude"
maybe_install_npm INSTALL_CODEX_CLI   "@openai/codex"             "codex"
maybe_install_npm INSTALL_GEMINI_CLI  "@google/gemini-cli"        "gemini"

if [ "${INSTALL_AIDER:-0}" = "1" ]; then
  if command -v aider >/dev/null 2>&1; then
    ok "aider already installed ($(command -v aider))"
  else
    if command -v python3 >/dev/null 2>&1; then
      info "Installing aider via pip..."
      python3 -m pip install --user aider-chat
      ok "aider installed"
    else
      warn "python3 not found — skipping aider"
    fi
  fi
else
  info "Skipping aider (INSTALL_AIDER != 1 in .env.local)"
fi

# ---------- summary -------------------------------------------------------

section "Summary"

summarize() {
  local bin="$1" label="$2"
  if command -v "$bin" >/dev/null 2>&1; then
    ok "$label ready — $(command -v "$bin")"
  else
    info "$label not installed"
  fi
}

summarize claude "Claude Code"
summarize codex  "Codex CLI"
summarize gemini "Gemini CLI"
summarize aider  "Aider"
summarize gh     "GitHub CLI"

cat <<'EONOTE'

Next steps:

  1. In the project you want to run /auto in, create .claude/settings.json with a safe allowlist.
     See the template in AUTONOMOUS_SETUP.md -> "Claude Code (primary)".

  2. Test /auto interactively on a throwaway task BEFORE leaving any run unattended:

       claude --print "/auto add a demo hello endpoint"

  3. Review tasks/auto-<slug>.md and the draft PR when you return. Never configure auto-merge.

EONOTE

ok "Setup script complete."
