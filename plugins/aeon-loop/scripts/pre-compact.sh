#!/bin/bash
# Aeon Loop - Pre Compact Hook
# Saves attention markers and checkpoint before context compaction

set -euo pipefail
exec 2>/dev/null

# Create memory directory if needed
mkdir -p .claude/memory

# Read current conversation from stdin if available
CONVERSATION=""
read -r -t 1 CONVERSATION || CONVERSATION=""

# Save checkpoint with current state
if [[ -f ".claude/loop-state.md" ]]; then
  ITERATION=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' ".claude/loop-state.md" | \
    grep "^iteration:" | sed 's/iteration: *//' || echo "0")
  TASK_SLUG=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' ".claude/loop-state.md" | \
    grep "^task_slug:" | sed 's/task_slug: *//' | sed 's/^"\(.*\)"$/\1/' || echo "")

  cat > .claude/memory/checkpoint.md << EOF
---
checkpoint_time: $(date -u +%Y-%m-%dT%H:%M:%SZ)
iteration: $ITERATION
task_slug: "$TASK_SLUG"
trigger: pre_compact
---

## Pre-Compaction Checkpoint
Context is being compacted. This checkpoint preserves state.

## Critical Files to Read After Compaction
1. .claude/memory/attention.md - Critical context
2. .claude/memory/patterns.md - Learned patterns
3. .planning/$TASK_SLUG/task_plan.md - Current goals

## Orchestration State
$(if [[ -f ".claude/orchestration/manifest.md" ]]; then
  sed -n '/^---$/,/^---$/{ /^---$/d; p; }' ".claude/orchestration/manifest.md"
else
  echo "No active orchestration"
fi)
EOF
fi

# Ensure attention.md exists with at least basic info
if [[ ! -f ".claude/memory/attention.md" ]] && [[ -f ".claude/loop-state.md" ]]; then
  TASK_SLUG=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' ".claude/loop-state.md" | \
    grep "^task_slug:" | sed 's/task_slug: *//' | sed 's/^"\(.*\)"$/\1/' || echo "")

  if [[ -n "$TASK_SLUG" ]]; then
    cat > .claude/memory/attention.md << EOF
<!-- ATTENTION -->
Task: $TASK_SLUG
Plan: .planning/$TASK_SLUG/task_plan.md
<!-- /ATTENTION -->
EOF
  fi
fi

# Output confirmation (will be included in compacted context)
echo "Pre-compact checkpoint saved to .claude/memory/checkpoint.md"

exit 0
