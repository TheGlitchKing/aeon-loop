# Example: Simple Feature Implementation

## When to Use
- Single, well-defined feature
- No complex dependencies
- Can be completed in a few iterations

## Option A: Plan First, Then Loop

Use `/start-planning` to set up planning files, review/edit them, then start the loop:

```bash
# 1. Create planning structure
/start-planning "Add logout button to navbar"

# 2. Review and customize the plan
# Edit .planning/add-logout-button-to-navbar/task_plan.md
# - Refine phases
# - Add specific requirements
# - Note any constraints

# 3. Start the autonomous loop
/loop "Add logout button to navbar" --done "COMPLETE"
```

## Option B: Direct Loop

For simple tasks, `/loop` creates planning files automatically:

```bash
/loop "Add a logout button to the navbar that clears the session and redirects to /login" --done "COMPLETE"
```

## What Happens

1. Planning files created in `.planning/add-a-logout-button-to-the-navbar/`
2. Loop state tracked in `.claude/loop-state.md`
3. Claude implements the feature
4. Progress saved to checkpoint each iteration
5. Outputs `<promise>COMPLETE</promise>` when done
6. Loop exits

## Files Used

```
.planning/add-logout-button-to-navbar/
├── task_plan.md    # Phases, decisions, status (updated during work)
└── notes.md        # Research findings

.claude/
├── loop-state.md   # Iteration count, completion promise
└── memory/
    ├── checkpoint.md  # Progress snapshot (reloaded each iteration)
    └── attention.md   # Critical context
```

## Why Use /start-planning First?

- **Customize phases** before starting
- **Add specific requirements** that might be missed
- **Review complexity** before committing to autonomous execution
- **Plan without executing** if you want to review first
