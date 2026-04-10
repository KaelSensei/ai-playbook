#!/bin/bash
# run-supervisor.sh v2 — Supervisor main loop
# Uses Claude Code's native hooks (.claude/hooks/)
# Run by startup.sh in the background

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
LOG_DIR="$PROJECT_DIR/logs"
QUEUE_FILE="$PROJECT_DIR/QUEUE.md"
MAX_RETRIES=3
RETRY_DELAYS=(30 60 120)
SLEEP_BETWEEN_TASKS=10
SLEEP_EMPTY_QUEUE=60

mkdir -p "$LOG_DIR"

log() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo "$msg"
    echo "$msg" >> "$LOG_DIR/supervisor.log"
}

# ── Extract the next task ─────────────────────────────────────────

get_next_task() {
    # Priority 1: next_task.pending file created by the on-stop hook
    if [ -f "$PROJECT_DIR/tasks/next_task.pending" ]; then
        TASK=$(cat "$PROJECT_DIR/tasks/next_task.pending")
        rm "$PROJECT_DIR/tasks/next_task.pending"
        echo "$TASK"
        return
    fi
    # Priority 2: first "To do" task in QUEUE.md
    grep -m1 "^- \[ \]" "$QUEUE_FILE" 2>/dev/null \
        | sed 's/^- \[ \] //' \
        | sed 's/ _(started.*)//'
}

count_todo() {
    grep -c "^- \[ \]" "$QUEUE_FILE" 2>/dev/null || echo 0
}

# ── Move a task inside QUEUE.md ───────────────────────────────────

update_queue() {
    local action="$1"  # in_progress | done | paused
    local task="$2"
    local extra="${3:-}"

    python3 - << PYEOF
import re
from datetime import datetime

with open('$QUEUE_FILE', 'r') as f:
    content = f.read()

task = """$task"""
action = "$action"
timestamp = datetime.now().strftime('%Y-%m-%d %H:%M')
extra = """$extra"""

if action == "in_progress":
    old = f"- [ ] {task}"
    new = f"- [ ] {task} _(started on {timestamp})_"
    content = content.replace(old, new, 1)

elif action == "done":
    content = re.sub(rf'- \[ \] {re.escape(task)}.*\n', '', content)
    done_line = f"- [x] {task} _(finished on {timestamp} — {extra})_\n"
    content = content.replace('## Done\n', f'## Done\n{done_line}')

elif action == "paused":
    content = re.sub(rf'- \[ \] {re.escape(task)}.*\n', '', content)
    pause_line = f"- [!] {task} _(paused since {timestamp} — 3 attempts)_\n      Error: {extra}\n"
    content = content.replace('## Paused (error)\n', f'## Paused (error)\n{pause_line}')

with open('$QUEUE_FILE', 'w') as f:
    f.write(content)
PYEOF
}

# ── Execute a task via Claude Code (non-interactive mode) ─────────

run_task() {
    local task="$1"
    log "EXEC    | $task"

    # Update current_task.md before launching
    cat > "$PROJECT_DIR/tasks/current_task.md" << TASKEOF
# Current Task
## Status
RUNNING
## Active Flow / Task
$task
## Started
$(date '+%Y-%m-%d %H:%M:%S')
## Agent State
| Agent | Status | Findings |
|---|---|---|
TASKEOF

    # Build the prompt for the orchestrator
    local prompt="You are orchestrator then supervisor.

Load CLAUDE.md.
Load project-architecture.md SUMMARY.
Load tasks/current_task.md.

TASK: $task

Instructions:
1. Assess complexity (level 1/2/3)
2. Select the MINIMUM required agents
3. Run the FULL pipeline to the end without stopping
4. Include /pr automatically if code was produced
5. Update tasks/current_task.md with status=IDLE at the end of the task

Do not ask for confirmation. Execute to the end."

    # Launch Claude Code with a 2h timeout
    # --dangerously-skip-permissions for non-interactive mode
    timeout 7200 claude \
        --print "$prompt" \
        --dangerously-skip-permissions \
        2>> "$LOG_DIR/errors.log"

    return $?
}

# ── Main loop ─────────────────────────────────────────────────────

log "INIT    | Supervisor v2 started"
log "INIT    | Project: $PROJECT_DIR"
log "INIT    | Claude Code hooks: .claude/hooks/ active"

while true; do

    # Check whether the on-stop hook left a next task
    TASK=$(get_next_task)

    if [ -z "$TASK" ]; then
        TODO=$(count_todo)
        if [ "$TODO" -eq 0 ]; then
            log "IDLE    | Queue empty — waiting ${SLEEP_EMPTY_QUEUE}s"
            sleep $SLEEP_EMPTY_QUEUE
            continue
        fi
        # Re-read the queue directly
        TASK=$(grep -m1 "^- \[ \]" "$QUEUE_FILE" 2>/dev/null | sed 's/^- \[ \] //')
        if [ -z "$TASK" ]; then
            sleep $SLEEP_EMPTY_QUEUE
            continue
        fi
    fi

    log "START   | $TASK"
    update_queue "in_progress" "$TASK"

    START_TIME=$(date +%s)
    SUCCESS=false

    for attempt in 1 2 3; do
        log "TRY     | Attempt $attempt/$MAX_RETRIES"

        if run_task "$TASK"; then
            SUCCESS=true
            log "OK      | Attempt $attempt succeeded"
            break
        else
            EXIT_CODE=$?
            log "FAIL    | Attempt $attempt failed (exit $EXIT_CODE)"
            if [ $attempt -lt $MAX_RETRIES ]; then
                DELAY=${RETRY_DELAYS[$((attempt-1))]}
                log "WAIT    | Retry in ${DELAY}s"
                sleep $DELAY
            fi
        fi
    done

    END_TIME=$(date +%s)
    DURATION=$(( (END_TIME - START_TIME) / 60 ))m

    if [ "$SUCCESS" = true ]; then
        log "SUCCESS | $TASK ($DURATION)"
        update_queue "done" "$TASK" "$DURATION"
        bash "$SCRIPT_DIR/post-task.sh" "$TASK" "success" 2>/dev/null || true
    else
        log "PAUSE   | $TASK → 3 attempts exhausted"
        update_queue "paused" "$TASK" "See logs/errors.log"
        bash "$SCRIPT_DIR/notify.sh" "$TASK" "PAUSE" 2>/dev/null || true
        bash "$SCRIPT_DIR/post-task.sh" "$TASK" "failure" 2>/dev/null || true
    fi

    # Reset current_task.md
    echo -e "# Current Task\n## Status\nIDLE\n## Active Flow / Task\nnone" \
        > "$PROJECT_DIR/tasks/current_task.md"

    sleep $SLEEP_BETWEEN_TASKS
done
