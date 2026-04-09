#!/bin/bash
set -euo pipefail
SOURCE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-.claude}"

echo "PM-BA Squad — installing into $(pwd)/$TARGET"
echo "  (Usage: install.sh [target-dir]  — e.g. .claude, .cursor, .agents)"
echo ""

mkdir -p "$TARGET/agents" "$TARGET/commands" "$TARGET/skills"
mkdir -p tasks docs/specs docs/adr

echo "→ Agents..."
for agent in product-owner business-analyst spec-reviewer; do
  cp "$SOURCE/.claude/agents/$agent.md" "$TARGET/agents/$agent.md" && echo "  ✓ $agent"
done

echo "→ Skills..."
for skill in bdd-gherkin spec-writing acceptance-criteria domain-language refinement-process; do
  [ -d "$SOURCE/.claude/skills/$skill" ] && \
    cp -r "$SOURCE/.claude/skills/$skill" "$TARGET/skills/$skill" && echo "  ✓ $skill"
done

echo "→ Commands..."
for cmd in story spec review-spec; do
  cp "$SOURCE/.claude/commands/$cmd.md" "$TARGET/commands/$cmd.md" && echo "  ✓ /$cmd"
done

[ ! -f "$TARGET/project-architecture.md" ] && cp "$SOURCE/.claude/project-architecture.md" "$TARGET/"
[ ! -f "$TARGET/constants.md" ]            && cp "$SOURCE/.claude/constants.md" "$TARGET/"
[ ! -f "CLAUDE.md" ]                        && cp "$SOURCE/CLAUDE.md" .

echo ""
echo "✅ PM-BA Squad installed."
echo ""
echo "Next steps:"
echo "  1. Fill in $TARGET/constants.md with personas and project context"
echo "  2. Start your AI tool and use: /story [raw need]"
