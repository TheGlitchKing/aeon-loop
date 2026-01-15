---
name: status
description: Show current loop progress, worker status, and orchestration state.
---

# Status Command

Display comprehensive status of the current loop execution.

## Usage

```
/status
```

## Execution

```bash
#!/bin/bash

echo "═══════════════════════════════════════════════════════════════"
echo " AEON LOOP STATUS"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Check if loop is active
if [[ ! -f ".claude/loop-state.md" ]]; then
  echo " Status: No active loop"
  echo ""
  echo " Start a loop with:"
  echo "   /loop \"Your task\" --done \"COMPLETE\""
  echo ""
  exit 0
fi

# Parse loop state
parse_field() {
  sed -n '/^---$/,/^---$/{ /^---$/d; p; }' ".claude/loop-state.md" | \
    grep "^${1}:" | sed "s/${1}: *//" | sed 's/^"\(.*\)"$/\1/'
}

ACTIVE=$(parse_field "active")
ITERATION=$(parse_field "iteration")
MAX_ITER=$(parse_field "max_iterations")
TASK_SLUG=$(parse_field "task_slug")
PROMISE=$(parse_field "completion_promise")
WORKERS=$(parse_field "workers")
STARTED=$(parse_field "started_at")
FAILURES=$(parse_field "consecutive_failures")
TOTAL_WORKERS=$(parse_field "total_workers_spawned")

# Status line
if [[ "$ACTIVE" == "true" ]]; then
  echo " Status: RUNNING"
elif [[ "$ACTIVE" == "paused" ]]; then
  echo " Status: PAUSED (run /resume to continue)"
else
  echo " Status: $ACTIVE"
fi

echo " Task: $TASK_SLUG"
echo " Started: $STARTED"
echo ""

# Progress bar
if [[ "$MAX_ITER" =~ ^[0-9]+$ ]] && [[ "$MAX_ITER" -gt 0 ]]; then
  PERCENT=$((ITERATION * 100 / MAX_ITER))
  FILLED=$((PERCENT / 5))
  EMPTY=$((20 - FILLED))
  BAR=$(printf '█%.0s' $(seq 1 $FILLED 2>/dev/null) || echo "")
  BAR+=$(printf '░%.0s' $(seq 1 $EMPTY 2>/dev/null) || echo "")
  echo " Progress: [$BAR] $ITERATION/$MAX_ITER iterations ($PERCENT%)"
else
  echo " Progress: Iteration $ITERATION (no limit)"
fi
echo ""

# Orchestration status
if [[ -f ".claude/orchestration/manifest.md" ]]; then
  parse_manifest() {
    sed -n '/^---$/,/^---$/{ /^---$/d; p; }' ".claude/orchestration/manifest.md" | \
      grep "^${1}:" | sed "s/${1}: *//"
  }

  TOTAL_CHUNKS=$(parse_manifest "total_chunks")
  COMPLETED=$(parse_manifest "completed_chunks")
  FAILED=$(parse_manifest "failed_chunks")
  WAVE=$(parse_manifest "current_wave")
  COST=$(parse_manifest "estimated_cost_usd")
  COST_LIMIT=$(parse_manifest "cost_limit_usd")

  if [[ "$TOTAL_CHUNKS" =~ ^[0-9]+$ ]] && [[ "$TOTAL_CHUNKS" -gt 0 ]]; then
    echo " Orchestration:"
    echo "   Chunks: $COMPLETED/$TOTAL_CHUNKS complete"
    echo "   Failed: $FAILED"
    echo "   Wave: $WAVE"
    echo "   Cost: \$$COST / \$$COST_LIMIT limit"
    echo ""
  fi
fi

# Worker status
echo " Workers:"
echo "   Max concurrent: $WORKERS"
echo "   Total spawned: $TOTAL_WORKERS"

# Check active heartbeats
if [[ -d ".claude/orchestration/heartbeats" ]]; then
  ACTIVE_COUNT=0
  NOW=$(date +%s)
  for hb in .claude/orchestration/heartbeats/*.txt; do
    if [[ -f "$hb" ]]; then
      HB_TIME=$(cat "$hb" | head -1)
      HB_EPOCH=$(date -d "$HB_TIME" +%s 2>/dev/null || echo "0")
      AGE=$((NOW - HB_EPOCH))
      if [[ $AGE -lt 90 ]]; then
        ACTIVE_COUNT=$((ACTIVE_COUNT + 1))
        WORKER_ID=$(basename "$hb" .txt)
        echo "   Active: $WORKER_ID (${AGE}s ago)"
      fi
    fi
  done
  if [[ $ACTIVE_COUNT -eq 0 ]]; then
    echo "   Active: none"
  fi
fi
echo ""

# Safety status
echo " Safety:"
echo "   Consecutive failures: $FAILURES/5 (circuit breaker)"

# Check abort signal
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
if command -v md5sum &>/dev/null; then
  PROJECT_HASH=$(echo "$PROJECT_DIR" | md5sum | cut -c1-8)
else
  PROJECT_HASH="default"
fi
if [[ -f "/tmp/aeon-loop-abort-$PROJECT_HASH" ]]; then
  echo "   Abort signal: ACTIVE (run /abort clear to resume)"
else
  echo "   Abort signal: none"
fi
echo ""

# Completion
echo " Completion:"
if [[ -n "$PROMISE" ]] && [[ "$PROMISE" != "null" ]]; then
  echo "   Promise: <promise>$PROMISE</promise>"
else
  echo "   Promise: (none - runs until max iterations)"
fi
echo ""

# Recent errors
if [[ -f ".claude/memory/errors.md" ]]; then
  ERROR_COUNT=$(grep -c "^## " .claude/memory/errors.md 2>/dev/null || echo "0")
  if [[ "$ERROR_COUNT" -gt 0 ]]; then
    echo " Recent Errors: $ERROR_COUNT captured"
    echo "   See: .claude/memory/errors.md"
  fi
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
```

## Output Example

```
═══════════════════════════════════════════════════════════════
 AEON LOOP STATUS
═══════════════════════════════════════════════════════════════

 Status: RUNNING
 Task: build-rest-api
 Started: 2026-01-14T15:00:00Z

 Progress: [████████░░░░░░░░░░░░] 8/50 iterations (16%)

 Orchestration:
   Chunks: 5/12 complete
   Failed: 0
   Wave: 2
   Cost: $2.45 / $10 limit

 Workers:
   Max concurrent: 3
   Total spawned: 8
   Active: w-abc (25s ago)
   Active: w-def (18s ago)

 Safety:
   Consecutive failures: 0/5 (circuit breaker)
   Abort signal: none

 Completion:
   Promise: <promise>COMPLETE</promise>

 Recent Errors: 2 captured
   See: .claude/memory/errors.md

═══════════════════════════════════════════════════════════════
```
