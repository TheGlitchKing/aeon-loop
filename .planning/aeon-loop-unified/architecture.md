# Aeon Loop - Unified Architecture

## Overview

Combines:
- **ralph-loop**: Autonomous iteration engine
- **aeon-flux**: Abort system + action philosophy
- **mind-glaive**: Context persistence
- **planning-with-files**: Persistent markdown planning + Manus principles

Into a single "start and walk away" plugin with full context persistence.

## Core Flow

```
┌────────────────────────────────────────────────────────────────────┐
│  User: /loop "Build API with tests" --done "COMPLETE"              │
└────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌────────────────────────────────────────────────────────────────────┐
│  setup-loop.sh                                                     │
│  - Creates .claude/loop-state.md (iteration=1, prompt, settings)   │
│  - Creates .claude/memory/progress.md (empty template)             │
│  - Outputs task to Claude                                          │
└────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌────────────────────────────────────────────────────────────────────┐
│  ITERATION CYCLE                                                   │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │ SessionStart Hook                                            │  │
│  │ - Load .claude/memory/checkpoint.md into context             │  │
│  │ - Load .claude/memory/attention.md (critical info)           │  │
│  │ - Clear stale abort signals                                  │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                              │                                     │
│                              ▼                                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │ Claude Works on Task                                         │  │
│  │ - PreToolUse checks abort signal before EVERY tool           │  │
│  │ - PostToolUse[Bash] captures errors to patterns.md           │  │
│  │ - PostToolUse[Edit] can trigger verification                 │  │
│  │ - May spawn subagents (they also check abort signal)         │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                              │                                     │
│                              ▼                                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │ PreCompact Hook (if context fills)                           │  │
│  │ - Save attention markers to .claude/memory/attention.md      │  │
│  │ - Auto-checkpoint current state                              │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                              │                                     │
│                              ▼                                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │ Stop Hook (Claude tries to exit)                             │  │
│  │ - Check for <promise>COMPLETE</promise> in output            │  │
│  │ - If found AND true → allow exit, cleanup state              │  │
│  │ - If max iterations → allow exit, cleanup state              │  │
│  │ - Otherwise:                                                 │  │
│  │   1. Save checkpoint to .claude/memory/checkpoint.md         │  │
│  │   2. Update progress.md with iteration summary               │  │
│  │   3. Increment iteration in loop-state.md                    │  │
│  │   4. Return {"decision":"block","reason":"<prompt>"}         │  │
│  │   5. Loop continues with same prompt                         │  │
│  └──────────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌────────────────────────────────────────────────────────────────────┐
│  COMPLETION                                                        │
│  - Remove .claude/loop-state.md                                    │
│  - Keep .claude/memory/* for reference                             │
│  - User returns to completed work                                  │
└────────────────────────────────────────────────────────────────────┘
```

## Abort Signal Flow

```
User: Ctrl+C / Esc / /abort
            │
            ▼
┌───────────────────────────────┐
│ Creates signal file:          │
│ /tmp/aeon-loop-abort-{hash}   │
└───────────────────────────────┘
            │
            ├──────────────────────────────────────┐
            │                                      │
            ▼                                      ▼
┌───────────────────────┐              ┌───────────────────────┐
│ Main Agent            │              │ Subagent(s)           │
│ PreToolUse hook       │              │ PreToolUse hook       │
│ checks signal file    │              │ checks SAME file      │
│ → blocks next action  │              │ → blocks next action  │
└───────────────────────┘              └───────────────────────┘

All agents stop at their next tool boundary.
Resume with: /abort clear
```

## Dual-Layer File System

Aeon Loop uses TWO layers of files:

1. **Planning Layer** (`.planning/`) - Human-facing, from planning-with-files
2. **Runtime Layer** (`.claude/`) - Machine-facing, enables autonomous looping

