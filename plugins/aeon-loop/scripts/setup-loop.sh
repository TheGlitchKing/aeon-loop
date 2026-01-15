#!/bin/bash
# Aeon Loop - Setup Script
# Initializes loop state and planning files for autonomous execution

set -euo pipefail

# Parse arguments
PROMPT_PARTS=()
MAX_ITERATIONS=100
COMPLETION_PROMISE=""
WORKERS=3
CHUNK_SIZE=5
COST_LIMIT=10

# Help text
show_help() {
  cat << 'EOF'
Aeon Loop - Autonomous Task Execution

USAGE:
  /loop [PROMPT...] [OPTIONS]

ARGUMENTS:
  PROMPT...    Task description (can be multiple words)

OPTIONS:
  --done <text>           Completion promise phrase (REQUIRED for finite loops)
  --max-iters <n>         Maximum iterations (default: 100)
  --workers <n>           Max concurrent workers (default: 3, max: 3)
  --chunk-size <n>        Tasks per chunk (default: 5)
  --cost-limit <n>        Max USD to spend (default: 10)
  -h, --help              Show this help message

EXAMPLES:
  /loop Build a REST API with auth --done "COMPLETE"
  /loop Fix all test failures --done "ALL TESTS PASS" --max-iters 20
  /loop Refactor the auth module --done "DONE" --workers 2

STOPPING:
  - Output <promise>YOUR_PHRASE</promise> when task is complete
  - Or reach --max-iters limit
  - Or run /abort to stop immediately

MONITORING:
  /status              Check progress
  /pause               Pause after current iteration
  /resume              Continue paused loop
EOF
  exit 0
}

# Parse options
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      show_help
      ;;
    --done|--completion-promise)
      if [[ -z "${2:-}" ]]; then
        echo "Error: --done requires a text argument" >&2
        exit 1
      fi
      COMPLETION_PROMISE="$2"
      shift 2
      ;;
    --max-iters|--max-iterations)
      if [[ -z "${2:-}" ]] || ! [[ "$2" =~ ^[0-9]+$ ]]; then
        echo "Error: --max-iters requires a positive integer" >&2
        exit 1
      fi
      MAX_ITERATIONS="$2"
      shift 2
      ;;
    --workers)
      if [[ -z "${2:-}" ]] || ! [[ "$2" =~ ^[0-9]+$ ]]; then
        echo "Error: --workers requires a positive integer" >&2
        exit 1
      fi
      # Cap at 3
      if [[ "$2" -gt 3 ]]; then
        echo "Warning: Max workers capped at 3 for safety" >&2
        WORKERS=3
      else
        WORKERS="$2"
      fi
      shift 2
      ;;
    --chunk-size)
      if [[ -z "${2:-}" ]] || ! [[ "$2" =~ ^[0-9]+$ ]]; then
        echo "Error: --chunk-size requires a positive integer" >&2
        exit 1
      fi
      CHUNK_SIZE="$2"
      shift 2
      ;;
    --cost-limit)
      if [[ -z "${2:-}" ]] || ! [[ "$2" =~ ^[0-9]+$ ]]; then
        echo "Error: --cost-limit requires a positive integer" >&2
        exit 1
      fi
      COST_LIMIT="$2"
      shift 2
      ;;
    *)
      PROMPT_PARTS+=("$1")
      shift
      ;;
  esac
done

# Join prompt
PROMPT="${PROMPT_PARTS[*]}"

# Validate prompt
if [[ -z "$PROMPT" ]]; then
  echo "Error: No task description provided" >&2
  echo "" >&2
  echo "Usage: /loop \"Your task description\" --done \"COMPLETE\"" >&2
  exit 1
fi

# Generate task slug from prompt
task_name_to_slug() {
  local name="$1"
  name=$(echo "$name" | tr '[:upper:]' '[:lower:]')
  name=$(echo "$name" | sed 's/[[:space:]_]\+/-/g')
  name=$(echo "$name" | sed 's/[^a-z0-9-]//g')
  name=$(echo "$name" | sed 's/^-\+\|-\+$//g')
  name=$(echo "$name" | sed 's/-\+/-/g')
  # Truncate to 50 chars
  echo "${name:0:50}"
}

TASK_SLUG=$(task_name_to_slug "$PROMPT")

# Create directories
mkdir -p .claude/memory
mkdir -p .claude/orchestration/chunks
mkdir -p .claude/orchestration/heartbeats
mkdir -p ".planning/$TASK_SLUG"

