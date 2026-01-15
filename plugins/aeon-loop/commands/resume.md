---
name: resume
description: Resume a paused loop from where it left off.
---

# Resume Command

Continue a paused loop from the last checkpoint.

## Usage

```
/resume
```

## Execution

```bash
#!/bin/bash

if [[ ! -f ".claude/loop-state.md" ]]; then
  echo "No loop state found."
  echo ""
  echo "To start a new loop:"
  echo "  /loop \"Your task\" --done \"COMPLETE\""
  exit 0
fi

# Check current state
ACTIVE=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' ".claude/loop-state.md" | \
  grep "^active:" | sed 's/active: *//')

if [[ "$ACTIVE" == "true" ]]; then
  echo "Loop is already running."
  echo "Use /status to check progress."
  exit 0
fi

if [[ "$ACTIVE" != "paused" ]]; then
  echo "Loop state is: $ACTIVE"
  echo "Cannot resume from this state."
  exit 0
fi

# Get task info
TASK_SLUG=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' ".claude/loop-state.md" | \
  grep "^task_slug:" | sed 's/task_slug: *//' | sed 's/^"\(.*\)"$/\1/')
ITERATION=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' ".claude/loop-state.md" | \
  grep "^iteration:" | sed 's/iteration: *//')

# Clear any abort signal
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
if command -v md5sum &>/dev/null; then
  PROJECT_HASH=$(echo "$PROJECT_DIR" | md5sum | cut -c1-8)
else
  PROJECT_HASH="default"
fi
rm -f "/tmp/aeon-loop-abort-$PROJECT_HASH"

# Reset consecutive failures
sed -i 's/^consecutive_failures: .*/consecutive_failures: 0/' ".claude/loop-state.md"

# Set to active
sed -i 's/^active: paused/active: true/' ".claude/loop-state.md"

echo "LOOP RESUMED"
echo ""
echo "Task: $TASK_SLUG"
echo "Continuing from iteration: $ITERATION"
echo ""
echo "Reading context files..."
echo ""

# Output context for Claude
if [[ -f ".claude/memory/checkpoint.md" ]]; then
  echo "## Checkpoint"
  cat .claude/memory/checkpoint.md
  echo ""
fi

if [[ -f ".claude/memory/attention.md" ]]; then
  echo "## Attention"
  cat .claude/memory/attention.md
  echo ""
fi

if [[ -f ".planning/$TASK_SLUG/task_plan.md" ]]; then
  echo "## Task Plan"
  cat ".planning/$TASK_SLUG/task_plan.md"
  echo ""
fi

echo ""
echo "Continue working on the task. The loop is now active."
```

## Behavior

- Clears any abort signal
- Resets consecutive failure counter
- Restores loop to active state
- Outputs context files for Claude to read
- Loop continues from last iteration
