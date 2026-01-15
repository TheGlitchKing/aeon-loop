---
name: retry
description: Retry a failed chunk manually.
argument-hint: "CHUNK_ID"
---

# Retry Command

Manually retry a failed chunk that exceeded automatic retry limit.

## Usage

```
/retry chunk-006
/retry 006
```

## Execution

```bash
#!/bin/bash

CHUNK_ID="${1:-}"

# Normalize chunk ID
if [[ -z "$CHUNK_ID" ]]; then
  echo "Usage: /retry CHUNK_ID"
  echo ""
  echo "Example: /retry chunk-006"
  echo "         /retry 006"
  echo ""

  # List failed chunks
  if [[ -d ".claude/orchestration/chunks" ]]; then
    echo "Failed chunks:"
    for chunk in .claude/orchestration/chunks/*.md; do
      if [[ -f "$chunk" ]]; then
        STATUS=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$chunk" | \
          grep "^status:" | sed 's/status: *//' | sed 's/^"\(.*\)"$/\1/')
        if [[ "$STATUS" == "failed" ]]; then
          CHUNK_NAME=$(basename "$chunk" .md)
          echo "  - $CHUNK_NAME"
        fi
      fi
    done
  fi
  exit 0
fi

# Normalize to chunk-XXX format
if [[ ! "$CHUNK_ID" =~ ^chunk- ]]; then
  CHUNK_ID="chunk-$CHUNK_ID"
fi

CHUNK_FILE=".claude/orchestration/chunks/${CHUNK_ID}.md"

if [[ ! -f "$CHUNK_FILE" ]]; then
  echo "Chunk not found: $CHUNK_FILE"
  exit 1
fi

# Check status
STATUS=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$CHUNK_FILE" | \
  grep "^status:" | sed 's/status: *//' | sed 's/^"\(.*\)"$/\1/')

if [[ "$STATUS" != "failed" ]]; then
  echo "Chunk $CHUNK_ID is not failed (status: $STATUS)"
  exit 0
fi

# Reset chunk for retry
sed -i 's/^status: "failed"/status: "pending"/' "$CHUNK_FILE"
sed -i 's/^retries: .*/retries: 0/' "$CHUNK_FILE"

# Reset consecutive failures in loop state
if [[ -f ".claude/loop-state.md" ]]; then
  sed -i 's/^consecutive_failures: .*/consecutive_failures: 0/' ".claude/loop-state.md"
fi

echo "Chunk $CHUNK_ID reset for retry"
echo ""
echo "Status: pending (was: failed)"
echo "Retries: 0"
echo ""
echo "Chunk will be picked up in next orchestration cycle."

# Show chunk tasks
echo ""
echo "Tasks in this chunk:"
awk '/^## Tasks/,/^## [^T]/' "$CHUNK_FILE" | grep -E "^\s*-" || echo "(no tasks found)"
```

## When to Use

- A chunk failed after 3 automatic retries
- You've fixed the underlying issue (missing dependency, env var, etc.)
- You want to retry without restarting the entire loop

## Note

- Resets retry counter to 0
- Sets chunk status to "pending"
- Orchestrator will spawn a new worker for this chunk
- Does not affect other chunks or workers
