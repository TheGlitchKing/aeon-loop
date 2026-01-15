#!/bin/bash
# Aeon Loop - Stop Hook
# Core loop engine: checks completion, saves checkpoint, re-injects prompt
# Based on ralph-loop with orchestration and safety enhancements

set -euo pipefail

# Read hook input from stdin
HOOK_INPUT=$(cat)

# State file location
LOOP_STATE_FILE=".claude/loop-state.md"

# If no active loop, allow exit
if [[ ! -f "$LOOP_STATE_FILE" ]]; then
  exit 0
fi

# Parse YAML frontmatter
parse_frontmatter() {
  local key="$1"
  sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$LOOP_STATE_FILE" | \
    grep "^${key}:" | sed "s/${key}: *//" | sed 's/^"\(.*\)"$/\1/'
}

ACTIVE=$(parse_frontmatter "active")
ITERATION=$(parse_frontmatter "iteration")
MAX_ITERATIONS=$(parse_frontmatter "max_iterations")
COMPLETION_PROMISE=$(parse_frontmatter "completion_promise")
TASK_SLUG=$(parse_frontmatter "task_slug")
CONSECUTIVE_FAILURES=$(parse_frontmatter "consecutive_failures" || echo "0")
TOTAL_WORKERS=$(parse_frontmatter "total_workers_spawned" || echo "0")

# Validate
if [[ "$ACTIVE" != "true" ]]; then
  exit 0
fi

if [[ ! "$ITERATION" =~ ^[0-9]+$ ]]; then
  echo "Loop state corrupted: invalid iteration" >&2
  rm "$LOOP_STATE_FILE"
  exit 0
fi

if [[ ! "$MAX_ITERATIONS" =~ ^[0-9]+$ ]]; then
  MAX_ITERATIONS=0
fi

# Check max iterations
if [[ $MAX_ITERATIONS -gt 0 ]] && [[ $ITERATION -ge $MAX_ITERATIONS ]]; then
  echo "Max iterations ($MAX_ITERATIONS) reached."

  # Save final checkpoint
  if [[ -d ".claude/memory" ]]; then
    echo "---" > .claude/memory/checkpoint.md
    echo "checkpoint_time: $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> .claude/memory/checkpoint.md
    echo "iteration: $ITERATION" >> .claude/memory/checkpoint.md
    echo "status: max_iterations_reached" >> .claude/memory/checkpoint.md
    echo "---" >> .claude/memory/checkpoint.md
    echo "" >> .claude/memory/checkpoint.md
    echo "## Final State" >> .claude/memory/checkpoint.md
    echo "Loop ended after $ITERATION iterations (max reached)" >> .claude/memory/checkpoint.md
  fi

  rm "$LOOP_STATE_FILE"
  exit 0
fi

# Get transcript path
TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path // empty' 2>/dev/null)

if [[ -z "$TRANSCRIPT_PATH" ]] || [[ ! -f "$TRANSCRIPT_PATH" ]]; then
  echo "Transcript not found" >&2
  rm "$LOOP_STATE_FILE"
  exit 0
fi

# Get last assistant message
if ! grep -q '"role":"assistant"' "$TRANSCRIPT_PATH"; then
  echo "No assistant messages in transcript" >&2
  rm "$LOOP_STATE_FILE"
  exit 0
fi

