# Subagent Orchestration Design

## The Problem

Given a plan with 50 tasks:
```markdown
## Phases
- [ ] Phase 1: Setup (5 tasks)
- [ ] Phase 2: Core API (15 tasks)
- [ ] Phase 3: Auth (10 tasks)
- [ ] Phase 4: Tests (12 tasks)
- [ ] Phase 5: Deploy (8 tasks)
```

How do we:
1. Automatically break phases into executable chunks?
2. Spawn subagents to handle each chunk?
3. Maintain continuity between subagents?
4. Handle failures and retries?
5. Aggregate progress back to the main plan?

---

## Solution: Orchestrator-Worker Pattern with DAG Execution

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           MAIN LOOP (Orchestrator)                       │
│                                                                          │
│  Responsibilities:                                                       │
│  - Parse task_plan.md into executable chunks                            │
│  - Build dependency DAG for execution waves                             │
│  - Spawn worker subagents (max 3 concurrent)                            │
│  - Monitor progress via filesystem polling + heartbeats                 │
│  - Aggregate results back to task_plan.md                               │
│  - Handle failures with circuit breaker pattern                         │
│  - Decide when phase is complete → move to next phase                   │
└─────────────────────────────────────────────────────────────────────────┘
         │
         │ Spawns workers in dependency waves
         │
         ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           WORKER SUBAGENTS                               │
│                                                                          │
│  Wave 1 (no deps):                                                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                   │
│  │   Worker 1   │  │   Worker 2   │  │   Worker 3   │   (max parallel)  │
│  │  chunk: 001  │  │  chunk: 002  │  │  chunk: 003  │                   │
│  └──────────────┘  └──────────────┘  └──────────────┘                   │
│         │                 │                 │                            │
│         ▼                 ▼                 ▼                            │
│  Wave 2 (deps on wave 1):                                               │
│  ┌──────────────┐  ┌──────────────┐                                     │
│  │   Worker 4   │  │   Worker 5   │   (spawned after wave 1 completes)  │
│  │  chunk: 004  │  │  chunk: 005  │                                     │
│  └──────────────┘  └──────────────┘                                     │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────────────────┐
│              SHARED FILESYSTEM (Continuity Layer)                        │
│                                                                          │
│  .claude/orchestration/                                                 │
│  ├── manifest.md         (task breakdown, DAG, progress)                │
│  ├── chunks/             (individual chunk state files)                 │
│  └── heartbeats/         (worker liveness signals)                      │
│                                                                          │
│  .claude/memory/                                                        │
│  ├── checkpoint.md       (aggregated progress)                          │
│  ├── attention.md        (shared critical context)                      │
│  └── patterns.md         (shared learned patterns)                      │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Safety Limits (HARD CONSTRAINTS)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           SAFETY CONSTANTS                               │
├─────────────────────────────────────────────────────────────────────────┤
│  MAX_CONCURRENT_WORKERS     = 3        # Never exceed                   │
│  MAX_TOTAL_WORKERS_PER_LOOP = 50       # Prevent runaway spawning       │
│  MAX_RETRIES_PER_CHUNK      = 3        # Then escalate                  │
│  MAX_CONSECUTIVE_FAILURES   = 5        # Circuit breaker trips          │
│  WORKER_TIMEOUT             = 10 min   # Kill stalled workers           │
│  HEARTBEAT_INTERVAL         = 30 sec   # Worker writes heartbeat        │
│  HEARTBEAT_STALE_THRESHOLD  = 90 sec   # Orchestrator considers dead    │
│  POLL_INTERVAL              = 10 sec   # Orchestrator checks progress   │
└─────────────────────────────────────────────────────────────────────────┘
```

**Why 3 concurrent workers:**
1. Claude Code API rate limits - more parallel calls = throttling
2. Context coherence - keeps filesystem churn manageable
3. Debugging sanity - can mentally track 3 workers
4. Resource safety - predictable token cost (3 × chunk)

---

## Dependency-Aware DAG Execution

### Task Dependency Detection

Parse task descriptions for dependency keywords:

```
Keywords that indicate dependency:
  - "uses", "requires", "needs", "depends on"
  - "after", "following", "once X is done"
  - "imports from", "extends", "inherits"
  - "reads from", "writes to" (same resource)
