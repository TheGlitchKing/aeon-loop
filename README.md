# Aeon Loop

**Autonomous task execution for Claude Code.** Start a task, walk away, return to find it complete.

## Features Table

| Feature | ralph-loop | aeon-flux | mind-glaive | aeon-loop |
|---------|-----------|-----------|-------------|-----------|
| Loop engine | ✅ | - | - | ✅ |
| Abort system | - | ✅ | - | ✅ |
| Context persistence | - | partial | ✅ | ✅ |
| Subagent coordination | - | ✅ | - | ✅ (enhanced) |
| Pattern learning | - | - | ✅ | ✅ |
| Attention preservation | - | ✅ | ✅ | ✅ |
| Action philosophy | - | ✅ | - | ✅ |
| Persistent planning | - | - | - | ✅ |
| PRD generation | - | - | - | ✅ |

## What Is This?

Aeon Loop is a Claude Code plugin that enables autonomous, multi-iteration task execution. It combines:

| Source Plugin | What It Contributes |
|---------------|---------------------|
| **Ralph Loop** | Autonomous iteration engine (Stop hook re-injects prompt) |
| **Aeon Flux** | Abort system + "action over explanation" philosophy |
| **Mind Glaive** | Context persistence across iterations and compactions |
| **Persistent Planning** | Manus-style persistent markdown planning |

## Quick Start

```bash
# Install from marketplace
/plugin add TheGlitchKing/aeon-loop

# Start any project with one command:
/aeon-flux
```

That's it. The unified workflow guides you through everything.

## The Workflow

When you run `/aeon-flux`, you'll be guided through a complete project lifecycle:

```
/aeon-flux
    │
    ▼
┌─────────────────────────────────────────────────────────────┐
│ PHASE 0: EXPLORATION (Optional)                             │
│                                                             │
│ "I see this is an existing project.                        │
│  Would you like me to explore the codebase first?"         │
│                                                             │
│ 1.1. Full analysis (structure, patterns, architecture)     │
│ 1.2. Quick overview                                        │
│ 2.1. Skip - I'm familiar with this codebase               │
│ 2.2. Skip - This is a new project                          │
│                                                             │
│ → Launches parallel agents to explore                      │
│ → Saves report to .planning/exploration/report.md          │
└─────────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────────┐
│ PHASE 1: DISCOVERY                                          │
│                                                             │
│ "What would you like to build?"                            │
│                                                             │
│ → Asks 3-5 clarifying questions with numbered options      │
│ → You respond: "1.1, 2.2, 3.1"                             │
│ → Continues until 90% confident                            │
└─────────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────────┐
│ PHASE 2: PRD CREATION                                       │
│                                                             │
│ → Generates Product Requirements Document                   │
│ → Right-sized user stories (completable in one iteration)  │
│ → Saves to .planning/[task-slug]/prd.md                    │
│                                                             │
│ "Does this PRD capture what you want?"                     │
└─────────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────────┐
│ PHASE 3: PLANNING                                           │
│                                                             │
│ → Creates implementation plan from PRD                      │
│ → Groups stories into phases                                │
│ → Saves to .planning/[task-slug]/task_plan.md              │
│                                                             │
│ "Here's the plan. Ready to start?"                         │
└─────────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────────┐
│ PHASE 4: EXECUTION MODE                                     │
│                                                             │
│ "How would you like to proceed?"                           │
│                                                             │
│ A) Set it and forget it (Recommended)                      │
│    → Autonomous execution until complete                    │
│    → Check /status anytime                                  │
│    → Use /abort if needed                                   │
│                                                             │
│ B) Be in the loop                                           │
│    → Collaborative, checks in after each story              │
│    → You guide decisions as you go                          │
└─────────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────────┐
│ PHASE 5: IMPLEMENTATION                                     │
│                                                             │
│ → Works through stories in dependency order                 │
│ → Updates progress in STATE blocks                          │
│ → Continues until all stories complete                      │
│ → Verifies all STATE blocks show passes: true               │
└─────────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────────┐
│ PHASE 6: COMPREHENSIVE TESTING                              │
│                                                             │
│ → Only proceeds if all stories are complete                 │
│ → Detects test framework (jest, pytest, go test, etc.)     │
│ → Creates missing tests for new functionality               │
│ → Runs full test suite                                      │
│ → Fixes any failing tests                                   │
│ → Verifies all tests pass before proceeding                 │
└─────────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────────┐
│ PHASE 7: VERIFICATION                                       │
│                                                             │
│ → Re-reads original PRD                                     │
│ → Verifies all requirements met                             │
│ → If something was missed, creates follow-up plan           │
│                                                             │
│ "All requirements implemented. Project complete!"           │
└─────────────────────────────────────────────────────────────┘
```