```
project/
│
├── .planning/                      ══════════ PLANNING LAYER ══════════
│   │                               Human-readable task definition
│   │                               Created by /loop or /start-planning
│   │                               Persists across sessions
│   │
│   └── [task-slug]/                # e.g., build-rest-api/
│       │
│       ├── task_plan.md            # THE PRIMARY PLAN (source of truth)
│       │   ┌─────────────────────────────────────────────────────┐
│       │   │ # Task Plan: Build REST API                         │
│       │   │                                                     │
│       │   │ ## Goal                                             │
│       │   │ Build REST API with JWT auth and >80% test coverage │
│       │   │                                                     │
│       │   │ ## Phases                                           │
│       │   │ - [x] Phase 1: Setup project structure              │
│       │   │ - [x] Phase 2: User model + CRUD                    │
│       │   │ - [ ] Phase 3: JWT auth (CURRENT)                   │
│       │   │ - [ ] Phase 4: Tests                                │
│       │   │                                                     │
│       │   │ ## Key Questions                                    │
│       │   │ 1. Which JWT library?                               │
│       │   │ 2. Access token expiry time?                        │
│       │   │                                                     │
│       │   │ ## Decisions Made                                   │
│       │   │ - Using Express + TypeScript                        │
│       │   │ - bcrypt for password hashing                       │
│       │   │ - jsonwebtoken library                              │
│       │   │                                                     │
│       │   │ ## Errors Encountered                               │
│       │   │ - TypeError in middleware → fixed by adding await   │
│       │   │                                                     │
│       │   │ ## Status                                           │
│       │   │ **Currently in Phase 3** - Implementing JWT         │
│       │   └─────────────────────────────────────────────────────┘
│       │
│       └── notes.md                # Research and findings
│           ┌─────────────────────────────────────────────────────┐
│           │ # Notes: Build REST API                             │
│           │                                                     │
│           │ ## Key Findings                                     │
│           │ - JWT best practice: short access, long refresh     │
│           │ - bcrypt rounds: 10-12 for production               │
│           │                                                     │
│           │ ## Research Sources                                 │
│           │ - OWASP JWT Cheat Sheet                             │
│           │ - Express security best practices                   │
│           └─────────────────────────────────────────────────────┘
│
└── .claude/                        ══════════ RUNTIME LAYER ══════════
    │                               Machine-readable loop state
    │                               Enables autonomous iteration
    │                               Hooks read/write these files
    │
    ├── loop-state.md               # Loop engine control file
    │   ┌─────────────────────────────────────────────────────────┐
    │   │ ---                                                     │
    │   │ active: true                                            │
    │   │ iteration: 5                                            │
    │   │ max_iterations: 50                                      │
    │   │ completion_promise: "COMPLETE"                          │
    │   │ task_slug: "build-rest-api"      ← Links to .planning/  │
    │   │ started_at: "2026-01-14T15:00:00Z"                      │
    │   │ ---                                                     │
    │   │                                                         │
    │   │ Build a REST API with JWT auth and >80% test coverage.  │
    │   │ Output <promise>COMPLETE</promise> when done.           │
    │   └─────────────────────────────────────────────────────────┘
    │
    │   Used by: Stop hook (check iteration, re-inject prompt)
    │
    └── memory/
        │
        ├── checkpoint.md           # Snapshot of current progress
        │   ┌─────────────────────────────────────────────────────┐
        │   │ ---                                                 │
        │   │ checkpoint_time: 2026-01-14T15:45:00Z               │
        │   │ iteration: 5                                        │
        │   │ task_slug: "build-rest-api"                         │
        │   │ ---                                                 │
        │   │                                                     │
        │   │ ## Completed This Session                           │
        │   │ - User model with validation                        │
        │   │ - CRUD endpoints for /users                         │
        │   │ - Password hashing with bcrypt                      │
        │   │                                                     │
        │   │ ## Currently Working On                             │
        │   │ - JWT middleware implementation                     │
        │   │                                                     │
        │   │ ## Next Up                                          │
        │   │ - Login/logout endpoints                            │
        │   │ - Token refresh logic                               │
        │   └─────────────────────────────────────────────────────┘
        │
        │   Used by: SessionStart (load into context each iteration)
        │            Stop hook (save before next iteration)
        │
        ├── attention.md            # Critical info for compaction survival
        │   ┌─────────────────────────────────────────────────────┐
        │   │ <!-- ATTENTION -->                                  │
        │   │ Task: Build REST API with JWT                       │
        │   │ Plan: .planning/build-rest-api/task_plan.md         │
        │   │ API base: /api/v2                                   │
        │   │ Auth: JWT with 15min access, 7d refresh             │
        │   │ DB: PostgreSQL on localhost:5432                    │
        │   │ Test command: npm test                              │
        │   │ <!-- /ATTENTION -->                                 │
        │   └─────────────────────────────────────────────────────┘
        │
        │   Used by: PreCompact (save before summarization)
        │            SessionStart (inject into context)
        │
        ├── patterns.md             # Learned corrections (persistent)
        │   ┌─────────────────────────────────────────────────────┐
        │   │ # Learned Patterns                                  │
        │   │                                                     │
        │   │ ## This Project                                     │
        │   │ - bcrypt.hash() needs await (async)                 │
        │   │ - JWT secret from process.env, never hardcode       │
        │   │ - Express middleware order matters                  │
        │   │                                                     │
        │   │ ## General                                          │
        │   │ - Always run tests after editing test files         │
        │   │ - Check package.json scripts before assuming npm    │
        │   └─────────────────────────────────────────────────────┘
        │
        │   Used by: PostBash (extract patterns from errors)
        │            SessionStart (load to avoid repeat mistakes)
        │
        └── errors.md               # Raw error log for debugging
            ┌─────────────────────────────────────────────────────┐
            │ ## Iteration 3 - 2026-01-14T15:20:00Z                │
            │ Command: npm test                                   │
            │ Exit: 1                                             │
            │ Output:                                             │
            │   TypeError: Cannot read property 'id' of undefined │
            │   at UserController.getUser (src/controllers/...)   │
            │ Resolution: Added null check for user lookup        │
            │                                                     │
            │ ## Iteration 5 - 2026-01-14T15:45:00Z                │
            │ Command: npm run build                              │
            │ Exit: 1                                             │
            │ Output:                                             │
            │   error TS2345: Argument of type 'string' is not... │
            │ Resolution: (pending)                               │
            └─────────────────────────────────────────────────────┘

            Used by: PostBash (capture failures)
                     Learner agent (analyze for patterns)
```