```

### Example DAG

```
Phase 2 Tasks:
  Task 6: Create user model        (no deps)
  Task 7: Create product model     (no deps)
  Task 8: Create order model       (depends on 6, 7)
  Task 9: User CRUD                (depends on 6)
  Task 10: Product CRUD            (depends on 7)
  Task 11: Order CRUD              (depends on 8)

DAG:
       ┌─────┐     ┌─────┐
       │  6  │     │  7  │     Wave 1 (parallel)
       └──┬──┘     └──┬──┘
          │           │
     ┌────┴────┬──────┴────┐
     ▼         ▼           ▼
  ┌─────┐   ┌─────┐   ┌─────┐
  │  9  │   │  8  │   │ 10  │  Wave 2 (parallel after wave 1)
  └─────┘   └──┬──┘   └─────┘
               │
               ▼
            ┌─────┐
            │ 11  │            Wave 3 (after wave 2)
            └─────┘

Execution:
  Wave 1: [6, 7] parallel     ← no deps, run together
  Wave 2: [8, 9, 10] parallel ← deps satisfied
  Wave 3: [11]                ← depends on wave 2
```

### Chunk Frontmatter with Dependencies

```yaml
---
chunk_id: "004"
tasks: [8, 9, 10]
depends_on: ["chunk-001", "chunk-002"]  # Must complete first
status: "pending"
wave: 2
---
```

---

## Worker Communication: Filesystem Polling + Heartbeat

### Why Filesystem Polling?

| Approach | Pros | Cons |
|----------|------|------|
| Callbacks | Real-time | Complex, failure modes |
| Message Queue | Scalable | Overkill, external dep |
| **Filesystem** | Simple, debuggable, crash-resistant | Slight latency |

### Heartbeat Protocol

**Worker writes heartbeat:**
```bash
# Worker heartbeat loop (runs in background)
while working; do
  echo $(date -u +%Y-%m-%dT%H:%M:%SZ) > .claude/orchestration/heartbeats/worker-{id}.txt
  sleep 30
done
```

**Orchestrator detects stale worker:**
```bash
# Check heartbeat freshness
heartbeat_time=$(cat .claude/orchestration/heartbeats/worker-{id}.txt)
age=$(time_diff_seconds "$heartbeat_time" "$(date -u)")

if [ $age -gt 90 ]; then
  # Worker is stalled
  mark_chunk_status "stalled"
  kill_worker $worker_id
  respawn_worker $chunk_id
fi
```

### Atomic Status Updates

```bash
# Worker updates chunk status atomically
update_chunk_status() {
  local chunk_file="$1"
  local new_status="$2"

  # Write to temp file first
  sed "s/^status: .*/status: \"$new_status\"/" "$chunk_file" > "${chunk_file}.tmp"

  # Atomic move
  mv "${chunk_file}.tmp" "$chunk_file"
}
```

---

## Tiered Context Loading

### Context Tiers

```
┌─────────────────────────────────────────────────────────────────────────┐
│ TIER 1: Always Loaded (~2KB)                                            │
│ ─────────────────────────────                                           │
│ - attention.md (critical context)                                       │
│ - Their specific chunk file                                             │
│ - Current phase summary (not all phases)                                │
│                                                                          │
│ Injected directly into worker prompt                                    │
├─────────────────────────────────────────────────────────────────────────┤
│ TIER 2: Loaded on Demand (referenced by path)                           │
│ ──────────────────────────────────────────────                          │
│ - patterns.md (only if they hit an error)                               │
│ - Previous chunk outputs (only chunks they depend on)                   │
│ - notes.md sections (only relevant headers)                             │
│                                                                          │
│ Worker READs these files when needed                                    │
├─────────────────────────────────────────────────────────────────────────┤
│ TIER 3: Never Loaded (too large)                                        │
│ ────────────────────────────────                                        │
│ - Full task_plan.md (just Goal + current phase extracted)               │
│ - All historical chunk outputs                                          │
│ - Full errors.md                                                        │
│                                                                          │
│ Orchestrator summarizes if needed                                       │
└─────────────────────────────────────────────────────────────────────────┘
```

### Worker Prompt Template

```markdown
# Worker {worker_id} - Chunk {chunk_id}

