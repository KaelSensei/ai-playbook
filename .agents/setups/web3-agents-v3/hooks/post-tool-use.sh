#!/bin/bash
# post-tool-use.sh — Triggered after every Bash or Write tool use
# Role: detect progress markers and update the state

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TASK_FILE="$PROJECT_DIR/tasks/current_task.md"
LOG_DIR="$PROJECT_DIR/logs"

mkdir -p "$LOG_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] HOOK:POST | $1" >> "$LOG_DIR/hooks.log"
}

# ── Variables injected by Claude Code ────────────────────────────
# CLAUDE_TOOL_NAME    : name of the tool used
# CLAUDE_TOOL_INPUT   : tool input (JSON)
# CLAUDE_TOOL_OUTPUT  : tool output

TOOL="${CLAUDE_TOOL_NAME:-unknown}"
OUTPUT="${CLAUDE_TOOL_OUTPUT:-}"

log "Tool used: $TOOL"

# ── Detect passing tests (TDD RED→GREEN) ─────────────────────────

if echo "$OUTPUT" | grep -qE "(PASS|✓|passing|Tests:.*passed)"; then
    log "Green tests detected — GREEN phase confirmed"

    # Update current_task.md
    if [ -f "$TASK_FILE" ]; then
        python3 - << PYEOF
with open('$TASK_FILE', 'r') as f:
    content = f.read()

if 'RUNNING' in content:
    content = content.replace('RUNNING', 'GREEN_PASS', 1)
    with open('$TASK_FILE', 'w') as f:
        f.write(content)
    print("current_task.md updated: GREEN_PASS")
PYEOF
    fi
fi

# ── Detect failing tests (TDD RED) ───────────────────────────────

if echo "$OUTPUT" | grep -qE "(FAIL|✗|failing|AssertionError)"; then
    log "Red tests detected — RED phase confirmed"
fi

# ── Detect a git commit ──────────────────────────────────────────

if [ "$TOOL" = "Bash" ] && echo "${CLAUDE_TOOL_INPUT:-}" | grep -q "git commit"; then
    log "Commit detected — TDD step committed"
fi

exit 0
