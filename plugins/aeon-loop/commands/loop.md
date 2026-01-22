---
name: loop
description: Start autonomous task execution loop with fresh agent sessions per iteration
argument-hint: "TASK [--done TEXT] [--max-iters N]"
allowed-tools: ["Bash(${CLAUDE_PLUGIN_ROOT}/scripts/setup-loop.sh:*)"]
---

# Loop Command

Start an autonomous execution loop where **each iteration runs in a fresh agent session**.

## Key Change

Unlike traditional loops that re-inject prompts in the same session, Aeon Loop spawns a fresh Task agent for each iteration. This ensures:
- Clean context boundaries between iterations
- Explicit context loading from files
- No context window bloat
- Forced discipline in state management

## Usage

```
/loop "Your task description" --done "COMPLETE" [options]
```

## Options

| Option | Default | Description |
|--------|---------|-------------|
| `--done <text>` | (none) | Completion promise phrase |
| `--max-iters <n>` | 100 | Maximum iterations |

## Examples

```bash
/loop Build a REST API with JWT auth and tests --done "COMPLETE"
/loop Fix all failing tests in src/ --done "ALL TESTS PASS" --max-iters 20
/loop Refactor authentication module --done "DONE"
```

## Execution

**Step 1**: Run setup script to initialize loop state:

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/setup-loop.sh" $ARGUMENTS
```

**Step 2**: After setup completes, spawn the orchestrator agent.

Read `.claude/loop-state.md` to get the task slug, max iterations, completion promise, and original prompt. Then spawn the orchestrator using the Task tool with instructions from `${CLAUDE_PLUGIN_ROOT}/agents/loop-orchestrator.md`.

The orchestrator will:
1. Read loop state
2. Spawn worker agent for iteration N
3. Wait for worker to complete
4. Check if loop is done (via stop-loop.sh hook)
5. Repeat until complete

## What Gets Created

```
.claude/
├── loop-state.md           # Iteration tracking, completion promise
└── memory/
    ├── checkpoint.md       # Iteration summaries
    ├── attention.md        # Critical context for next iteration
    ├── patterns.md         # Learned patterns
    └── errors.md           # Error log

.planning/[task-slug]/
├── task_plan.md            # Phases and progress
├── prd.md                  # User stories (if using /aeon-flux)
└── notes.md                # Research findings
```

## How It Works

```
User: /loop "Add feature X" --done "COMPLETE"
  ↓
setup-loop.sh creates state files
  ↓
Orchestrator agent spawns
  ↓
Loop:
  Orchestrator spawns Worker agent for iteration N
    ↓
  Worker loads context from files
    ↓
  Worker does work, updates files, exits
    ↓
  stop-loop.sh hook checks completion
    ↓
  Hook updates loop-state.md
    ↓
  Orchestrator checks if done
    ↓
  If not done: repeat with iteration N+1
  ↓
Loop complete!
```

## Worker Sessions

Each iteration runs in a **completely fresh agent session**:

1. Worker agent spawns with NO memory
2. Worker reads context from files:
   - `.claude/memory/checkpoint.md` - What happened last iteration
   - `.claude/memory/attention.md` - Critical decisions
   - `.planning/[task]/task_plan.md` - Task plan
   - `.planning/[task]/prd.md` - User stories
3. Worker executes one iteration of work
4. Worker updates files with progress
5. Worker exits
6. Next worker starts fresh

## Completion

Loop completes when:

1. **Completion promise found**: Worker outputs `<promise>TEXT</promise>`
2. **STATE block complete**: All stories have `passes: true` in PRD
3. **Max iterations**: Reached iteration limit
4. **User abort**: `/abort` command
5. **Circuit breaker**: 5 consecutive failures

The `stop-loop.sh` hook detects completion and updates loop-state.md.

## Monitoring

- `/status` - Check current progress
- `/pause` - Pause after current worker completes
- `/abort` - Stop immediately

## Behavioral Mode

Workers operate in **autonomous execution mode**:
- Action over explanation
- Fix errors immediately
- Update files as progress is made
- Exit when iteration's work is done

See `agents/loop-worker.md` for full worker instructions.
