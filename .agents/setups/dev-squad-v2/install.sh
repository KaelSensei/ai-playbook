#!/bin/bash
set -euo pipefail
SOURCE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-.claude}"

echo "Dev Squad — installing into $(pwd)/$TARGET"
echo "  (Usage: install.sh [target-dir]  — e.g. .claude, .cursor, .agents)"
echo ""

mkdir -p "$TARGET/agents" "$TARGET/commands" "$TARGET/skills"
mkdir -p tasks docs/adr docs/rollbacks docs/specs

echo "→ Agents..."
for agent in tech-lead dev-senior-a dev-senior-b; do
  cp "$SOURCE/.claude/agents/$agent.md" "$TARGET/agents/$agent.md" && echo "  ✓ $agent"
done

echo "→ Skills..."
for skill in canon-tdd clean-architecture typescript-patterns code-review-standards api-design-ts react-patterns testing-patterns-ts; do
  [ -d "$SOURCE/.claude/skills/$skill" ] && \
    cp -r "$SOURCE/.claude/skills/$skill" "$TARGET/skills/$skill" && echo "  ✓ $skill"
done

echo "→ Commands..."
for cmd in brief build review-pr arbitrate; do
  cp "$SOURCE/.claude/commands/$cmd.md" "$TARGET/commands/$cmd.md" && echo "  ✓ /$cmd"
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
