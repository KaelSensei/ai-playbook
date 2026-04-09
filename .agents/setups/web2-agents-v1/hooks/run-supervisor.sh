#!/bin/bash
# run-supervisor.sh v2 — Boucle principale du supervisor
# Utilise les hooks natifs Claude Code (.claude/hooks/)
# Tournée par startup.sh en background

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

# ── Extraire la prochaine tâche ───────────────────────────────────

get_next_task() {
    # Priorité 1 : fichier next_task.pending créé par le hook on-stop
    if [ -f "$PROJECT_DIR/tasks/next_task.pending" ]; then
        TASK=$(cat "$PROJECT_DIR/tasks/next_task.pending")
        rm "$PROJECT_DIR/tasks/next_task.pending"
        echo "$TASK"
        return
    fi
    # Priorité 2 : première tâche "À faire" dans QUEUE.md
    grep -m1 "^- \[ \]" "$QUEUE_FILE" 2>/dev/null \
        | sed 's/^- \[ \] //' \
        | sed 's/ _(démarrée.*)//'
}

count_todo() {
    grep -c "^- \[ \]" "$QUEUE_FILE" 2>/dev/null || echo 0
}

# ── Déplacer une tâche dans QUEUE.md ─────────────────────────────

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
    new = f"- [ ] {task} _(démarrée le {timestamp})_"
    content = content.replace(old, new, 1)

elif action == "done":
    content = re.sub(rf'- \[ \] {re.escape(task)}.*\n', '', content)
    done_line = f"- [x] {task} _(terminée le {timestamp} — {extra})_\n"
    content = content.replace('## Terminé\n', f'## Terminé\n{done_line}')

elif action == "paused":
    content = re.sub(rf'- \[ \] {re.escape(task)}.*\n', '', content)
    pause_line = f"- [!] {task} _(en pause depuis {timestamp} — 3 tentatives)_\n      Erreur : {extra}\n"
    content = content.replace('## En pause (erreur)\n', f'## En pause (erreur)\n{pause_line}')

with open('$QUEUE_FILE', 'w') as f:
    f.write(content)
PYEOF
}

# ── Exécuter une tâche via Claude Code (mode non-interactif) ─────

run_task() {
    local task="$1"
    log "EXEC    | $task"

    # Mettre à jour current_task.md avant de lancer
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

    # Construire le prompt pour l'orchestrateur
    local prompt="Tu es orchestrator puis supervisor.

Charge CLAUDE.md.
Charge project-architecture.md SUMMARY.
Charge tasks/current_task.md.

TÂCHE : $task

Instructions :
1. Analyser la complexité (niveau 1/2/3)
2. Sélectionner les agents MINIMUM nécessaires
3. Exécuter le pipeline COMPLET jusqu'au bout sans s'arrêter
4. Inclure /pr automatiquement si du code a été produit
5. Mettre à jour tasks/current_task.md avec status=IDLE en fin de tâche

Ne pas demander de confirmation. Exécuter jusqu'au bout."

    # Lancer Claude Code avec timeout 2h
    # --dangerously-skip-permissions pour le mode non-interactif
    timeout 7200 claude \
        --print "$prompt" \
        --dangerously-skip-permissions \
        2>> "$LOG_DIR/errors.log"

    return $?
}

# ── Boucle principale ─────────────────────────────────────────────

log "INIT    | Supervisor v2 démarré"
log "INIT    | Projet : $PROJECT_DIR"
log "INIT    | Hooks Claude Code : .claude/hooks/ actifs"

while true; do

    # Vérifier si le hook on-stop a déposé une prochaine tâche
    TASK=$(get_next_task)

    if [ -z "$TASK" ]; then
        TODO=$(count_todo)
        if [ "$TODO" -eq 0 ]; then
            log "IDLE    | Queue vide — attente ${SLEEP_EMPTY_QUEUE}s"
            sleep $SLEEP_EMPTY_QUEUE
            continue
        fi
        # Re-lire la queue directement
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
        log "TRY     | Tentative $attempt/$MAX_RETRIES"

        if run_task "$TASK"; then
            SUCCESS=true
            log "OK      | Tentative $attempt réussie"
            break
        else
            EXIT_CODE=$?
            log "FAIL    | Tentative $attempt échouée (exit $EXIT_CODE)"
            if [ $attempt -lt $MAX_RETRIES ]; then
                DELAY=${RETRY_DELAYS[$((attempt-1))]}
                log "WAIT    | Retry dans ${DELAY}s"
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
        log "PAUSE   | $TASK → 3 tentatives épuisées"
        update_queue "paused" "$TASK" "Voir logs/errors.log"
        bash "$SCRIPT_DIR/notify.sh" "$TASK" "PAUSE" 2>/dev/null || true
        bash "$SCRIPT_DIR/post-task.sh" "$TASK" "failure" 2>/dev/null || true
    fi

    # Reset current_task.md
    echo -e "# Current Task\n## Status\nIDLE\n## Active Flow / Task\nnone" \
        > "$PROJECT_DIR/tasks/current_task.md"

    sleep $SLEEP_BETWEEN_TASKS
done
