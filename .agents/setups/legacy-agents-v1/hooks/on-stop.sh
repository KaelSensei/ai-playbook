#!/bin/bash
# on-stop.sh — Triggered by Claude Code's "Stop" hook
# Runs when Claude completes a full response
# Role: check whether the current task is finished and launch the next one

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
QUEUE_FILE="$PROJECT_DIR/QUEUE.md"
TASK_FILE="$PROJECT_DIR/tasks/current_task.md"
LOG_DIR="$PROJECT_DIR/logs"

mkdir -p "$LOG_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] HOOK:STOP | $1" >> "$LOG_DIR/hooks.log"
}

# ── Read current task status ─────────────────────────────────────

if [ ! -f "$TASK_FILE" ]; then
    log "No current_task.md — nothing to do"
    exit 0
fi

STATUS=$(grep "^## Status" "$TASK_FILE" -A1 | tail -1 | tr -d ' ')

log "Current status: $STATUS"

# ── If task IDLE → check the queue ───────────────────────────────

if [ "$STATUS" = "IDLE" ]; then
    if [ ! -f "$QUEUE_FILE" ]; then
        log "No QUEUE.md — manual mode only"
        exit 0
    fi

    # Is there a next task?
    NEXT=$(grep -m1 "^- \[ \]" "$QUEUE_FILE" 2>/dev/null | sed 's/^- \[ \] //' | sed 's/ _(started.*)//')

    if [ -z "$NEXT" ]; then
        log "Queue empty — supervisor waiting"
        exit 0
    fi

    log "Next task detected: $NEXT"

    # Write the next task to a "pending" file
    # The supervisor will read it and trigger Claude Code
    echo "$NEXT" > "$PROJECT_DIR/tasks/next_task.pending"
    log "next_task.pending file created → supervisor will start"
fi

# ── If task SUCCESS (detected in current_task) ───────────────────

if echo "$STATUS" | grep -q "SUCCESS\|COMPLETE\|DONE"; then
    log "Task completed successfully"

    # Archive in QUEUE.md if applicable
    CURRENT_TASK=$(grep "^## Task" "$TASK_FILE" -A1 | tail -1 | sed 's/^none//')
    if [ -n "$CURRENT_TASK" ] && [ "$CURRENT_TASK" != "none" ]; then
        python3 - << PYEOF
import re
from datetime import datetime

with open('$QUEUE_FILE', 'r') as f:
    content = f.read()

task = open('$TASK_FILE').readlines()
task_name = ""
for line in task:
    if line.startswith("## Active Flow") or line.startswith("## Task"):
        pass
    elif task_name == "" and line.strip() and not line.startswith("#"):
        task_name = line.strip()
        break

if task_name and task_name != "none":
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M')
    content = re.sub(
        rf'- \[ \] {re.escape(task_name)}.*\n',
        f'- [x] {task_name} _(finished on {timestamp})_\n',
        content
    )
    with open('$QUEUE_FILE', 'w') as f:
        f.write(content)
    print(f"QUEUE.md updated: {task_name} → Done")
PYEOF
    fi
fi

exit 0
