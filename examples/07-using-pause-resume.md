# Example: Using /pause and /resume

## When to Use /pause
- Need to review progress before continuing
- Want to make manual changes to the plan
- Taking a break but want to continue later

## When to Use /resume
- Continue after `/pause`
- Continue after `/abort clear`
- Pick up where you left off

## Commands

### Pause After Current Iteration
```bash
/pause
```
Loop finishes current iteration, then stops cleanly.

### Resume Paused Loop
```bash
/resume
```
Continues from checkpoint with same settings.

## Difference: /pause vs /abort

| Action | /pause | /abort |
|--------|--------|--------|
| Stops immediately | No (finishes iteration) | Yes (next tool boundary) |
| Checkpoint saved | Yes | Yes |
| Subagents | Finish current work | Stop immediately |
| Resume command | `/resume` | `/abort clear` then `/resume` |

## Workflow: Review and Modify Plan

```bash
# Start a task
/loop "Build payment system" --done "COMPLETE"

# ... some time passes ...

# Want to review progress and modify plan
/pause

# Check what's been done
cat .planning/build-payment-system/task_plan.md

# Modify the plan
# Edit .planning/build-payment-system/task_plan.md
# - Add a new phase
# - Clarify requirements
# - Add notes about approach

# Update notes with new findings
# Edit .planning/build-payment-system/notes.md

# Continue with modified plan
/resume
```

## How Resume Uses Planning Files

When you `/resume`:

1. **SessionStart hook** loads:
   - `.claude/memory/checkpoint.md`
   - `.claude/memory/attention.md`
   - `.planning/[task]/task_plan.md`

2. **Claude sees**:
   - Where it left off (checkpoint)
   - What phases are complete (task_plan.md)
   - Critical context (attention.md)
   - Any modifications you made

3. **Continues from** the updated plan

## Example: Adding a Phase Mid-Loop

```bash
# Initial plan had 4 phases
/loop "Build API" --done "DONE"

# After Phase 2, realize need additional phase
/pause

# Edit .planning/build-api/task_plan.md:
# ## Phases
# - [x] Phase 1: Setup
# - [x] Phase 2: Models
# - [ ] Phase 2.5: Add caching layer  ← NEW
# - [ ] Phase 3: Endpoints
# - [ ] Phase 4: Tests

# Resume - Claude will see the new phase
/resume
```

## Planning Persistence Across Sessions

Even if you close Claude Code:

```bash
# Day 1: Start and pause
/loop "Big project" --done "COMPLETE"
/pause

# Day 2: Resume from saved state
/resume
# Planning files still there, checkpoint restored
```

Your `.planning/` directory persists on disk forever (until you delete it).
