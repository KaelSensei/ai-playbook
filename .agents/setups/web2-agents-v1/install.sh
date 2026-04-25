#!/bin/bash
# web2-agents v1 — install into your project
# Run from the project root: bash /path/to/web2-agents-v1/install.sh

set -e

SOURCE="$(cd "$(dirname "$0")" && pwd)"
BASE_SKILLS="$SOURCE/../../skills"
BASE_COMMANDS="$SOURCE/../../commands"
TARGET="${1:-.claude}"

echo ""
echo "web2-agents v1 — installing into $(pwd)/$TARGET"
echo "  (Usage: install.sh [target-dir]  — e.g. .claude, .cursor, .agents)"
echo "──────────────────────────────────────────"

# ── Structure ──────────────────────────────────────────────────────────────

mkdir -p \
  "$TARGET/agents" \
  "$TARGET/commands" \
  "$TARGET/specs" \
  "$TARGET/skills/clean-code" \
  "$TARGET/skills/testing-patterns" \
  "$TARGET/skills/api-design" \
  "$TARGET/skills/database-patterns" \
  "$TARGET/skills/security-web2" \
  "$TARGET/skills/team--skill-review" \
  "$TARGET/skills/observability" \
  "$TARGET/skills/team--skill-refine" \
  "$TARGET/skills/team--skill-lookup" \
  tasks

# ── Agents ─────────────────────────────────────────────────────────────────

for agent in \
  product-owner \
  ux-designer \
  tech-lead \
  architect \
  spec-writer \
  dev-senior-a \
  dev-senior-b \
  qa-engineer \
  security-reviewer \
  data-engineer \
  devops-engineer \
  qa-automation \
  scribe
do
  cp "$SOURCE/.claude/agents/$agent.md" "$TARGET/agents/$agent.md"
done
echo "✓  11 agents"

# ── Domain skills ───────────────────────────────────────────────────────────

for skill in testing-patterns api-design database-patterns; do
  cp "$SOURCE/.claude/skills/$skill/SKILL.md" "$TARGET/skills/$skill/SKILL.md"
done
echo "✓  3 domain skills"

# ── Base playbook skills (shared across setups) ─────────────────────────────

for skill in clean-code security-web2; do
  if [ -f "$BASE_SKILLS/$skill/SKILL.md" ]; then
    cp "$BASE_SKILLS/$skill/SKILL.md" "$TARGET/skills/$skill/SKILL.md"
    echo "✓  $skill (from base playbook)"
  else
    echo "⚠  $skill not found at $BASE_SKILLS/$skill — install the base playbook or rerun from a full clone"
  fi
done

# ── Team skills ─────────────────────────────────────────────────────────────

for skill in team--skill-review team--skill-refine team--skill-lookup observability; do
  cp "$SOURCE/.claude/skills/$skill/SKILL.md" "$TARGET/skills/$skill/SKILL.md"
done
echo "✓  3 team skills"

# ── Commands ────────────────────────────────────────────────────────────────

for cmd in story spec build review check pr; do
  cp "$SOURCE/.claude/commands/$cmd.md" "$TARGET/commands/$cmd.md"
done
echo "✓  5 commands"

# ── Base playbook commands (shared across setups) ───────────────────────────

for cmd_path in devops/setup-ci; do
  cmd_name="$(basename "$cmd_path")"
  src="$BASE_COMMANDS/$cmd_path.md"
  if [ -f "$src" ]; then
    cp "$src" "$TARGET/commands/$cmd_name.md"
    echo "✓  /$cmd_name (from base playbook)"
  else
    echo "⚠  $cmd_path not found at $src — install the base playbook or rerun from a full clone"
  fi
done

# ── Foundation docs ─────────────────────────────────────────────────────────

for doc in project-architecture.md data-architecture.md constants.md; do
  if [ ! -f "$TARGET/$doc" ]; then
    cp "$SOURCE/.claude/$doc" "$TARGET/$doc"
    echo "✓  Created $TARGET/$doc  ← fill in"
  else
    echo "⚠  Skipped $TARGET/$doc  (already exists)"
  fi
