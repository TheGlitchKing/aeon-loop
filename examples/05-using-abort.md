# Example: Using /abort

## When to Use
- Need to stop a running loop immediately
- Want to pause and review progress
- Something is going wrong

## Commands

### Stop Everything
```bash
/abort
```
Creates abort signal. All agents stop at their next tool boundary.

### Check Status
```bash
/abort status
```
Shows if abort signal is active.

### Resume Work
```bash
/abort clear
```
Removes abort signal. Then use `/resume` to continue the loop.

## What Happens When You Abort

1. Signal file created at `/tmp/aeon-loop-abort-{hash}`
2. PreToolUse hook checks this file before EVERY tool
3. All agents (main + subagents) see the signal
4. Each agent stops at its next action
5. Progress is preserved:
   - `.claude/memory/checkpoint.md` - last progress
   - `.planning/[task]/task_plan.md` - phase status
   - `.claude/memory/attention.md` - critical context

## After Aborting

Your planning files are preserved. You can:

```bash
# Check what was accomplished
cat .planning/[task-slug]/task_plan.md

# Check the checkpoint
cat .claude/memory/checkpoint.md

# Review any errors
cat .claude/memory/errors.md

# Resume from where you stopped
/abort clear
/resume

# Or start fresh with modifications
/start-planning "Modified task"
# Edit the plan
/loop "Modified task" --done "COMPLETE"
```

## Example Workflow

```bash
# Start a task
/loop "Refactor auth system" --done "DONE"

# ... running for a while ...

# Something seems wrong, stop it
/abort

# Check progress
cat .planning/refactor-auth-system/task_plan.md
# See: Phase 2 was in progress, Phase 1 complete

# Check what went wrong
cat .claude/memory/errors.md

# Modify the plan if needed
# Edit .planning/refactor-auth-system/task_plan.md

# Clear abort and continue
/abort clear
/resume
```

## Planning Files After Abort

Your planning files remain intact:

```
.planning/refactor-auth-system/
├── task_plan.md    # Shows completed phases, current status
└── notes.md        # All research/findings preserved

.claude/memory/
├── checkpoint.md   # Exact state when aborted
├── attention.md    # Critical context
└── patterns.md     # Learned patterns (reusable)
```