# Create loop state
cat > .claude/loop-state.md << EOF
---
active: true
iteration: 1
max_iterations: $MAX_ITERATIONS
completion_promise: "$COMPLETION_PROMISE"
task_slug: "$TASK_SLUG"
workers: $WORKERS
chunk_size: $CHUNK_SIZE
cost_limit: $COST_LIMIT
consecutive_failures: 0
total_workers_spawned: 0
started_at: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
---

$PROMPT
EOF

# Create task plan if doesn't exist
if [[ ! -f ".planning/$TASK_SLUG/task_plan.md" ]]; then
  cat > ".planning/$TASK_SLUG/task_plan.md" << EOF
# Task Plan: $PROMPT

## Goal
$PROMPT

## Phases
- [ ] Phase 1: Analyze requirements and plan approach
- [ ] Phase 2: Implement core functionality
- [ ] Phase 3: Test and validate
- [ ] Phase 4: Review and complete

<!-- STATE
phases:
  - id: 1
    name: "Analyze requirements"
    passes: false
  - id: 2
    name: "Implement core functionality"
    passes: false
  - id: 3
    name: "Test and validate"
    passes: false
  - id: 4
    name: "Review and complete"
    passes: false
stories: []
/STATE -->

## Key Questions
1. What are the main components needed?
2. What dependencies exist?
3. How will success be verified?

## Decisions Made
- (to be filled during execution)

## Errors Encountered
- (auto-captured by hooks)

## Status
**Currently in Phase 1** - Starting analysis
EOF
fi

# Create notes.md if doesn't exist
if [[ ! -f ".planning/$TASK_SLUG/notes.md" ]]; then
  cat > ".planning/$TASK_SLUG/notes.md" << EOF
# Notes: $PROMPT

## Key Findings
- (to be filled during research)

## Research Sources
- (to be added)

## Synthesized Findings
- (to be added)
EOF
fi

# Initialize memory files
cat > .claude/memory/checkpoint.md << EOF
---
checkpoint_time: $(date -u +%Y-%m-%dT%H:%M:%SZ)
iteration: 1
task_slug: "$TASK_SLUG"
---

## Initial State
Loop started for task: $PROMPT
EOF

cat > .claude/memory/attention.md << EOF
<!-- ATTENTION -->
Task: $PROMPT
Plan: .planning/$TASK_SLUG/task_plan.md
Completion: Output <promise>$COMPLETION_PROMISE</promise> when done
Max iterations: $MAX_ITERATIONS
<!-- /ATTENTION -->
EOF

# Initialize patterns.md if doesn't exist
if [[ ! -f ".claude/memory/patterns.md" ]]; then
  cat > .claude/memory/patterns.md << EOF
# Learned Patterns

## This Project
- (patterns will be captured from errors)

## General
- Read context files before starting work
- Update task_plan.md after each phase
- Check for existing work before creating new files
EOF
fi

# Initialize errors.md
cat > .claude/memory/errors.md << EOF
# Error Log

Errors are auto-captured by the post-bash hook.

EOF

# Initialize orchestration manifest
cat > .claude/orchestration/manifest.md << EOF
---
total_chunks: 0
completed_chunks: 0
failed_chunks: 0
current_phase: 1
current_wave: 0
consecutive_failures: 0
total_workers_spawned: 0
estimated_cost_usd: 0.00
cost_limit_usd: $COST_LIMIT
max_workers: $WORKERS
chunk_size: $CHUNK_SIZE
---

## Dependency Graph
(To be built when tasks are parsed)

## Chunk Status
| Chunk | Wave | Tasks | Deps | Status | Worker | Duration |
|-------|------|-------|------|--------|--------|----------|
| (none yet) | | | | | | |

## Event Log
| Time | Event | Details |
|------|-------|---------|
| $(date -u +%H:%M:%S) | loop_start | task=$TASK_SLUG |
EOF

# Output confirmation
cat << EOF

Aeon Loop activated!

Task: $PROMPT
Slug: $TASK_SLUG
Iteration: 1
Max iterations: $MAX_ITERATIONS
Completion promise: ${COMPLETION_PROMISE:-"(none - runs until max)"}
Max workers: $WORKERS
Cost limit: \$$COST_LIMIT

Files created:
  .claude/loop-state.md
  .claude/memory/checkpoint.md
  .claude/memory/attention.md
  .planning/$TASK_SLUG/task_plan.md
  .planning/$TASK_SLUG/notes.md

To monitor: /status
To stop: /abort

Starting task...

$PROMPT

EOF

# Add completion instructions if promise set
if [[ -n "$COMPLETION_PROMISE" ]]; then
  cat << EOF
When complete, output:
  <promise>$COMPLETION_PROMISE</promise>

Only output when the statement is TRUE. Do not lie to exit the loop.

EOF
fi
