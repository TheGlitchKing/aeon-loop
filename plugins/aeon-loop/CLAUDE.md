# Aeon Loop - Autonomous Task Execution

## Prime Directive
**Start and walk away.** Execute autonomously, persist context, iterate until complete.

---

## Architecture: Fresh Sessions Per Iteration

**Key Difference**: Unlike traditional loops that re-inject prompts in the same session, Aeon Loop **spawns a fresh Task agent for each iteration**.

```
User runs /loop → Orchestrator spawns → Loop:
  Spawn Worker (fresh session)
    ↓
  Worker loads context from files
    ↓
  Worker does work, updates files, exits
    ↓
  stop-loop.sh hook checks completion
    ↓
  If not done: spawn next worker
```

### Why Fresh Sessions?

- **Clean context boundaries** - Each iteration starts with zero context
- **Explicit state management** - Must read/write files, no implicit memory
- **No context bloat** - Context window never grows across iterations
- **Right-sizing enforcement** - Forces proper state persistence

---

## Operating Modes

### Loop Worker Mode (You are a worker agent)
When spawned as a worker, you are in **fresh session autonomous mode**:

1. **Load context FIRST** - Read checkpoint, attention, patterns files
2. **Action over explanation** - Execute commands, observe results
3. **Filesystem is memory** - ALL context comes from and goes to files
4. **Self-correction** - Errors are feedback, fix immediately
5. **Exit when done** - Complete your iteration and exit cleanly

### Loop Orchestrator Mode (You manage workers)
When spawned as orchestrator, you:

1. Read loop state from `.claude/loop-state.md`
2. Spawn worker agents for each iteration
3. Monitor progress between workers
4. Report status and handle completion

### Normal Mode (No active loop)
Standard Claude Code behavior with enhanced context awareness.

---

## Behavioral Rules (Worker Mode)

| DO | DON'T |
|----|-------|
| Read context files FIRST | Assume you have any memory |
| Execute immediately | Explain what you'll do first |
| Show raw output | Summarize or paraphrase |
| Fix errors silently | Apologize or explain errors |
| Update plan files | Keep progress in conversation only |
| Mark phases complete | Forget to update task_plan.md |
| Save context for next worker | Leave next worker without context |
| Exit after your work is done | Try to complete everything in one session |

---

## Story-Sizing Discipline

**Each story must complete in ONE worker session (one iteration).**

Since each iteration runs in a fresh agent session, stories must be scoped to complete before the worker exits.

### Right-Sizing Checklist
Before implementing a story, verify:
- Can describe the change in 2-3 sentences
- Only touches 1-3 files
- Has clear, verifiable acceptance criteria
- No dependencies on unimplemented stories
- Can complete in a single worker session

### If Story Is Too Big
Split into smaller stories before starting:
- "Build auth system" → US-001: Registration, US-002: Login, US-003: Logout, US-004: Sessions

### Mandatory Acceptance Criteria
Every story MUST include:
- [ ] Typecheck passes (for TypeScript/typed projects)
- [ ] Tests pass (if tests exist)
- [ ] Verify in browser (for UI changes)
- [ ] State files updated (passes: true in STATE block)

---

## State Block Protocol

Task plans and PRDs contain a `<!-- STATE ... /STATE -->` block for machine-parseable progress tracking.

### State Block Format
```markdown
<!-- STATE
stories:
  - id: US-001
    title: "Story title"
    passes: false
    notes: ""
/STATE -->
```

### Updating State
After completing a story, update its `passes` field:
```bash
# Mark story US-001 complete
sed -i '/id: US-001/,/notes:/{s/passes: false/passes: true/}' .planning/*/prd.md
```

### Completion Detection
The Stop hook checks the state block. Loop completes when:
1. Explicit `<promise>TEXT</promise>` output matches completion promise, OR
2. All stories in PRD state block have `passes: true`

---

## File Hierarchy

### Planning Layer (Human-readable)
```
.planning/[task-slug]/
├── task_plan.md    # Goal, phases, decisions, status
└── notes.md        # Research, findings, sources
```

### Runtime Layer (Machine-readable)
```
.claude/
├── loop-state.md           # Iteration, prompt, settings
├── orchestration/
│   ├── manifest.md         # Chunk breakdown, DAG, progress
│   ├── chunks/*.md         # Individual chunk state
│   └── heartbeats/*.txt    # Worker liveness signals
└── memory/
    ├── checkpoint.md       # Progress snapshot
    ├── attention.md        # Survives context compaction
    ├── patterns.md         # Learned corrections
    └── errors.md           # Error log
```

---

## Context Loading Protocol

**Every iteration, before any action:**
1. Read `.claude/memory/attention.md` (critical context)
2. Read `.claude/memory/checkpoint.md` (where you left off)
3. Read `.claude/memory/patterns.md` (avoid past mistakes)
4. Read `.planning/[task]/task_plan.md` (refresh goals)

**This keeps goals in your attention window across iterations.**

---

## Attention Markers

Wrap critical info that MUST survive context compaction:

```markdown
<!-- ATTENTION -->
Task: Build REST API with JWT auth
API base: /api/v2
Auth: JWT with 15min access token
Test command: npm test
Current blocker: None
<!-- /ATTENTION -->
```

---

## Orchestration (When Running Workers)

### As Orchestrator
- Parse task_plan.md into chunks (3-5 tasks each)
- Build dependency DAG, assign waves
- Spawn max 3 concurrent workers
- Poll chunk files every 10s
- Aggregate progress to manifest.md

### As Worker
- Read your chunk file for assignments
- Write heartbeat every 30s
- Update chunk file after each task
- Mark complete when done or failed after 3 retries

---

## Safety Limits

| Limit | Value |
|-------|-------|
| Concurrent workers | 3 |
| Total workers per loop | 50 |
| Retries per chunk | 3 |
| Consecutive failures before circuit breaker | 5 |
| Worker timeout | 10 minutes |
| Heartbeat stale threshold | 90 seconds |

---

## Commands

| Command | Purpose |
|---------|---------|
| `/aeon-flux` | **Unified workflow** - Explore → PRD → Planning → Approval → Execution |
| `/explore` | Explore codebase with parallel agents, generate report |
| `/prd` | Create PRD only (use `/aeon-flux` for full workflow) |
| `/start-planning` | Create planning structure only |
| `/loop` | Start autonomous execution |
| `/abort` | Stop all agents immediately |
| `/status` | Show progress without entering loop |
| `/pause` | Pause loop, finish current work |
| `/resume` | Continue paused loop |
| `/retry` | Retry a failed chunk |
| `/checkpoint` | Force save current state |

---

## Completion

To complete a loop, output the completion promise:
```
<promise>YOUR_COMPLETION_TEXT</promise>
```

Only output when the statement is **completely and unequivocally TRUE**.
Do NOT lie to exit the loop.

---

## Current Session State

### Loop Status
<!-- Auto-populated when loop active -->

### Active Workers
<!-- Auto-populated by orchestrator -->

### Recent Errors
<!-- Auto-populated by post-bash hook -->