## Immediate Context (Tier 1)
<!-- ATTENTION -->
{attention.md contents}
<!-- /ATTENTION -->

## Your Assignment
{chunk file contents - tasks, status, deps}

## Dependent Chunk Outputs
{outputs from chunks listed in depends_on}

## Available on Request (Tier 2)
If you need more context, READ these files:
- Error patterns: `.claude/memory/patterns.md`
- Research notes: `.planning/{slug}/notes.md`
- Other chunk outputs: `.claude/orchestration/chunks/chunk-XXX.md`

Do NOT read unless specifically needed. Save tokens.

## Execution Rules
1. Work through tasks sequentially
2. After each task: update chunk file with [x] and output
3. Check for existing work before starting (idempotency)
4. If error: log to chunk file, read patterns.md, attempt fix
5. If stuck after 3 attempts: set status to "failed", document blocker
6. When all tasks done: set status to "complete"

## Heartbeat
Write timestamp to `.claude/orchestration/heartbeats/{worker_id}.txt` every 30s

## Abort Compliance
Check `/tmp/aeon-loop-abort-{hash}` before each task. Stop gracefully if exists.
```

---

## Circuit Breaker Pattern

### Failure Tracking

```bash
# In orchestrator
consecutive_failures=0

on_chunk_complete() {
  consecutive_failures=0  # Reset on success
}

on_chunk_failure() {
  consecutive_failures=$((consecutive_failures + 1))

  if [ $consecutive_failures -ge 5 ]; then
    trip_circuit_breaker
  fi
}

trip_circuit_breaker() {
  # 1. Pause the loop
  echo "paused" > .claude/loop-state.md.status

  # 2. Write attention marker
  cat >> .claude/memory/attention.md << 'EOF'
<!-- ATTENTION -->
⚠️ CIRCUIT BREAKER TRIPPED
5 consecutive chunk failures detected
Last error: {error_message}
Failed chunks: {list}
Human intervention required

To resume: /loop resume
To abort: /abort
<!-- /ATTENTION -->
EOF

  # 3. Don't re-inject prompt (exit loop)
  exit 0
}
```

### Runaway Prevention

```bash
total_workers_spawned=0
MAX_TOTAL=50

