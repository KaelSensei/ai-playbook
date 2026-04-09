#!/bin/bash
# pre-tool-use.sh — Déclenché avant chaque outil Bash
# Rôle : gardrails — bloquer les actions dangereuses, logger

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
LOG_DIR="$PROJECT_DIR/logs"

mkdir -p "$LOG_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] HOOK:PRE | $1" >> "$LOG_DIR/hooks.log"
}

INPUT="${CLAUDE_TOOL_INPUT:-}"

# ── Bloquer les commandes dangereuses ────────────────────────────

# Pas de rm -rf sur le projet
if echo "$INPUT" | grep -qE "rm -rf (\.|\/)"; then
    log "BLOQUÉ : rm -rf détecté"
    echo "HOOK_BLOCK: rm -rf non autorisé sans confirmation manuelle" >&2
    exit 1
fi

# Pas de git push --force sans PR
if echo "$INPUT" | grep -q "git push --force\|git push -f"; then
    log "BLOQUÉ : git push --force détecté"
    echo "HOOK_BLOCK: git push --force non autorisé — utiliser /pr" >&2
    exit 1
fi

# ── Contexte legacy : vérifier le filet avant tout changement ────

SETUP=$(grep -l "legacy-analyst" "$PROJECT_DIR/.claude/agents/" 2>/dev/null | head -1)
if [ -n "$SETUP" ]; then
    # Si c'est un setup legacy et que la commande modifie un fichier
    if echo "$INPUT" | grep -qE "(sed -i|awk.*>|patch )"; then
        # Vérifier que des tests de caractérisation existent
        CHAR_TESTS=$(find "$PROJECT_DIR" -name "*char*" -o -name "*characteriz*" 2>/dev/null | head -1)
        if [ -z "$CHAR_TESTS" ]; then
            log "WARN : Modification legacy sans tests de caractérisation détectés"
            # On warn mais on ne bloque pas — le guardian s'en charge
        fi
    fi
fi

log "Commande autorisée : $(echo "$INPUT" | head -c 80)"

exit 0
