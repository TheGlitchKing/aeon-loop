#!/bin/bash
# Aeon Loop - Pre Tool Use Hook
# Checks for abort signal before tool execution
# Only outputs valid JSON, nothing else

# Ensure clean output - no errors to stderr
exec 2>/dev/null

# Read input (ignore if empty/missing)
read -r INPUT || INPUT=""

# Try to get project directory from input
CWD=""
if command -v jq &>/dev/null && [ -n "$INPUT" ]; then
    CWD=$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null) || CWD=""
fi

# Determine project directory with fallbacks
if [ -n "$CLAUDE_PROJECT_DIR" ]; then
    PROJECT_DIR="$CLAUDE_PROJECT_DIR"
elif [ -n "$CWD" ]; then
    PROJECT_DIR="$CWD"
else
    PROJECT_DIR="$(pwd 2>/dev/null)" || PROJECT_DIR="/tmp"
fi

# Generate hash for project-specific abort file
if command -v md5sum &>/dev/null; then
    PROJECT_HASH=$(echo "$PROJECT_DIR" | md5sum 2>/dev/null | cut -c1-8) || PROJECT_HASH="default"
elif command -v md5 &>/dev/null; then
    PROJECT_HASH=$(echo "$PROJECT_DIR" | md5 2>/dev/null | cut -c1-8) || PROJECT_HASH="default"
else
    PROJECT_HASH="default"
fi

SIGNAL_FILE="/tmp/aeon-loop-abort-${PROJECT_HASH}"

# Check abort signal and output ONLY valid JSON
if [ -f "$SIGNAL_FILE" ]; then
    # Abort is active - block the tool
    printf '{"decision":"deny","reason":"Abort signal active. Run /abort clear to resume."}\n'
else
    # No abort - allow the tool
    printf '{"decision":"allow"}\n'
fi

exit 0
