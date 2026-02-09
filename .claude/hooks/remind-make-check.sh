#!/bin/bash
# PostToolUse hook: remind to run make check after editing source files
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

case "$FILE_PATH" in
  */backend/app/*|*/backend/tests/*)
    echo "[Hook] Backend source changed. Run \`make check\` in backend/ before committing."
    ;;
  */frontend/src/*)
    echo "[Hook] Frontend source changed. Run \`make check\` in frontend/ before committing."
    ;;
esac

exit 0