## Individual Commands

You can also use individual commands if you prefer granular control:

```bash
# Explore codebase only
/explore

# Create PRD only
/prd "Feature description"

# Create planning structure only
/start-planning "Task name"

# Start autonomous execution directly
/loop "Task description" --done "COMPLETE"
```

## Planning System

Aeon Loop uses **persistent markdown files** as working memory. Unlike in-memory todo lists, these files:
- **Persist forever** on disk (until you delete them)
- **Survive context compaction** and session restarts
- **Guide every iteration** of the loop
- **Can be edited** while paused to modify the plan

### Two Layers of Files

| Layer | Location | Purpose | Lifecycle |
|-------|----------|---------|-----------|
| **Planning** | `.planning/[task]/` | Define WHAT to do | Created once, updated during work |
| **Runtime** | `.claude/` | Track HOW it's going | Created by `/loop`, updated each iteration |

### How Planning Files Are Used

```
/loop "Build API" --done "COMPLETE"
         │
         ▼
┌─────────────────────────────────────────────────────────────┐
│ SETUP (once)                                                │
│ Creates .planning/build-api/task_plan.md (if not exists)   │
│ Creates .claude/loop-state.md                              │
│ Creates .claude/memory/checkpoint.md                       │
└─────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────┐
│ EACH ITERATION                                              │
│                                                             │
│ SessionStart hook loads:                                    │
│   → .claude/memory/checkpoint.md (where we left off)       │
│   → .claude/memory/attention.md (critical context)         │
│   → .planning/build-api/task_plan.md (phases, goals)       │
│                                                             │
│ Claude works on the task, guided by task_plan.md           │
│                                                             │
│ Stop hook:                                                  │
│   → Saves progress to checkpoint.md                        │
│   → Updates task_plan.md status                            │
│   → Re-injects prompt for next iteration                   │
└─────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────┐
│ COMPLETION                                                  │
│ When <promise>COMPLETE</promise> is output:                │
│   → Loop exits                                              │
│   → Planning files remain for reference                    │
└─────────────────────────────────────────────────────────────┘
```

### Planning File Templates

**task_plan.md** (created automatically):
```markdown
# Task Plan: Build API

## Goal
Build a REST API with JWT auth

## Phases
- [ ] Phase 1: Analyze requirements and plan approach
- [ ] Phase 2: Implement core functionality
- [ ] Phase 3: Test and validate
- [ ] Phase 4: Review and complete

## Key Questions
1. What are the main components needed?
2. What dependencies exist?

## Decisions Made
- (updated during execution)

## Errors Encountered
- (auto-captured by hooks)

## Status
**Currently in Phase 1** - Starting analysis
```

**notes.md** (for research and findings):
```markdown
# Notes: Build API

## Key Findings
- (discoveries during work)

## Research Sources
- (references used)
```

## Commands

| Command | Description | Example |
|---------|-------------|---------|
| `/aeon-flux` | **Unified workflow** - Explore → PRD → Plan → Execute | `/aeon-flux` |
| `/explore` | Explore codebase with parallel agents | `/explore` or `/explore "auth system"` |
| `/prd` | Generate a Product Requirements Document | `/prd "User authentication"` |
| `/start-planning` | Create planning structure only | `/start-planning "Build API"` |
| `/loop` | Start autonomous execution | `/loop "Build API" --done "DONE"` |
| `/abort` | Stop all agents immediately | `/abort` or `/abort clear` |
| `/status` | Show progress | `/status` |
| `/pause` | Pause after current iteration | `/pause` |
| `/resume` | Continue paused loop | `/resume` |
| `/retry` | Retry a failed chunk | `/retry chunk-003` |
| `/checkpoint` | Force save current state | `/checkpoint` |

### /start-planning vs /loop

| Command | Creates Planning Files | Starts Loop | Use When |
|---------|----------------------|-------------|----------|
| `/start-planning` | ✅ | ❌ | Want to customize plan first |
| `/loop` | ✅ (if needed) | ✅ | Ready to execute immediately |

### /loop Options

