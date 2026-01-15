#!/bin/bash
# Aeon Loop - Post Bash Hook
# Captures errors from bash commands to patterns.md and errors.md

set -euo pipefail
exec 2>/dev/null

# Read hook input
read -r INPUT || INPUT=""

# Parse input
EXIT_CODE=$(echo "$INPUT" | jq -r '.exit_code // 0' 2>/dev/null || echo "0")
STDOUT=$(echo "$INPUT" | jq -r '.stdout // ""' 2>/dev/null || echo "")
STDERR=$(echo "$INPUT" | jq -r '.stderr // ""' 2>/dev/null || echo "")
COMMAND=$(echo "$INPUT" | jq -r '.command // ""' 2>/dev/null || echo "")

# Only process if there was an error
if [[ "$EXIT_CODE" != "0" ]] && [[ "$EXIT_CODE" != "" ]]; then
  mkdir -p .claude/memory

  TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

  # Append to errors.md
  cat >> .claude/memory/errors.md << EOF

## $TIMESTAMP
Command: $COMMAND
Exit code: $EXIT_CODE
Output:
\`\`\`
${STDERR:-$STDOUT}
\`\`\`

EOF

  # Extract common error patterns and add to patterns.md
  ERROR_OUTPUT="${STDERR:-$STDOUT}"

  # Check for common patterns
  PATTERN=""
  if echo "$ERROR_OUTPUT" | grep -q "command not found"; then
    PATTERN="Command not found - check if tool is installed"
  elif echo "$ERROR_OUTPUT" | grep -q "Permission denied"; then
    PATTERN="Permission denied - may need sudo or chmod"
  elif echo "$ERROR_OUTPUT" | grep -q "No such file or directory"; then
    PATTERN="File not found - check path exists"
  elif echo "$ERROR_OUTPUT" | grep -q "Cannot find module"; then
    PATTERN="Module not found - run npm install or check imports"
  elif echo "$ERROR_OUTPUT" | grep -q "ECONNREFUSED"; then
    PATTERN="Connection refused - check if service is running"
  elif echo "$ERROR_OUTPUT" | grep -q "TypeError"; then
    PATTERN="TypeError - check types and null/undefined values"
  elif echo "$ERROR_OUTPUT" | grep -q "SyntaxError"; then
    PATTERN="SyntaxError - check for typos in code"
  fi

  if [[ -n "$PATTERN" ]]; then
    # Check if pattern already exists
    if ! grep -q "$PATTERN" .claude/memory/patterns.md 2>/dev/null; then
      cat >> .claude/memory/patterns.md << EOF

## Pattern: $PATTERN
First seen: $TIMESTAMP
Command: $COMMAND
EOF
    fi
  fi

  # Update consecutive failures in loop state if active
  if [[ -f ".claude/loop-state.md" ]]; then
    CURRENT_FAILURES=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' ".claude/loop-state.md" | \
      grep "^consecutive_failures:" | sed 's/consecutive_failures: *//' || echo "0")

    if [[ "$CURRENT_FAILURES" =~ ^[0-9]+$ ]]; then
      NEW_FAILURES=$((CURRENT_FAILURES + 1))

      if grep -q "^consecutive_failures:" ".claude/loop-state.md"; then
        sed -i "s/^consecutive_failures: .*/consecutive_failures: $NEW_FAILURES/" ".claude/loop-state.md"
      else
        # Add if not present (after last ---)
        sed -i "/^---$/a consecutive_failures: $NEW_FAILURES" ".claude/loop-state.md"
      fi
    fi
  fi
fi

exit 0