LAST_LINE=$(grep '"role":"assistant"' "$TRANSCRIPT_PATH" | tail -1)
LAST_OUTPUT=$(echo "$LAST_LINE" | jq -r '
  .message.content |
  map(select(.type == "text")) |
  map(.text) |
  join("\n")
' 2>/dev/null || echo "")

if [[ -z "$LAST_OUTPUT" ]]; then
  echo "No text in last assistant message" >&2
  rm "$LOOP_STATE_FILE"
  exit 0
fi

# Check for completion promise
if [[ -n "$COMPLETION_PROMISE" ]] && [[ "$COMPLETION_PROMISE" != "null" ]]; then
  # Extract text from <promise> tags
  PROMISE_TEXT=$(echo "$LAST_OUTPUT" | \
    perl -0777 -pe 's/.*?<promise>(.*?)<\/promise>.*/$1/s; s/^\s+|\s+$//g; s/\s+/ /g' 2>/dev/null || echo "")

  if [[ -n "$PROMISE_TEXT" ]] && [[ "$PROMISE_TEXT" = "$COMPLETION_PROMISE" ]]; then
    echo "Completion promise detected: $COMPLETION_PROMISE"

    # Save final checkpoint
    mkdir -p .claude/memory
    cat > .claude/memory/checkpoint.md << EOF
---
checkpoint_time: $(date -u +%Y-%m-%dT%H:%M:%SZ)
iteration: $ITERATION
status: complete
task_slug: "$TASK_SLUG"
---

## Task Completed
Loop completed successfully after $ITERATION iterations.
Completion promise: $COMPLETION_PROMISE
EOF

    # Update task_plan.md if it exists
    if [[ -n "$TASK_SLUG" ]] && [[ -f ".planning/$TASK_SLUG/task_plan.md" ]]; then
      sed -i 's/\*\*Currently in Phase.*/**Completed** - All phases done/' ".planning/$TASK_SLUG/task_plan.md"
    fi

    rm "$LOOP_STATE_FILE"
    exit 0
  fi
fi

# Check circuit breaker (5 consecutive failures)
if [[ "$CONSECUTIVE_FAILURES" =~ ^[0-9]+$ ]] && [[ $CONSECUTIVE_FAILURES -ge 5 ]]; then
  echo "CIRCUIT BREAKER: 5 consecutive failures"

  mkdir -p .claude/memory
  cat >> .claude/memory/attention.md << 'EOF'

<!-- ATTENTION -->
CIRCUIT BREAKER TRIPPED
5 consecutive chunk failures detected
Human intervention required
Run /resume to continue or /abort to stop
<!-- /ATTENTION -->
EOF

  # Pause but don't delete state
  sed -i 's/^active: true/active: paused/' "$LOOP_STATE_FILE"
  exit 0
fi

# Check total worker limit (50)
if [[ "$TOTAL_WORKERS" =~ ^[0-9]+$ ]] && [[ $TOTAL_WORKERS -ge 50 ]]; then
  echo "SAFETY LIMIT: 50 workers spawned without completion"

  mkdir -p .claude/memory
  cat >> .claude/memory/attention.md << 'EOF'

<!-- ATTENTION -->
SAFETY LIMIT REACHED
Spawned 50 workers without task completion
This may indicate infinite loop or impossible task
Loop aborted - review orchestration manifest
<!-- /ATTENTION -->
EOF

  rm "$LOOP_STATE_FILE"
  exit 0
fi

# Not complete - continue loop
NEXT_ITERATION=$((ITERATION + 1))

# Save checkpoint before next iteration
mkdir -p .claude/memory
cat > .claude/memory/checkpoint.md << EOF
---
checkpoint_time: $(date -u +%Y-%m-%dT%H:%M:%SZ)
iteration: $NEXT_ITERATION
task_slug: "$TASK_SLUG"
---

## Iteration $ITERATION Summary
Completed iteration $ITERATION, starting iteration $NEXT_ITERATION.

## Context
Read the following files to restore context:
- .claude/memory/attention.md
- .claude/memory/patterns.md
- .planning/$TASK_SLUG/task_plan.md
EOF

# Extract prompt (everything after closing ---)
PROMPT_TEXT=$(awk '/^---$/{i++; next} i>=2' "$LOOP_STATE_FILE")

if [[ -z "$PROMPT_TEXT" ]]; then
  echo "No prompt text in loop state" >&2
  rm "$LOOP_STATE_FILE"
  exit 0
fi

# Update iteration in state file
TEMP_FILE="${LOOP_STATE_FILE}.tmp.$$"
sed "s/^iteration: .*/iteration: $NEXT_ITERATION/" "$LOOP_STATE_FILE" > "$TEMP_FILE"
mv "$TEMP_FILE" "$LOOP_STATE_FILE"

# Build system message
if [[ -n "$COMPLETION_PROMISE" ]] && [[ "$COMPLETION_PROMISE" != "null" ]]; then
  SYSTEM_MSG="Aeon Loop iteration $NEXT_ITERATION | Complete: <promise>$COMPLETION_PROMISE</promise> (only when TRUE)"
else
  SYSTEM_MSG="Aeon Loop iteration $NEXT_ITERATION | No completion promise - loop runs until max iterations"
fi

# Output JSON to block stop and re-inject prompt
jq -n \
  --arg prompt "$PROMPT_TEXT" \
  --arg msg "$SYSTEM_MSG" \
  '{
    "decision": "block",
    "reason": $prompt,
    "systemMessage": $msg
  }'

exit 0