## Layer Responsibilities

| Layer | Location | Purpose | Lifecycle |
|-------|----------|---------|-----------|
| **Planning** | `.planning/[task]/` | Define WHAT to do | Created once, updated by human/Claude |
| **Runtime** | `.claude/` | Track HOW it's going | Created by /loop, updated each iteration |

## How Layers Connect

```
/loop "Build REST API" --done "COMPLETE"
         │
         ▼
┌─────────────────────────────────────────────────────────────────┐
│ 1. Creates .planning/build-rest-api/task_plan.md                │
│    (if not exists - uses planning-with-files template)          │
│                                                                 │
│ 2. Creates .claude/loop-state.md                                │
│    - Links to task_slug: "build-rest-api"                       │
│    - Sets iteration: 1, max_iterations, completion_promise      │
│                                                                 │
│ 3. Initializes .claude/memory/ files                            │
│    - checkpoint.md (empty template)                             │
│    - attention.md (seed with task reference)                    │
│    - patterns.md (empty or load existing)                       │
│    - errors.md (empty)                                          │
└─────────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────────┐
│ EACH ITERATION:                                                 │
│                                                                 │
│ SessionStart:                                                   │
│   1. Read .claude/memory/checkpoint.md    → restore progress    │
│   2. Read .claude/memory/attention.md     → critical context    │
│   3. Read .claude/memory/patterns.md      → avoid past mistakes │
│   4. Read .planning/[task]/task_plan.md   → refresh goals       │
│                                                                 │
│ During Work:                                                    │
│   - Update .planning/[task]/task_plan.md  → mark phases done    │
│   - Update .planning/[task]/notes.md      → store findings      │
│   - PostBash captures errors to errors.md                       │
│                                                                 │
│ Stop Hook:                                                      │
│   1. Check for completion promise in output                     │
│   2. Save checkpoint.md with current progress                   │
│   3. Extract attention markers to attention.md                  │
│   4. Increment iteration in loop-state.md                       │
│   5. Re-inject prompt → next iteration                          │
└─────────────────────────────────────────────────────────────────┘
```

## File Summary

