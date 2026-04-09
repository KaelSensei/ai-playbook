#!/bin/bash
# legacy-agents v1 — installer dans ton projet legacy
# Lancer depuis la racine du projet : bash /path/to/legacy-agents-v1/install.sh

set -e

SOURCE="$(cd "$(dirname "$0")" && pwd)"
TARGET="${1:-.claude}"

echo ""
echo "legacy-agents v1 — installing into $(pwd)/$TARGET"
echo "  (Usage: install.sh [target-dir]  — e.g. .claude, .cursor, .agents)"
echo "─────────────────────────────────────────────"

# ── Structure ─────────────────────────────────────────────────────────────

mkdir -p \
  "$TARGET/agents" \
  "$TARGET/commands" \
  "$TARGET/specs" \
  "$TARGET/skills/legacy-patterns" \
  "$TARGET/skills/refactoring-patterns" \
  "$TARGET/skills/strangler-fig" \
  "$TARGET/skills/technical-debt" \
  "$TARGET/skills/testing-patterns" \
  "$TARGET/skills/clean-code" \
  "$TARGET/skills/security-web2" \
  "$TARGET/skills/database-patterns" \
  "$TARGET/skills/team--skill-review" \
  "$TARGET/skills/observability" \
  "$TARGET/skills/team--skill-refine" \
  "$TARGET/skills/team--skill-lookup" \
  tasks

# ── Agents ────────────────────────────────────────────────────────────────

for agent in \
  legacy-analyst \
  archaeologist \
  characterization-tester \
  refactoring-guide \
  debt-tracker \
  dev-senior-a \
  dev-senior-b \
  architect \
  tech-lead \
  security-reviewer \
  data-engineer
do
  cp "$SOURCE/.claude/agents/$agent.md" "$TARGET/agents/$agent.md"
done
echo "✓  11 agents"

# ── Skills legacy-spécifiques ─────────────────────────────────────────────

for skill in legacy-patterns refactoring-patterns strangler-fig technical-debt; do
  cp "$SOURCE/.claude/skills/$skill/SKILL.md" "$TARGET/skills/$skill/SKILL.md"
done
echo "✓  4 skills legacy-spécifiques"

# ── Skills partagés ───────────────────────────────────────────────────────

for skill in testing-patterns clean-code security-web2 database-patterns; do
  cp "$SOURCE/.claude/skills/$skill/SKILL.md" "$TARGET/skills/$skill/SKILL.md"
done
echo "✓  4 skills partagés"

# ── Team skills ───────────────────────────────────────────────────────────

for skill in team--skill-review team--skill-refine team--skill-lookup observability; do
  cp "$SOURCE/.claude/skills/$skill/SKILL.md" "$TARGET/skills/$skill/SKILL.md"
done
echo "✓  3 team skills"

# ── Commands ──────────────────────────────────────────────────────────────

for cmd in understand characterize refactor strangler debt review pr; do
  cp "$SOURCE/.claude/commands/$cmd.md" "$TARGET/commands/$cmd.md"
done
echo "✓  6 commandes"

# ── Foundation docs ───────────────────────────────────────────────────────

for doc in project-architecture.md legacy-map.md constants.md; do
  if [ ! -f "$TARGET/$doc" ]; then
    cp "$SOURCE/.claude/$doc" "$TARGET/$doc"
    echo "✓  Créé $TARGET/$doc  ← à remplir"
  else
    echo "⚠  Ignoré $TARGET/$doc  (existe déjà)"
  fi
done

# ── CLAUDE.md ─────────────────────────────────────────────────────────────

if [ ! -f "CLAUDE.md" ]; then
  cp "$SOURCE/CLAUDE.md" "CLAUDE.md"
  echo "✓  Créé CLAUDE.md  ← mettre à jour Stack"
else
  echo "⚠  Ignoré CLAUDE.md  (existe déjà)"
fi

# ── Task tracker ──────────────────────────────────────────────────────────

if [ ! -f "tasks/current_task.md" ]; then
  cp "$SOURCE/tasks/current_task.md" "tasks/current_task.md"
  echo "✓  Créé tasks/current_task.md"
fi

# ── Permissions ───────────────────────────────────────────────────────────

if [ ! -f "$TARGET/settings.json" ]; then
  cat > "$TARGET/settings.json" << 'EOF'
{
  "permissions": {
    "allow": [
      "Bash(git add:*)",
      "Bash(git commit:*)",
      "Bash(git diff:*)",
      "Bash(git log:*)",
      "Bash(git blame:*)",
      "Bash(git bisect:*)",
      "Bash(git revert:*)",
      "Bash(find:*)",
      "Bash(grep:*)",
      "Bash(wc:*)"
    ]
  }
}
EOF
  echo "✓  Créé $TARGET/settings.json"
fi


# ── Docs structure ────────────────────────────────────────────────────────

mkdir -p "docs/adr" "docs/rollbacks"

if [ ! -f "TEST_PLAN.md" ]; then
  cp "$SOURCE/TEST_PLAN.md" "TEST_PLAN.md"
  echo "✓  Créé TEST_PLAN.md  ← configurer les flows et seuils"
fi

if [ ! -f "$TARGET/observability.md" ]; then
  cp "$SOURCE/.claude/observability.md" "$TARGET/observability.md"
  echo "✓  Créé $TARGET/observability.md  ← configurer ton stack observabilité"
fi

if [ ! -f "CHANGELOG.md" ]; then
  cp "$SOURCE/CHANGELOG.md" "CHANGELOG.md"
  echo "✓  Créé CHANGELOG.md"
fi

if [ ! -f "PROGRESS.md" ]; then
  cp "$SOURCE/PROGRESS.md" "PROGRESS.md"
  echo "✓  Créé PROGRESS.md"
fi

if [ ! -f "docs/adr/README.md" ]; then
  cp "$SOURCE/docs/adr/README.md" "docs/adr/README.md"
  echo "✓  Créé docs/adr/README.md"
fi

# ── Résumé ────────────────────────────────────────────────────────────────

echo ""
echo "─────────────────────────────────────────────"
echo "Installation complete."
echo ""
echo "Next steps:"
echo ""
echo "  1. Edit CLAUDE.md"
echo "       → Stack: language, framework, DB, version, codebase age"
echo "       → Agent Team: remove unused agents"
echo ""
echo "  2. Fill in $TARGET/project-architecture.md"
echo "       → What the system does, known modules, risk zones"
echo ""
echo "  3. $TARGET/legacy-map.md is empty at first — that's normal."
echo "       It fills up as you run /understand."
echo ""
echo "  4. Fill in $TARGET/constants.md"
echo "       → Known env vars, versions, URLs per environment"
echo ""
echo "  5. Start your AI tool, then:"
echo "       /understand <first module to explore>"
echo "       /debt                    — global debt audit"
echo ""
echo "  Golden rule: UNDERSTAND → CHARACTERIZE → REFACTOR or STRANGLER"
echo "  Never skip a step."
echo ""
