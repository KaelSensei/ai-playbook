#!/bin/bash
# pre-tool-use.sh — Triggered before each Bash tool
# Role: guardrails — block dangerous actions, log

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
LOG_DIR="$PROJECT_DIR/logs"

mkdir -p "$LOG_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] HOOK:PRE | $1" >> "$LOG_DIR/hooks.log"
}

INPUT="${CLAUDE_TOOL_INPUT:-}"

# ── Block dangerous commands ─────────────────────────────────────

# No rm -rf on the project
if echo "$INPUT" | grep -qE "rm -rf (\.|\/)"; then
    log "BLOCKED: rm -rf detected"
    echo "HOOK_BLOCK: rm -rf not allowed without manual confirmation" >&2
    exit 1
fi

# No git push --force without a PR
if echo "$INPUT" | grep -q "git push --force\|git push -f"; then
    log "BLOCKED: git push --force detected"
    echo "HOOK_BLOCK: git push --force not allowed — use /pr" >&2
    exit 1
fi

# ── Legacy context: check for safety net before any change ───────

SETUP=$(grep -l "legacy-analyst" "$PROJECT_DIR/.claude/agents/" 2>/dev/null | head -1)
if [ -n "$SETUP" ]; then
    # If this is a legacy setup and the command modifies a file
    if echo "$INPUT" | grep -qE "(sed -i|awk.*>|patch )"; then
        # Verify that characterization tests exist
        CHAR_TESTS=$(find "$PROJECT_DIR" -name "*char*" -o -name "*characteriz*" 2>/dev/null | head -1)
        if [ -z "$CHAR_TESTS" ]; then
            log "WARN: Legacy modification without characterization tests detected"
            # We warn but don't block — the guardian handles it
        fi
    fi
fi

log "Command allowed: $(echo "$INPUT" | head -c 80)"

exit 0
