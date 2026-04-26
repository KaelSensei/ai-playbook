#!/usr/bin/env bash
set -euo pipefail

mkdir -p "$HOME/.claude"

# Re-wire RTK hook into Claude Code settings if the volume shadowed the build-time one
if ! grep -q "rtk" "$HOME/.claude/settings.json" 2>/dev/null; then
    rtk init -g >/dev/null 2>&1 || true
fi

# If the workspace contains a playbook (.agents/), expose its skills/commands/rules
# to Claude Code by symlinking into ~/.claude/. Symlinks are refreshed each run so
# they always point at the currently mounted workspace.
PLAYBOOK="/workspace/.agents"
if [ -d "$PLAYBOOK" ]; then
    for dir in skills commands rules setups; do
        target="$HOME/.claude/$dir"
        if [ -d "$PLAYBOOK/$dir" ]; then
            if [ -L "$target" ] || [ ! -e "$target" ]; then
                ln -sfn "$PLAYBOOK/$dir" "$target"
            fi
        fi
    done
fi

if [ ! -f "$HOME/.claude/.welcomed" ] && [ -t 1 ]; then
    cat <<'BANNER'
─────────────────────────────────────────────────────────────
  Claude Code + RTK sandbox
   • claude          start Claude Code (first run = login)
   • rtk gain        token savings stats
   • rtk --help      list RTK commands
   • exit            leave the container
─────────────────────────────────────────────────────────────
BANNER
    touch "$HOME/.claude/.welcomed"
fi

exec "$@"
