---
name: pause
description: Pause the loop after current iteration completes. Workers finish their tasks then stop.
---

# Pause Command

Pause the autonomous loop gracefully. Current work completes, then loop stops.

## Usage

```
/pause
```

## Execution

```bash
#!/bin/bash

if [[ ! -f ".claude/loop-state.md" ]]; then
  echo "No active loop to pause."
  exit 0
fi

# Check current state
ACTIVE=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' ".claude/loop-state.md" | \
  grep "^active:" | sed 's/active: *//')

if [[ "$ACTIVE" == "paused" ]]; then
  echo "Loop is already paused."
  echo "Run /resume to continue."
  exit 0
fi

if [[ "$ACTIVE" != "true" ]]; then
  echo "Loop is not running (status: $ACTIVE)"
  exit 0
fi

# Set to paused
sed -i 's/^active: true/active: paused/' ".claude/loop-state.md"

echo "LOOP PAUSED"
echo ""
echo "Current iteration will complete, then loop stops."
echo "Active workers will finish their current tasks."
echo ""
echo "To resume: /resume"
echo "To stop permanently: /abort then delete .claude/loop-state.md"
```

## Behavior

- Current iteration completes normally
- Active workers finish their current chunk
- No new workers are spawned
- Loop state is preserved
- Resume with `/resume` to continue from where you left off