spawn_worker() {
  total_workers_spawned=$((total_workers_spawned + 1))

  if [ $total_workers_spawned -gt $MAX_TOTAL ]; then
    echo "SAFETY LIMIT: Spawned 50 workers without completion" >&2

    # Force abort
    touch /tmp/aeon-loop-abort-{hash}

    cat >> .claude/memory/attention.md << 'EOF'
<!-- ATTENTION -->
🛑 SAFETY LIMIT REACHED
Spawned 50 workers without task completion
This indicates infinite loop or impossible task
Loop aborted automatically

Review: .claude/orchestration/manifest.md
<!-- /ATTENTION -->
EOF

    exit 1
  fi

  # Proceed with spawn...
}
```

---

## File Structure for Orchestration

```
.claude/
├── loop-state.md                  # Main loop state
│
├── orchestration/
│   │
│   ├── manifest.md                # Master task breakdown + DAG
│   │   ---
│   │   total_chunks: 12
│   │   completed_chunks: 5
│   │   failed_chunks: 1
│   │   current_phase: 2
│   │   current_wave: 2
│   │   consecutive_failures: 0
│   │   total_workers_spawned: 8
│   │   estimated_cost_usd: 2.45
│   │   ---
│   │
│   │   ## Dependency Graph
│   │   ```
│   │   001 ──┬──► 004
│   │   002 ──┤
│   │   003 ──┴──► 005 ──► 007
│   │   ```
│   │
│   │   ## Chunk Status
│   │   | Chunk | Wave | Tasks | Deps | Status | Worker | Duration |
│   │   |-------|------|-------|------|--------|--------|----------|
│   │   | 001   | 1    | 1-3   | -    | done   | w-abc  | 12m      |
│   │   | 002   | 1    | 4-6   | -    | done   | w-def  | 18m      |
│   │   | 003   | 1    | 7-9   | -    | done   | w-ghi  | 15m      |
│   │   | 004   | 2    | 10-12 | 001,002 | active | w-jkl | -     |
│   │   | 005   | 2    | 13-15 | 003  | active | w-mno  | -        |
│   │   | ...   |      |       |      |        |        |          |
│   │
│   ├── chunks/
│   │   ├── chunk-001.md
│   │   │   ---
│   │   │   chunk_id: "001"
│   │   │   tasks: [1, 2, 3]
│   │   │   depends_on: []
│   │   │   wave: 1
│   │   │   status: "complete"
│   │   │   worker_id: "w-abc"
│   │   │   started_at: "2026-01-14T15:00:00Z"
│   │   │   completed_at: "2026-01-14T15:12:00Z"
│   │   │   retries: 0
│   │   │   checksum: "a1b2c3d4"
│   │   │   ---
│   │   │
│   │   │   ## Tasks
│   │   │   - [x] Task 1: Create user model
│   │   │   - [x] Task 2: Add validation
│   │   │   - [x] Task 3: Write migration
│   │   │
│   │   │   ## Output
│   │   │   Created:
│   │   │   - src/models/user.ts
│   │   │   - src/migrations/001_users.sql
│   │   │
│   │   │   ## Artifacts
│   │   │   Files modified: 2
│   │   │   Tests added: 0
│   │   │   Lines changed: +145
│   │   │
│   │   ├── chunk-002.md
│   │   ├── chunk-003.md
│   │   └── ...
│   │
│   └── heartbeats/
│       ├── w-abc.txt              # "2026-01-14T15:11:30Z"
│       ├── w-def.txt
│       └── ...
│
└── memory/
    ├── checkpoint.md              # Aggregated from all chunks
    ├── attention.md               # Shared context for all workers
    ├── patterns.md                # Shared learnings
    └── errors.md                  # Error log
```

---

## Orchestration Flow

### Phase 1: Task Decomposition

```
/loop "Build E-Commerce API" --done "COMPLETE"
         │
         ▼