| File | Layer | Created By | Read By | Written By |
|------|-------|------------|---------|------------|
| `task_plan.md` | Planning | /loop or /start-planning | SessionStart, Claude | Claude (phase updates) |
| `notes.md` | Planning | /loop or /start-planning | Claude | Claude (findings) |
| `loop-state.md` | Runtime | /loop | Stop hook | Stop hook (iteration++) |
| `checkpoint.md` | Runtime | /loop | SessionStart | Stop hook |
| `attention.md` | Runtime | /loop | SessionStart | PreCompact, Claude |
| `patterns.md` | Runtime | /loop | SessionStart | PostBash, Learner |
| `errors.md` | Runtime | /loop | Learner | PostBash |

## Subagent Orchestration

See **[orchestration.md](orchestration.md)** for full design.

### Summary: Orchestrator-Worker Pattern with DAG Execution

```
┌─────────────────────────────────────────────────────────────────────────┐
│ ORCHESTRATOR (Main Loop)                                                │
│ - Parses task_plan.md into chunks                                       │
│ - Builds dependency DAG, assigns waves                                  │
│ - Spawns workers (max 3 concurrent, 50 total limit)                    │
│ - Polls filesystem for progress                                         │
│ - Circuit breaker on 5 consecutive failures                            │
└─────────────────────────────────────────────────────────────────────────┘
         │
         │ Spawns in dependency waves
         ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ WORKERS (Subagents)                                                     │
│                                                                          │
│ Wave 1: [chunk-001, chunk-002, chunk-003]  ← parallel, no deps          │
│              │           │           │                                   │
│              ▼           ▼           ▼                                   │
│ Wave 2: [chunk-004, chunk-005, chunk-006]  ← after wave 1               │
│                          │                                               │
│                          ▼                                               │
│ Wave 3: [chunk-007, ...]                   ← after wave 2               │
└─────────────────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ SHARED FILESYSTEM                                                        │
│                                                                          │
│ .claude/orchestration/                                                  │
│ ├── manifest.md      (DAG, progress, cost tracking)                     │
│ ├── chunks/*.md      (individual chunk state)                           │
│ └── heartbeats/*.txt (worker liveness)                                  │
└─────────────────────────────────────────────────────────────────────────┘
```

### Safety Limits

| Limit | Value | Purpose |
|-------|-------|---------|
| MAX_CONCURRENT_WORKERS | 3 | API rate limits, debuggability |
| MAX_TOTAL_WORKERS | 50 | Prevent runaway spawning |
| MAX_RETRIES_PER_CHUNK | 3 | Then escalate |
| MAX_CONSECUTIVE_FAILURES | 5 | Circuit breaker trips |
| WORKER_TIMEOUT | 10 min | Kill stalled workers |
| HEARTBEAT_STALE | 90 sec | Detect dead workers |

### Context Tiers for Workers

| Tier | Content | Size | Loaded |
|------|---------|------|--------|
| 1 | attention.md + chunk file | ~2KB | Always |
| 2 | patterns.md, dependent chunk outputs | Variable | On demand |
| 3 | Full task_plan.md, all history | Large | Never (summarized) |

### Continuity

Workers share context via filesystem, not conversation:

### Subagent Prompt Injection

Each agent definition includes:

```markdown
# Agent: executor

## Context Loading (REQUIRED)
Before starting work, read these files:
- `.claude/memory/checkpoint.md` - Current task state
- `.claude/memory/attention.md` - Critical information

## Context Saving (REQUIRED)
After completing work, update:
- `.claude/memory/progress.md` - Append your results
- `.claude/memory/checkpoint.md` - Update completed items

## Abort Compliance
The PreToolUse hook will block your tools if abort signal is active.
If blocked, stop gracefully. Do not retry.
```

### Subagent Types

| Agent | Purpose | Reads | Writes |
|-------|---------|-------|--------|
| executor | Pure action, no explanation | checkpoint, attention | progress, checkpoint |
| verifier | Run tests, validate changes | progress, checkpoint | progress, errors |
| learner | Extract patterns from errors | errors, progress | patterns |
| orchestrator | Decompose complex tasks | checkpoint | checkpoint (subtasks) |

## Hook Configuration

