# Example: Using /status

## When to Use
- Check progress without interrupting
- See current iteration count
- Review any errors or failures
- Monitor subagent progress

## Command
```bash
/status
```

## What It Shows

```
=== Aeon Loop Status ===

Loop: ACTIVE
Iteration: 7 / 100
Task: build-user-api
Started: 2026-01-14 15:00:00

Plan: .planning/build-user-api/task_plan.md
Progress:
- [x] Phase 1: Project setup
- [x] Phase 2: User model
- [ ] Phase 3: JWT auth (CURRENT)
- [ ] Phase 4: Tests

Workers: 2/3 active
Chunks: 12/18 complete

Recent Errors: 1
- TypeError in middleware (iteration 5, resolved)

Abort Signal: INACTIVE
```

## How Status Reads Planning Files

The `/status` command reads:
- `.claude/loop-state.md` - iteration, active state
- `.planning/[task]/task_plan.md` - phase progress
- `.claude/orchestration/manifest.md` - chunk status
- `.claude/memory/errors.md` - recent errors

## When to Check Status

- **Periodically while away** (every hour or so)
- **Before deciding to abort**
- **After returning** to see completion
- **When monitoring** complex multi-chunk tasks

## Understanding the Output

| Field | Meaning |
|-------|---------|
| Loop | ACTIVE, PAUSED, or (not running) |
| Iteration | Current / Max |
| Task | Slug from `.planning/` |
| Plan | Path to task_plan.md |
| Progress | Phases from task_plan.md |
| Workers | Active workers / Max concurrent |
| Chunks | Completed / Total (for orchestration) |
| Errors | Recent errors from memory |
| Abort Signal | Whether /abort was called |

## Status + Planning Integration

The status command helps you understand:

1. **Where in the plan** - which phase is current
2. **How much progress** - iterations used vs available
3. **Any problems** - errors encountered
4. **Worker activity** - for parallel tasks

This maps directly to your task_plan.md structure.
