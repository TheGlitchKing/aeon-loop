# Example: Using Individual Commands

While `/aeon-flux` is the recommended workflow, you can use individual commands for granular control.

## Available Commands

| Command | Purpose |
|---------|---------|
| `/explore` | Explore codebase with parallel agents |
| `/prd` | Create a PRD only |
| `/start-planning` | Create planning structure only |
| `/loop` | Start autonomous execution |
| `/status` | Check progress |
| `/pause` | Pause after current iteration |
| `/resume` | Continue paused loop |
| `/abort` | Stop immediately |
| `/checkpoint` | Force save current state |

---

## /explore - Understand a Codebase

Use when you need to understand an unfamiliar codebase before working on it.

```bash
/explore
```

### What Happens

```
Claude: What would you like to explore?

1. Full codebase overview
   1.1. Complete analysis (structure, patterns, architecture)
   1.2. Quick overview (just structure and key files)

2. Specific focus area
   2.1. How does [feature] work?
   2.2. Where is [functionality] implemented?

You: 1.1
```

Claude launches 4 parallel agents:
- **Structure Explorer** - Directory layout, entry points
- **Pattern Explorer** - Naming conventions, code patterns
- **Dependency Explorer** - Package analysis
- **Architecture Explorer** - Tech stack, data flow

### Output

Report saved to `.planning/exploration/report.md`

### Focused Exploration

```bash
/explore "authentication system"
```

Explores just the auth-related code.

---

## /prd - Create a PRD Only

Use when you want to create requirements without starting execution.

```bash
/prd "Add user notifications feature"
```

### What Happens

1. Claude asks 3-5 clarifying questions
2. Generates a full PRD with right-sized stories
3. Saves to `.planning/[task-slug]/prd.md`
4. Does NOT start implementation

### When to Use

- You want to review the PRD before execution
- You need to share the PRD with others
- You want to manually customize before running `/loop`

### After Creating PRD

```bash
# Review the PRD
cat .planning/add-user-notifications/prd.md

# Edit if needed
# Then start execution manually:
/loop "Add user notifications" --done "COMPLETE"
```

---

## /start-planning - Create Planning Structure

Use when you want to set up planning files without PRD generation.

```bash
/start-planning "Refactor database layer"
```

### What Gets Created

```
.planning/refactor-database-layer/
├── task_plan.md    # Template with phases
└── notes.md        # Empty notes file
```

### When to Use

- You already know exactly what to do
- You want to write your own plan manually
- You're resuming work from external notes

### After Creating Structure

```bash
# Edit the plan manually
vim .planning/refactor-database-layer/task_plan.md

# Start execution
/loop "Refactor database layer" --done "COMPLETE"
```

---

## /loop - Direct Autonomous Execution

Use when you want to skip the guided workflow and start immediately.

```bash
/loop "Fix all TypeScript errors" --done "ZERO ERRORS"
```

### Options

| Option | Description |
|--------|-------------|
| `--done <text>` | Completion promise (required) |
| `--max-iters <n>` | Max iterations (default: 100) |

### What Happens

1. Creates planning files if they don't exist
2. Starts autonomous execution
3. Iterates until completion promise is output
4. Or until max iterations reached

### When to Use

- Simple, well-defined tasks
- You've already created a PRD via `/prd`
- You know exactly what "done" looks like

---

## /status - Check Progress

Use anytime to see what's happening.

```bash
/status
```

### Output

```
=== Aeon Loop Status ===

Loop: ACTIVE
Iteration: 12 / 100
Task: fix-typescript-errors

Stories: 3/5 complete
Phases: 2/4 complete

Recent Errors: 0
Abort Signal: INACTIVE
```

### When to Use

- During autonomous execution
- After stepping away
- Before deciding to abort

---

## /pause and /resume - Graceful Pause

### Pause

```bash
/pause
```

Loop finishes current iteration, then stops cleanly.

### Resume

```bash
/resume
```

Continues from saved checkpoint.

### When to Use

- Need to review progress before continuing
- Want to manually edit the plan mid-execution
- Taking a break but want to continue later

### Example: Modify Plan Mid-Execution

```bash
# Start a task
/loop "Build API" --done "COMPLETE"

# Pause to review
/pause

# Check progress
cat .planning/build-api/task_plan.md

# Modify the plan
vim .planning/build-api/task_plan.md

# Continue with modified plan
/resume
```

---

## /abort - Emergency Stop

```bash
/abort
```

Stops all execution immediately (at next tool boundary).

### After Aborting

```bash
# Check what was done
cat .planning/[task]/task_plan.md

# Review errors
cat .claude/memory/errors.md

# Clear abort signal
/abort clear

# Resume if desired
/resume
```

### When to Use

- Something is going wrong
- You need to stop immediately
- Want to review before continuing

---

## /checkpoint - Force Save

```bash
/checkpoint
```

Forces an immediate save of current state.

### When to Use

- Before a risky operation
- When you want to ensure progress is saved
- Before manually editing files

---

## Combining Commands

### Explore Then Build

```bash
# First, understand the codebase
/explore

# Then create a PRD
/prd "Add new feature based on exploration"

# Review and edit PRD
vim .planning/add-new-feature/prd.md

# Execute
/loop "Add new feature" --done "COMPLETE"
```

### Iterate on a Plan

```bash
# Create initial structure
/start-planning "Complex refactoring"

# Write detailed plan manually
vim .planning/complex-refactoring/task_plan.md

# Start execution
/loop "Complex refactoring" --done "COMPLETE"

# Pause to review
/pause

# Modify plan based on learnings
vim .planning/complex-refactoring/task_plan.md

# Continue
/resume
```

### Recovery After Issues

```bash
# Something went wrong
/abort

# Check status
/status

# Review what happened
cat .claude/memory/errors.md

# Fix the issue manually or update plan
vim .planning/[task]/task_plan.md

# Clear abort and resume
/abort clear
/resume
```

---

## When to Use Which

| Scenario | Recommended Approach |
|----------|---------------------|
| New feature, unclear requirements | `/aeon-flux` |
| Bug fix, known location | `/aeon-flux` (collaborative mode) |
| Simple task, clear scope | `/loop` directly |
| Need to understand codebase first | `/explore` then `/aeon-flux` |
| Want to review PRD before execution | `/prd` then `/loop` |
| Want full manual control | `/start-planning` then `/loop` |
| Resuming interrupted work | `/resume` |
