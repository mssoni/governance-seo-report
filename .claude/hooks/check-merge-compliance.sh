#!/bin/bash
# PreToolUse hook: check merge compliance before git merge commands
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [ -z "$COMMAND" ]; then
  exit 0
fi

# Check if this is a git merge command
if echo "$COMMAND" | grep -qE 'git\s+merge.*--no-ff'; then
  echo "[Hook] Merge detected. Ensure ./scripts/validate_change.sh CHG-NNN passed. Ensure MERGE_TRANSACTIONS.md has a STARTED entry."
  exit 0
fi

# Check if committing directly to main
if echo "$COMMAND" | grep -qE 'git\s+commit'; then
  PROJ_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
  for subdir in "$PROJ_DIR/backend" "$PROJ_DIR/frontend"; do
    if [ -d "$subdir/.git" ]; then
      BRANCH=$(git -C "$subdir" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
      if [ "$BRANCH" = "main" ]; then
        echo "[Hook] WARNING: $(basename "$subdir") is on main. Create a feature branch first (change/CHG-NNN-desc)."
        exit 0
      fi
    fi
  done
fi

exit 0