```json
{
  "hooks": {
    "SessionStart": [{
      "matcher": "*",
      "hooks": [{
        "type": "command",
        "command": "${CLAUDE_PLUGIN_ROOT}/scripts/session-start.sh",
        "timeout": 10
      }]
    }],

    "PreToolUse": [{
      "matcher": "Bash|Edit|Write|Task|NotebookEdit",
      "hooks": [{
        "type": "command",
        "command": "${CLAUDE_PLUGIN_ROOT}/scripts/pre-tool-use.sh",
        "timeout": 2
      }]
    }],

    "PreCompact": [{
      "matcher": "*",
      "hooks": [{
        "type": "command",
        "command": "${CLAUDE_PLUGIN_ROOT}/scripts/pre-compact.sh",
        "timeout": 30
      }]
    }],

    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{
          "type": "command",
          "command": "${CLAUDE_PLUGIN_ROOT}/scripts/post-bash.sh",
          "timeout": 5
        }]
      },
      {
        "matcher": "Edit|Write",
        "hooks": [{
          "type": "command",
          "command": "${CLAUDE_PLUGIN_ROOT}/scripts/post-edit.sh",
          "timeout": 10
        }]
      }
    ],

    "Stop": [{
      "matcher": "*",
      "hooks": [{
        "type": "command",
        "command": "${CLAUDE_PLUGIN_ROOT}/scripts/stop-loop.sh",
        "timeout": 30
      }]
    }]
  }
}
```

## Commands

### /loop
Start autonomous loop.

```
/loop "Build X with Y" --done "COMPLETE" --max-iters 50
```

Options:
- `--done <promise>` - Completion phrase (required for finite loops)
- `--max-iters <n>` - Safety limit (default: 100)
- `--quiet` - Minimal output between iterations

### /abort
Stop all agents.

```
/abort          # Create abort signal
/abort clear    # Remove abort signal, resume
/abort status   # Check if abort is active
```

### /status
Check progress without entering session.

```
/status         # Show current iteration, progress, errors
```

## File Structure

```
aeon-loop/
├── .claude-plugin/
│   └── plugin.json
├── marketplace.json
├── README.md
├── CLAUDE.md                      # Philosophy injection
│
├── commands/
│   ├── loop.md                    # Start autonomous loop
│   ├── abort.md                   # Stop all agents
│   └── status.md                  # Check progress
│
├── agents/
│   ├── executor.md                # Pure action agent
│   ├── verifier.md                # Test runner
│   ├── learner.md                 # Pattern extraction
│   └── orchestrator.md            # Task decomposition
│
├── skills/
│   └── bash-loop/
│       └── SKILL.md               # Activates "shut up and calculate" mode
│
├── hooks/
│   └── hooks.json
│
├── scripts/
│   ├── setup-loop.sh              # Initialize loop state
│   ├── session-start.sh           # Load context
│   ├── pre-tool-use.sh            # Abort check
│   ├── pre-compact.sh             # Save attention
│   ├── post-bash.sh               # Capture errors
│   ├── post-edit.sh               # Verification trigger
│   └── stop-loop.sh               # Loop continuation OR completion
│
└── templates/
    ├── checkpoint.md
    ├── progress.md
    └── attention.md
```

## Key Differences from Source Plugins

| Feature | ralph-loop | aeon-flux | mind-glaive | aeon-loop |
|---------|-----------|-----------|-------------|-----------|
| Loop engine | ✅ | - | - | ✅ |
| Abort system | - | ✅ | - | ✅ |
| Context persistence | - | partial | ✅ | ✅ |
| Subagent coordination | - | ✅ | - | ✅ (enhanced) |
| Pattern learning | - | - | ✅ | ✅ |
| Attention preservation | - | ✅ | ✅ | ✅ |
| Action philosophy | - | ✅ | - | ✅ |

## Migration Path

For existing users:
1. Disable aeon-flux and mind-glaive plugins
2. Install aeon-loop
3. Existing `.claude/memory/` files are compatible
4. `/checkpoint` → `/status`
5. `/focus` → Still works (or use attention markers directly)

## Open Questions

1. Should /loop auto-activate bash-loop skill, or let user opt-in?
2. How verbose should iteration transitions be?
3. Should we support multiple concurrent loops (different tasks)?
