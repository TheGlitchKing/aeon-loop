# Aeon Loop Examples

Learn how to use each command effectively.

## The Two Approaches

### Option A: Plan First (Recommended)
```bash
/start-planning "Your task"     # Create planning structure
# Edit .planning/[task]/task_plan.md to customize
/loop "Your task" --done "DONE" # Start autonomous execution
```

### Option B: Direct Loop
```bash
/loop "Your task" --done "DONE" # Creates planning files automatically
```

## When to Plan First

| Scenario | Recommendation |
|----------|----------------|
| Simple, clear task | Direct `/loop` is fine |
| Complex task | `/start-planning` first |
| Need custom phases | `/start-planning` first |
| Want to review before executing | `/start-planning` first |
| API development | `/start-planning` first |
| Large refactoring | `/start-planning` first |

## Examples by Use Case

| Example | Use Case |
|---------|----------|
| [01-simple-feature.md](01-simple-feature.md) | Basic feature implementation |
| [02-bug-fix-with-tests.md](02-bug-fix-with-tests.md) | Bug fixes with verification |
| [03-large-refactoring.md](03-large-refactoring.md) | Multi-file changes |
| [04-api-development.md](04-api-development.md) | Building new APIs |

## Examples by Command

| Example | Commands Covered |
|---------|-----------------|
| [05-using-abort.md](05-using-abort.md) | `/abort`, `/abort clear`, `/abort status` |
| [06-using-status.md](06-using-status.md) | `/status` |
| [07-using-pause-resume.md](07-using-pause-resume.md) | `/pause`, `/resume` |
| [08-using-retry.md](08-using-retry.md) | `/retry` |

## Quick Command Reference

```bash
# Create planning structure (without starting loop)
/start-planning "Your task name"

# Start autonomous execution (creates planning if needed)
/loop "Your task" --done "COMPLETE"

# Check progress
/status

# Stop everything immediately
/abort

# Resume after abort
/abort clear
/resume

# Pause gracefully
/pause

# Continue after pause
/resume

# Retry a failed chunk
/retry chunk-003
```

## Planning Files Structure

```
.planning/[task-slug]/
├── task_plan.md    # Phases, decisions, status
└── notes.md        # Research, findings

.claude/
├── loop-state.md   # Iteration tracking
└── memory/
    ├── checkpoint.md  # Progress snapshot
    ├── attention.md   # Critical context
    ├── patterns.md    # Learned patterns
    └── errors.md      # Error log
```