| Option | Description | Default |
|--------|-------------|---------|
| `--done <text>` | Completion promise to watch for | (required) |
| `--max-iters <n>` | Maximum iterations before stopping | 100 |
| `--workers <n>` | Max concurrent workers for complex tasks | 3 |
| `--quiet` | Minimal output between iterations | false |

## How It Works

```
/loop "Your task" --done "COMPLETE"
         │
         ▼
┌────────────────────────────────────────┐
│ ITERATION 1                            │
│ - Load context from memory files       │
│ - Read task_plan.md for guidance       │
│ - Work on task                         │
│ - Update task_plan.md status           │
│ - Try to exit                          │
│ - Stop hook blocks, saves checkpoint   │
│ - Re-injects prompt                    │
└────────────────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────┐
│ ITERATION 2                            │
│ - Load checkpoint                      │
│ - Read updated task_plan.md            │
│ - Continue from where left off         │
│ - Make more progress                   │
│ - ...                                  │
└────────────────────────────────────────┘
         │
         ▼
    (repeats until...)
         │
         ▼
┌────────────────────────────────────────┐
│ COMPLETION                             │
│ - Output <promise>COMPLETE</promise>   │
│ - task_plan.md marked complete         │
│ - Stop hook allows exit                │
│ - Task done!                           │
└────────────────────────────────────────┘
```

## Examples

See the [examples/](examples/) folder for detailed usage guides:

| Example | Description |
|---------|-------------|
| [Simple Feature](examples/01-simple-feature.md) | Basic `/loop` usage with `/start-planning` |
| [Bug Fix with Tests](examples/02-bug-fix-with-tests.md) | Fixing bugs with verification |
| [Large Refactoring](examples/03-large-refactoring.md) | Multi-file changes with orchestration |
| [API Development](examples/04-api-development.md) | Building new features |
| [Using /abort](examples/05-using-abort.md) | Stopping and resuming |
| [Using /status](examples/06-using-status.md) | Monitoring progress |
| [Using /pause & /resume](examples/07-using-pause-resume.md) | Graceful pausing |
| [Using /retry](examples/08-using-retry.md) | Retrying failed chunks |

## Safety Limits

| Limit | Value | Purpose |
|-------|-------|---------|
| MAX_CONCURRENT_WORKERS | 3 | API rate limits, debuggability |
| MAX_TOTAL_WORKERS | 50 | Prevent runaway spawning |
| MAX_RETRIES_PER_CHUNK | 3 | Then escalate |
| MAX_CONSECUTIVE_FAILURES | 5 | Circuit breaker trips |
| WORKER_TIMEOUT | 10 min | Kill stalled workers |
| HEARTBEAT_STALE | 90 sec | Detect dead workers |

## File Structure

```
project/
├── .planning/[task-slug]/          # PLANNING LAYER
│   ├── prd.md                      # Product Requirements Document (from /prd)
│   ├── task_plan.md                # Phases, decisions, status
│   └── notes.md                    # Research and findings
│
└── .claude/                        # RUNTIME LAYER
    ├── loop-state.md               # Iteration tracking
    ├── orchestration/              # Chunk breakdown (complex tasks)
    │   ├── manifest.md
    │   └── chunks/
    └── memory/
        ├── checkpoint.md           # Progress snapshot
        ├── attention.md            # Critical context
        ├── patterns.md             # Learned corrections
        └── errors.md               # Error log
```

## Philosophy

Based on the "Bash Loop" / "Ralphy Loop" approach:

1. **Action over explanation** - Just do it, don't narrate
2. **Tight feedback loop** - Observe → Act → Observe → Act
3. **Self-correction** - Errors are feedback, fix immediately
4. **Persistent memory** - Filesystem is external memory
5. **Attention manipulation** - Re-read goals to keep them in focus

## Requirements

- Claude Code 2.0.13+
- Bash shell
- `jq` (for JSON parsing in hooks)

## Installation

### From Marketplace (Recommended)

```
/plugin
→ Add Marketplace
→ TheGlitchKing/aeon-loop
→ Install aeon-loop
```

### Manual

```bash
git clone https://github.com/TheGlitchKing/aeon-loop
cd aeon-loop
# Then in Claude Code:
/plugin install ./plugins/aeon-loop
```

## License

MIT

## Credits

- Inspired by [Ralph Loop](https://ghuntley.com/ralph/) by Geoffrey Huntley
- Built on [Claude Code](https://claude.ai/claude-code) plugin system
- Incorporates [Manus](https://manus.im/) context engineering principles
