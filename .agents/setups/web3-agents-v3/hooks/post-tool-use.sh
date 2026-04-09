#!/bin/bash
# post-tool-use.sh — Déclenché après chaque outil Bash ou Write
# Rôle : détecter les marqueurs de progression, mettre à jour le state

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TASK_FILE="$PROJECT_DIR/tasks/current_task.md"
LOG_DIR="$PROJECT_DIR/logs"

mkdir -p "$LOG_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] HOOK:POST | $1" >> "$LOG_DIR/hooks.log"
}

# ── Variables injectées par Claude Code ──────────────────────────
# CLAUDE_TOOL_NAME    : nom de l'outil utilisé
# CLAUDE_TOOL_INPUT   : input de l'outil (JSON)
# CLAUDE_TOOL_OUTPUT  : output de l'outil

TOOL="${CLAUDE_TOOL_NAME:-unknown}"
OUTPUT="${CLAUDE_TOOL_OUTPUT:-}"

log "Outil utilisé : $TOOL"

# ── Détecter les tests qui passent (TDD RED→GREEN) ────────────────

if echo "$OUTPUT" | grep -qE "(PASS|✓|passing|Tests:.*passed)"; then
    log "Tests verts détectés — phase GREEN validée"

    # Mettre à jour current_task.md
    if [ -f "$TASK_FILE" ]; then
        python3 - << PYEOF
with open('$TASK_FILE', 'r') as f:
    content = f.read()

if 'RUNNING' in content:
    content = content.replace('RUNNING', 'GREEN_PASS', 1)
    with open('$TASK_FILE', 'w') as f:
        f.write(content)
    print("current_task.md mis à jour : GREEN_PASS")
PYEOF
    fi
fi

# ── Détecter les tests qui échouent (TDD RED) ────────────────────

if echo "$OUTPUT" | grep -qE "(FAIL|✗|failing|AssertionError)"; then
    log "Tests rouges détectés — phase RED validée"
fi

# ── Détecter un commit git ────────────────────────────────────────

if [ "$TOOL" = "Bash" ] && echo "${CLAUDE_TOOL_INPUT:-}" | grep -q "git commit"; then
    log "Commit détecté — step TDD commité"
fi

exit 0
