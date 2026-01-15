---
name: abort
description: Stop all agents immediately by creating abort signal. Use /abort clear to resume.
argument-hint: "[clear|status]"
---

# Abort Command

Create or clear the abort signal to stop all agents (main loop and subagents).

## Usage

```
/abort          # Create abort signal - stops all tool execution
/abort clear    # Clear abort signal - resume normal operation
/abort status   # Check if abort signal is active
```

## How It Works

The abort system uses a signal file that is checked before every tool execution:

1. `/abort` creates `/tmp/aeon-loop-abort-{project-hash}`
2. PreToolUse hook checks for this file before every Bash/Edit/Write/Task
3. If file exists, tool execution is blocked with message
4. `/abort clear` removes the file, resuming operation

## Execution

```bash
#!/bin/bash

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

if command -v md5sum &>/dev/null; then
  PROJECT_HASH=$(echo "$PROJECT_DIR" | md5sum | cut -c1-8)
elif command -v md5 &>/dev/null; then
  PROJECT_HASH=$(echo "$PROJECT_DIR" | md5 | cut -c1-8)
else
  PROJECT_HASH="default"
fi

SIGNAL_FILE="/tmp/aeon-loop-abort-$PROJECT_HASH"

case "${1:-}" in
  clear)
    if [[ -f "$SIGNAL_FILE" ]]; then
      rm -f "$SIGNAL_FILE"
      echo "Abort signal cleared. Operations resumed."
    else
      echo "No abort signal was active."
    fi
    ;;
  status)
    if [[ -f "$SIGNAL_FILE" ]]; then
      echo "Abort signal is ACTIVE"
      echo "Created: $(stat -c %y "$SIGNAL_FILE" 2>/dev/null || stat -f %Sm "$SIGNAL_FILE" 2>/dev/null)"
      echo "Run '/abort clear' to resume."
    else
      echo "No abort signal active. Operations running normally."
    fi
    ;;
  *)
    touch "$SIGNAL_FILE"
    echo "ABORT SIGNAL CREATED"
    echo ""
    echo "All tool execution is now blocked."
    echo "This affects:"
    echo "  - Main loop agent"
    echo "  - All worker subagents"
    echo "  - Any spawned Task agents"
    echo ""
    echo "To resume: /abort clear"
    ;;
esac
```

## When to Use

- **Emergency stop**: Something is going wrong, stop everything now
- **Runaway loop**: Loop seems stuck or infinite
- **Wrong direction**: Claude is doing something unexpected
- **Need to intervene**: Want to manually fix something before continuing

## Note

- Abort only prevents NEW tool executions
- Currently running API calls will complete
- Loop state is preserved - you can resume after `/abort clear`
- For permanent stop, delete `.claude/loop-state.md`