┌─────────────────────────────────────────────────────────────────┐
│ 1. Read .planning/[task]/task_plan.md                           │
│ 2. Parse phases and extract individual tasks                    │
│ 3. Analyze task descriptions for dependencies                   │
│ 4. Build DAG and assign waves                                   │
│ 5. Chunk tasks (3-5 per chunk, respecting deps)                │
│ 6. Create .claude/orchestration/manifest.md                     │
│ 7. Create .claude/orchestration/chunks/chunk-XXX.md for each   │
└─────────────────────────────────────────────────────────────────┘
```

### Phase 2: Wave Execution

```
┌─────────────────────────────────────────────────────────────────┐
│ For each wave:                                                  │
│                                                                 │
│ 1. Get all chunks in current wave                              │
│ 2. Filter to pending chunks with satisfied deps                │
│ 3. While pending chunks exist:                                 │
│    a. Count active workers                                     │
│    b. If active < 3 AND pending chunks exist:                  │
│       - Spawn worker for next pending chunk                    │
│       - Mark chunk as "active"                                 │
│    c. Poll chunk files every 10s                               │
│    d. Check heartbeats, kill stale workers                     │
│    e. On chunk complete:                                       │
│       - Reset consecutive_failures                             │
│       - Update manifest                                        │
│       - Check if wave complete                                 │
│    f. On chunk fail:                                           │
│       - Increment retries                                      │
│       - If retries < 3: respawn worker                         │
│       - If retries >= 3: mark failed, increment consecutive    │
│       - If consecutive >= 5: trip circuit breaker              │
│ 4. Wave complete → move to next wave                           │
└─────────────────────────────────────────────────────────────────┘
```

### Phase 3: Progress Aggregation

```
Every orchestrator iteration:
  │
  ├─► Scan .claude/orchestration/chunks/*.md
  │
  ├─► Update manifest.md:
  │     - completed_chunks count
  │     - current_wave
  │     - total_workers_spawned
  │     - estimated_cost_usd
  │
  ├─► Update .claude/memory/checkpoint.md:
  │     - Completed tasks summary
  │     - Current phase/wave
  │     - Files created/modified
  │
  ├─► Update .planning/[task]/task_plan.md:
  │     - Mark completed phases [x]
  │     - Update Status section
  │
  └─► Check completion:
        - All chunks complete? → output <promise>DONE</promise>
        - All phases complete? → output <promise>DONE</promise>
```

---

## Additional Safety Measures

### 1. Cost Tracking

```yaml
# In manifest.md frontmatter
estimated_cost_usd: 2.45
cost_per_chunk_avg: 0.20
cost_limit_usd: 10.00  # Hard stop

# In orchestrator
if estimated_cost > cost_limit:
  pause_loop "Cost limit reached: $${estimated_cost}"
```

### 2. Idempotency

```markdown
# Worker instruction
Before starting each task, check if already done:
1. Read chunk file - is task marked [x]?
2. Check if output files exist
3. If already done, skip and move to next

This prevents duplicate work on retry.
```

### 3. Checksum Verification

```yaml
# In chunk frontmatter
checksum: "a1b2c3d4"  # MD5 of file content

# Orchestrator verifies
expected=$(cat chunk-001.md | md5sum | cut -c1-8)
if [ "$checksum" != "$expected" ]; then
  log "WARNING: Chunk file corrupted, re-reading"
fi
```

### 4. Graceful Degradation

```bash
# If orchestration fails, fall back to single-agent mode
if [ ! -f ".claude/orchestration/manifest.md" ]; then
  echo "Orchestration unavailable, running in single-agent mode"
  # Run as regular loop without chunking
fi
```

### 5. Observability

```markdown
# Every state change logged in manifest.md

## Event Log
| Time | Event | Details |
|------|-------|---------|
| 15:00:00 | loop_start | chunks=12, waves=4 |
| 15:00:05 | worker_spawn | chunk=001, worker=w-abc |
| 15:00:06 | worker_spawn | chunk=002, worker=w-def |
| 15:00:07 | worker_spawn | chunk=003, worker=w-ghi |
| 15:12:00 | chunk_complete | chunk=001, duration=12m |
| 15:15:00 | chunk_complete | chunk=003, duration=15m |
| 15:18:00 | chunk_complete | chunk=002, duration=18m |
| 15:18:01 | wave_complete | wave=1, duration=18m |
| 15:18:05 | worker_spawn | chunk=004, worker=w-jkl |
| ... |
```

---

## Commands

### /loop (enhanced)

```bash
/loop "Build API" --done "COMPLETE" [options]

Options:
  --workers N       Max concurrent workers (default: 3, max: 3)
  --chunk-size N    Tasks per chunk (default: 5, max: 10)
  --retry-limit N   Max retries per chunk (default: 3)
  --cost-limit N    Max USD to spend (default: 10)
  --no-parallel     Disable parallel execution (sequential only)
```

### /status (enhanced)

```
/status

═══════════════════════════════════════════════════════════════
 AEON LOOP STATUS
═══════════════════════════════════════════════════════════════

 Task: Build E-Commerce API
 Status: Running
 Phase: 2 of 5 (Core API)
 Wave: 2 of 3

 Progress: ████████░░░░░░░░ 8/12 chunks (66%)

 Workers Active: 2/3
   ├─ w-jkl: Chunk 004 (tasks 10-12) [5m elapsed]
   └─ w-mno: Chunk 005 (tasks 13-15) [3m elapsed]

 Completed: 6 chunks
 Failed: 0 chunks
 Pending: 4 chunks

 Cost: $2.45 / $10.00 limit
 Duration: 18m elapsed

 Recent Events:
   15:18:01 Wave 1 complete (3 chunks, 18m)
   15:18:05 Spawned worker w-jkl for chunk 004
   15:18:08 Spawned worker w-mno for chunk 005

═══════════════════════════════════════════════════════════════
```

### /retry

```bash
/retry chunk-006

Retrying chunk 006...
Previous error: DB connection timeout
Spawning worker w-pqr for tasks 18-20
```

### /pause and /resume

```bash
/pause
Loop paused. Workers will complete current tasks then stop.
Run /resume to continue.

/resume
Resuming loop from wave 2, chunk 004...
```

---

## Architecture Integration

### New Files for Plugin

```
aeon-loop/
├── agents/
│   ├── orchestrator.md          # Main loop orchestration logic
│   ├── worker.md                # Generic worker agent template
│   └── fixer.md                 # Error recovery specialist
│
├── scripts/
│   ├── parse-plan.sh            # Extract tasks from task_plan.md
│   ├── build-dag.sh             # Analyze deps, create DAG
│   ├── create-chunks.sh         # Generate chunk files
│   ├── spawn-worker.sh          # Launch worker subagent
│   ├── poll-workers.sh          # Check heartbeats and status
│   ├── aggregate-progress.sh    # Update manifest and checkpoint
│   ├── check-circuit-breaker.sh # Failure monitoring
│   └── cost-tracker.sh          # Token/cost estimation
│
├── templates/
│   ├── manifest.md              # Orchestration manifest template
│   ├── chunk.md                 # Individual chunk template
│   └── worker-prompt.md         # Worker injection template
```

### Hook Changes

**Stop Hook (enhanced):**
```bash
#!/bin/bash

# 1. Aggregate worker progress
bash scripts/aggregate-progress.sh

# 2. Check circuit breaker
if bash scripts/check-circuit-breaker.sh; then
  # Circuit breaker tripped, don't continue
  exit 0
fi

# 3. Check completion
if all_chunks_complete; then
  # Allow exit
  exit 0
fi

# 4. Check cost limit
if bash scripts/cost-tracker.sh --check-limit; then
  echo '{"decision":"block","reason":"Cost limit reached"}'
  exit 0
fi

# 5. Continue loop
echo '{"decision":"block","reason":"<prompt>"}'
```

---

## Example: 50-Task Plan Execution

```
Plan: Build E-Commerce API
Total Tasks: 50
Phases: 5
Chunks: 12 (avg 4 tasks each)
Waves: 4

Timeline:
─────────────────────────────────────────────────────────────────
t=0     /loop "Build E-Commerce API" --done "COMPLETE"
        → Parse plan, build DAG, create 12 chunks in 4 waves
        → Wave 1: chunks 001-003 (no deps)
        → Spawn workers: w-001, w-002, w-003

t=15m   Wave 1 complete (all 3 chunks done)
        → Wave 2: chunks 004-006 (depend on wave 1)
        → Spawn workers: w-004, w-005, w-006

t=25m   Chunk 004 complete
        Chunk 005 complete
        Chunk 006 FAILED (DB connection error)
        → consecutive_failures = 1
        → Retry chunk 006 (attempt 2/3)

t=30m   Chunk 006 retry FAILED
        → consecutive_failures = 2
        → Retry chunk 006 (attempt 3/3)

t=35m   Chunk 006 retry SUCCESS
        → consecutive_failures = 0 (reset)
        → Wave 2 complete

t=35m   Wave 3: chunks 007-009
        → Spawn workers (max 3 concurrent)

t=55m   Wave 3 complete
        Wave 4: chunks 010-012 (final)

t=75m   All chunks complete
        All phases complete
        → Output: <promise>COMPLETE</promise>
        → Loop exits

Total: 75 minutes, 15 worker spawns, $3.80 cost
─────────────────────────────────────────────────────────────────
```

---

## Open Questions (Resolved)

| Question | Decision | Rationale |
|----------|----------|-----------|
| Parallel vs Sequential? | **DAG-based waves** | Max parallelism with dependency safety |
| Worker Communication? | **File polling + heartbeat** | Simple, crash-resistant, debuggable |
| Context Size? | **Tiered lazy loading** | Small prompts, full access on demand |
| Subagent Limit? | **3 concurrent, 50 total** | API safety, cost control, debuggability |
