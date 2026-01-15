#!/bin/bash
# Aeon Loop - Session Start Hook
# Loads context from memory files at session/iteration start

set -euo pipefail

# Suppress stderr to keep output clean
exec 2>/dev/null

OUTPUT=""

# Parse state block from file for progress tracking
parse_state_block() {
  local file="$1"
  local type="$2"  # "stories" or "phases"
  if [[ -f "$file" ]]; then
    # Extract content between <!-- STATE and /STATE -->
    local state=$(sed -n '/<!-- STATE/,/\/STATE -->/p' "$file" 2>/dev/null)
    if [[ -n "$state" ]]; then
      if [[ "$type" == "stories" ]]; then
        # Count completed vs total stories
        local total
        total=$(echo "$state" | grep -c "id: US-" 2>/dev/null) || total=0
        local done
        done=$(echo "$state" | grep -c "passes: true" 2>/dev/null) || done=0
        if [[ $total -gt 0 ]]; then
          echo "Stories: $done/$total complete"
        fi
      elif [[ "$type" == "phases" ]]; then
        # Count completed vs total phases
        local total
        total=$(echo "$state" | grep -c "id: [0-9]" 2>/dev/null) || total=0
        local done
        done=$(echo "$state" | grep -c "passes: true" 2>/dev/null) || done=0
        if [[ $total -gt 0 ]]; then
          echo "Phases: $done/$total complete"
        fi
      fi
    fi
  fi
}

# Load checkpoint if exists
if [[ -f ".claude/memory/checkpoint.md" ]]; then
  OUTPUT+="## Previous Checkpoint\n"
  OUTPUT+="$(cat .claude/memory/checkpoint.md)\n\n"
fi

# Load attention markers if exists
if [[ -f ".claude/memory/attention.md" ]]; then
  OUTPUT+="## Attention (Critical Context)\n"
  OUTPUT+="$(cat .claude/memory/attention.md)\n\n"
fi

# Load patterns if exists
if [[ -f ".claude/memory/patterns.md" ]]; then
  OUTPUT+="## Learned Patterns\n"
  OUTPUT+="$(cat .claude/memory/patterns.md)\n\n"
fi

# Check for active loop
if [[ -f ".claude/loop-state.md" ]]; then
  # Parse loop state
  ACTIVE=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' ".claude/loop-state.md" | \
    grep "^active:" | sed 's/active: *//')
  ITERATION=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' ".claude/loop-state.md" | \
    grep "^iteration:" | sed 's/iteration: *//')
  TASK_SLUG=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' ".claude/loop-state.md" | \
    grep "^task_slug:" | sed 's/task_slug: *//' | sed 's/^"\(.*\)"$/\1/')

  if [[ "$ACTIVE" == "true" ]]; then
    OUTPUT+="## Active Loop\n"
    OUTPUT+="Iteration: $ITERATION\n"
    OUTPUT+="Task: $TASK_SLUG\n"

    # Show progress from state blocks
    if [[ -n "$TASK_SLUG" ]]; then
      # Check PRD for story progress
      if [[ -f ".planning/$TASK_SLUG/prd.md" ]]; then
        story_progress=$(parse_state_block ".planning/$TASK_SLUG/prd.md" "stories")
        if [[ -n "$story_progress" ]]; then
          OUTPUT+="$story_progress\n"
        fi
      fi
      # Check task plan for phase progress
      if [[ -f ".planning/$TASK_SLUG/task_plan.md" ]]; then
        phase_progress=$(parse_state_block ".planning/$TASK_SLUG/task_plan.md" "phases")
        if [[ -n "$phase_progress" ]]; then
          OUTPUT+="$phase_progress\n"
        fi
      fi
    fi
    OUTPUT+="\n"

    # Load task plan if exists
    if [[ -n "$TASK_SLUG" ]] && [[ -f ".planning/$TASK_SLUG/task_plan.md" ]]; then
      OUTPUT+="## Task Plan\n"
      OUTPUT+="$(cat ".planning/$TASK_SLUG/task_plan.md")\n\n"
    fi
  elif [[ "$ACTIVE" == "paused" ]]; then
    OUTPUT+="## Loop Paused\n"
    OUTPUT+="Loop is paused. Run /resume to continue or /abort to stop.\n\n"
  fi
fi

# Load orchestration manifest if exists
if [[ -f ".claude/orchestration/manifest.md" ]]; then
  OUTPUT+="## Orchestration Status\n"
  # Just load the frontmatter and chunk status table
  OUTPUT+="$(sed -n '1,/^## Event Log/p' ".claude/orchestration/manifest.md" | head -50)\n\n"
fi

# Clear stale abort signal
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
if command -v md5sum &>/dev/null; then
  PROJECT_HASH=$(echo "$PROJECT_DIR" | md5sum | cut -c1-8)
elif command -v md5 &>/dev/null; then
  PROJECT_HASH=$(echo "$PROJECT_DIR" | md5 | cut -c1-8)
else
  PROJECT_HASH="default"
fi

ABORT_FILE="/tmp/aeon-loop-abort-$PROJECT_HASH"

# Only clear if abort file is old (> 1 hour)
if [[ -f "$ABORT_FILE" ]]; then
  ABORT_AGE=$(($(date +%s) - $(stat -c %Y "$ABORT_FILE" 2>/dev/null || echo "0")))
  if [[ $ABORT_AGE -gt 3600 ]]; then
    rm -f "$ABORT_FILE"
    OUTPUT+="## Note\nCleared stale abort signal (>1 hour old)\n\n"
  fi
fi

# Output if we have anything
if [[ -n "$OUTPUT" ]]; then
  echo -e "$OUTPUT"
fi

exit 0