done

# ── CLAUDE.md ───────────────────────────────────────────────────────────────

if [ ! -f "CLAUDE.md" ]; then
  cp "$SOURCE/CLAUDE.md" "CLAUDE.md"
  echo "✓  Created CLAUDE.md  ← update Stack + remove unused agents"
else
  echo "⚠  Skipped CLAUDE.md  (already exists — merge the Agent Team table manually)"
fi

# ── Task tracker ────────────────────────────────────────────────────────────

if [ ! -f "tasks/current_task.md" ]; then
  cp "$SOURCE/tasks/current_task.md" "tasks/current_task.md"
  echo "✓  Created tasks/current_task.md"
fi

# ── Permissions Claude Code ─────────────────────────────────────────────────

if [ ! -f "$TARGET/settings.json" ]; then
  cat > "$TARGET/settings.json" << 'EOF'
{
  "permissions": {
    "allow": [
      "Bash(npm:*)",
      "Bash(npx:*)",
      "Bash(yarn:*)",
      "Bash(pnpm:*)",
      "Bash(python:*)",
      "Bash(pytest:*)",
      "Bash(git add:*)",
      "Bash(git commit:*)",
      "Bash(git diff:*)",
      "Bash(git status:*)",
      "Bash(git log:*)"
    ]
  }
}
EOF
  echo "✓  Created $TARGET/settings.json  (Bash permissions)"
fi


# ── Docs structure ────────────────────────────────────────────────────────

mkdir -p "docs/adr" "docs/rollbacks"

if [ ! -f "TEST_PLAN.md" ]; then
  cp "$SOURCE/TEST_PLAN.md" "TEST_PLAN.md"
  echo "✓  Created TEST_PLAN.md  ← configure flows and thresholds"
fi

if [ ! -f "$TARGET/observability.md" ]; then
  cp "$SOURCE/.claude/observability.md" "$TARGET/observability.md"
  echo "✓  Created $TARGET/observability.md  ← configure your observability stack"
fi

if [ ! -f "CHANGELOG.md" ]; then
  cp "$SOURCE/CHANGELOG.md" "CHANGELOG.md"
  echo "✓  Created CHANGELOG.md"
fi

if [ ! -f "PROGRESS.md" ]; then
  cp "$SOURCE/PROGRESS.md" "PROGRESS.md"
  echo "✓  Created PROGRESS.md"
fi

if [ ! -f "docs/adr/README.md" ]; then
  cp "$SOURCE/docs/adr/README.md" "docs/adr/README.md"
  echo "✓  Created docs/adr/README.md"
fi

# ── Summary ─────────────────────────────────────────────────────────────────

echo ""
echo "──────────────────────────────────────────"
echo "Installation complete."
echo ""
echo "Next steps:"
echo ""
echo "  1. Edit CLAUDE.md"
echo "       → Stack: fill in your framework, DB, test runner"
echo "       → Agent Team: remove unused agent rows"
echo ""
echo "  2. Fill in $TARGET/project-architecture.md"
echo "       → Overview, modules, auth, key invariants"
echo ""
echo "  3. Fill in $TARGET/data-architecture.md"
echo "       → DB schema, relations, indexes, migration strategy"
echo ""
echo "  4. Fill in $TARGET/constants.md"
echo "       → Env vars, URLs, versions, rate limits"
echo ""
echo "  5. Start your AI tool, then:"
echo "       /story <need>      → define stories before coding"
echo "       /spec <story>      → technical spec + test list"
echo "       /build <spec>      → strict TDD step by step"
echo "       /review            → review before any merge"
echo "       /check             → QA + security + data before deploy"
echo ""
echo "  Tip: the quality of $TARGET/project-architecture.md"
echo "  determines the quality of every review. Fill it in carefully."
echo ""
