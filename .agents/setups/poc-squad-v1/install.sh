#!/usr/bin/env bash
# poc-squad v1 — minimal install for throwaway POC / demo work.
# Run from the project root: bash /path/to/poc-squad-v1/install.sh [target-dir]

set -euo pipefail

SOURCE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_SKILLS="$SOURCE/../../skills"
TARGET="${1:-.claude}"

echo "POC Squad — installing into $(pwd)/$TARGET"
echo "  (Usage: install.sh [target-dir]  — e.g. .claude, .cursor, .agents)"
echo ""

mkdir -p "$TARGET/agents" "$TARGET/commands" "$TARGET/skills"
mkdir -p tasks

echo "→ Agents..."
for agent in prototyper; do
  cp "$SOURCE/.claude/agents/$agent.md" "$TARGET/agents/$agent.md" && echo "  ✓ $agent"
done

echo "→ Commands..."
for cmd in poc demo-polish; do
  cp "$SOURCE/.claude/commands/$cmd.md" "$TARGET/commands/$cmd.md" && echo "  ✓ /$cmd"
done

echo "→ Base playbook skills (shared)..."
for skill in clean-code; do
  if [ -f "$BASE_SKILLS/$skill/SKILL.md" ]; then
    mkdir -p "$TARGET/skills/$skill"
    cp "$BASE_SKILLS/$skill/SKILL.md" "$TARGET/skills/$skill/SKILL.md"
    echo "  ✓ $skill (from base playbook)"
  else
    echo "  ⚠ $skill not found at $BASE_SKILLS/$skill — install the base playbook or rerun from a full clone"
  fi
done

[ ! -f "CLAUDE.md" ] && cp "$SOURCE/CLAUDE.md" . && echo "  Created CLAUDE.md"

echo ""
echo "✅ POC Squad installed."
echo ""
echo "Next steps:"
echo "  1. Describe the idea in one sentence."
echo "  2. Start your AI tool and run: /poc <idea>"
echo "  3. When the demo runs: /demo-polish (optional)"
echo ""
echo "When the POC graduates to a real project, switch to dev-squad-v2 or web2-agents-v1."
