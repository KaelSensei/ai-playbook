#!/bin/bash
# web3-agents v3 — install into your project
# Run from your project root: bash /path/to/web3-agents-v3/install.sh

set -e

SOURCE="$(cd "$(dirname "$0")" && pwd)"
BASE_SKILLS="$SOURCE/../../skills"
BASE_COMMANDS="$SOURCE/../../commands"
TARGET="${1:-.claude}"

echo ""
echo "web3-agents v3 — installing into $(pwd)/$TARGET"
echo "  (Usage: install.sh [target-dir]  — e.g. .claude, .cursor, .agents)"
echo "────────────────────────────────────────"

# ── Directory structure ─────────────────────────────────────────────────────

mkdir -p \
  "$TARGET/agents" \
  "$TARGET/commands" \
  "$TARGET/specs" \
  "$TARGET/skills/solidity-patterns" \
  "$TARGET/skills/foundry-testing" \
  "$TARGET/skills/defi-protocols" \
  "$TARGET/skills/web3-frontend" \
  "$TARGET/skills/security-web3" \
  "$TARGET/skills/team--skill-review" \
  "$TARGET/skills/observability" \
  "$TARGET/skills/team--skill-refine" \
  "$TARGET/skills/team--skill-lookup" \
  tasks

# ── Agents ──────────────────────────────────────────────────────────────────

for agent in \
  smart-contract-engineer \
  smart-contract-security-reviewer \
  infra-engineer \
  devops-engineer \
  frontend-engineer \
  backend-engineer \
  architect \
  spec-writer \
  rust-reviewer
do
  cp "$SOURCE/.claude/agents/$agent.md" "$TARGET/agents/$agent.md"
done
echo "✓  9 agents"

# ── Domain skills ────────────────────────────────────────────────────────────

for skill in solidity-patterns foundry-testing defi-protocols web3-frontend; do
  cp "$SOURCE/.claude/skills/$skill/SKILL.md" "$TARGET/skills/$skill/SKILL.md"
done
echo "✓  4 domain skills"

# ── Base playbook skills (shared across setups) ─────────────────────────────

for skill in security-web3; do
  if [ -f "$BASE_SKILLS/$skill/SKILL.md" ]; then
    cp "$BASE_SKILLS/$skill/SKILL.md" "$TARGET/skills/$skill/SKILL.md"
    echo "✓  $skill (from base playbook)"
  else
    echo "⚠  $skill not found at $BASE_SKILLS/$skill — install the base playbook or rerun from a full clone"
  fi
done

# ── Team skills ──────────────────────────────────────────────────────────────

for skill in team--skill-review team--skill-refine team--skill-lookup observability; do
  cp "$SOURCE/.claude/skills/$skill/SKILL.md" "$TARGET/skills/$skill/SKILL.md"
done
echo "✓  3 team skills"

# ── Commands ─────────────────────────────────────────────────────────────────

for cmd in research spec implement review pr; do
  cp "$SOURCE/.claude/commands/$cmd.md" "$TARGET/commands/$cmd.md"
done
echo "✓  4 commands"

# ── Foundation docs (only if not already present) ────────────────────────────

for doc in project-architecture.md data-architecture.md constants.md; do
  if [ ! -f "$TARGET/$doc" ]; then
    cp "$SOURCE/.claude/$doc" "$TARGET/$doc"
    echo "✓  Created $TARGET/$doc  ← fill this in"
  else
    echo "⚠  Skipped $TARGET/$doc  (already exists — merge manually if needed)"
  fi
done

# ── CLAUDE.md ────────────────────────────────────────────────────────────────

if [ ! -f "CLAUDE.md" ]; then
  cp "$SOURCE/CLAUDE.md" "CLAUDE.md"
  echo "✓  Created CLAUDE.md  ← update Stack section + remove unused agents"
else
  echo "⚠  Skipped CLAUDE.md  (already exists — merge ## Agent Team table manually)"
fi

# ── Task tracker ─────────────────────────────────────────────────────────────

if [ ! -f "tasks/current_task.md" ]; then
  cp "$SOURCE/tasks/current_task.md" "tasks/current_task.md"
  echo "✓  Created tasks/current_task.md"
fi

# ── Summary ──────────────────────────────────────────────────────────────────

echo ""
echo "────────────────────────────────────────"
echo "Installation complete."
echo ""
echo "Next steps:"
echo ""
echo "  1. Edit CLAUDE.md"
echo "       → Stack: fill in your chain, contracts, frontend, indexer"
echo "       → Agent Team: remove unused agent rows"
echo ""
echo "  2. Fill in $TARGET/project-architecture.md"
echo "       → System overview, component map, trust model, key invariants"
echo ""
echo "  3. Fill in $TARGET/data-architecture.md"
echo "       → Storage layout, events, indexer schema, data flow"
echo ""
echo "  4. Fill in $TARGET/constants.md"
echo "       → Contract addresses per chain, env vars, toolchain versions"
echo ""
echo "  5. Start your AI tool, then:"
echo "       /research <topic>          — before speccing anything unknown"
echo "       /spec <feature>            — before writing any code"
echo "       /implement <spec-slug>     — after spec is approved"
echo "       /review                    — on any diff before deployment"
echo ""
echo "  Tip: the quality of $TARGET/project-architecture.md determines"
echo "       the quality of every agent review. Fill it in carefully."
echo ""
