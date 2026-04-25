#!/bin/bash
set -euo pipefail
SOURCE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_SKILLS="$SOURCE/../../skills"
BASE_COMMANDS="$SOURCE/../../commands"
TARGET="${1:-.claude}"

echo "Dev Squad — installing into $(pwd)/$TARGET"
echo "  (Usage: install.sh [target-dir]  — e.g. .claude, .cursor, .agents)"
echo ""

mkdir -p "$TARGET/agents" "$TARGET/commands" "$TARGET/skills"
mkdir -p tasks docs/adr docs/rollbacks docs/specs

echo "→ Agents..."
for agent in tech-lead dev-senior-a dev-senior-b security-reviewer; do
  cp "$SOURCE/.claude/agents/$agent.md" "$TARGET/agents/$agent.md" && echo "  ✓ $agent"
done

echo "→ Setup-local skills..."
for skill in canon-tdd typescript-patterns code-review-standards api-design-ts react-patterns testing-patterns-ts; do
  [ -d "$SOURCE/.claude/skills/$skill" ] && \
    cp -r "$SOURCE/.claude/skills/$skill" "$TARGET/skills/$skill" && echo "  ✓ $skill"
done

echo "→ Base playbook skills (shared)..."
for skill in clean-architecture security-web2; do
  if [ -d "$BASE_SKILLS/$skill" ]; then
    cp -r "$BASE_SKILLS/$skill" "$TARGET/skills/$skill" && echo "  ✓ $skill (from base playbook)"
  else
    echo "  ⚠ $skill not found at $BASE_SKILLS/$skill — install the base playbook or rerun from a full clone"
  fi
done

echo "→ Commands..."
for cmd in brief build review-pr arbitrate auto; do
  cp "$SOURCE/.claude/commands/$cmd.md" "$TARGET/commands/$cmd.md" && echo "  ✓ /$cmd"
done

echo "→ Base playbook commands (shared)..."
for cmd_path in devops/setup-ci; do
  cmd_name="$(basename "$cmd_path")"
  src="$BASE_COMMANDS/$cmd_path.md"
  if [ -f "$src" ]; then
    cp "$src" "$TARGET/commands/$cmd_name.md" && echo "  ✓ /$cmd_name (from base playbook)"
  else
    echo "  ⚠ $cmd_path not found at $src — install the base playbook or rerun from a full clone"
  fi
done

[ ! -f "$TARGET/project-architecture.md" ] && cp "$SOURCE/.claude/project-architecture.md" "$TARGET/"
[ ! -f "$TARGET/data-architecture.md" ]    && cp "$SOURCE/.claude/data-architecture.md" "$TARGET/"
[ ! -f "$TARGET/constants.md" ]            && cp "$SOURCE/.claude/constants.md" "$TARGET/"
[ ! -f "CLAUDE.md" ]                        && cp "$SOURCE/CLAUDE.md" .

echo ""
echo "✅ Dev Squad installed."
echo ""
echo "Next steps:"
echo "  1. Fill in $TARGET/project-architecture.md"
echo "  2. Fill in $TARGET/data-architecture.md"
echo "  3. Start your AI tool and use: /brief [feature name]"
