#!/bin/bash
# on-stop.sh — Déclenché par le hook "Stop" de Claude Code
# S'exécute quand Claude termine une réponse complète
# Rôle : vérifier si la tâche courante est terminée et lancer la suivante

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
QUEUE_FILE="$PROJECT_DIR/QUEUE.md"
TASK_FILE="$PROJECT_DIR/tasks/current_task.md"
LOG_DIR="$PROJECT_DIR/logs"

mkdir -p "$LOG_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] HOOK:STOP | $1" >> "$LOG_DIR/hooks.log"
}

# ── Lire le statut de la tâche courante ──────────────────────────

if [ ! -f "$TASK_FILE" ]; then
    log "Pas de current_task.md — rien à faire"
    exit 0
fi

STATUS=$(grep "^## Status" "$TASK_FILE" -A1 | tail -1 | tr -d ' ')

log "Status courant : $STATUS"

# ── Si tâche IDLE → vérifier la queue ────────────────────────────

if [ "$STATUS" = "IDLE" ]; then
    if [ ! -f "$QUEUE_FILE" ]; then
        log "Pas de QUEUE.md — mode manuel uniquement"
        exit 0
    fi

    # Y a-t-il une prochaine tâche ?
    NEXT=$(grep -m1 "^- \[ \]" "$QUEUE_FILE" 2>/dev/null | sed 's/^- \[ \] //' | sed 's/ _(démarrée.*)//')

    if [ -z "$NEXT" ]; then
        log "Queue vide — supervisor en attente"
        exit 0
    fi

    log "Prochaine tâche détectée : $NEXT"

    # Écrire la prochaine tâche dans un fichier "pending"
    # Le supervisor le lira et déclenchera Claude Code
    echo "$NEXT" > "$PROJECT_DIR/tasks/next_task.pending"
    log "Fichier next_task.pending créé → supervisor va démarrer"
fi

# ── Si tâche SUCCESS (détecté dans current_task) ─────────────────

if echo "$STATUS" | grep -q "SUCCESS\|COMPLETE\|DONE"; then
    log "Tâche terminée avec succès"

    # Archiver dans QUEUE.md si applicable
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
        f'- [x] {task_name} _(terminée le {timestamp})_\n',
        content
    )
    with open('$QUEUE_FILE', 'w') as f:
        f.write(content)
    print(f"QUEUE.md mis à jour : {task_name} → Terminé")
PYEOF
    fi
fi

exit 0
