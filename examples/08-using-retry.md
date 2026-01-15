# Example: Using /retry

## When to Use
- A specific chunk failed after automatic retries
- Circuit breaker tripped on a chunk
- Want to retry with fresh context

## Command
```bash
/retry chunk-003
```

## What Happens

1. Resets retry count for that chunk
2. Spawns fresh worker for the chunk
3. Worker loads:
   - `.claude/memory/attention.md` - task context
   - `.claude/orchestration/chunks/chunk-003.md` - chunk details
   - Any dependent chunk outputs
4. Attempts execution again

## Finding Failed Chunks

```bash
/status
```
Shows which chunks failed and their IDs.

Or check the manifest:
```bash
cat .claude/orchestration/manifest.md
```

## How Retry Relates to Planning

Failed chunks may indicate:
- **Plan needs refinement** - unclear requirements
- **Missing context** - add to notes.md
- **Impossible task** - revise task_plan.md

## Workflow: Investigate Then Retry

```bash
# Check status, see chunk-007 failed
/status

# Look at the chunk definition
cat .claude/orchestration/chunks/chunk-007.md

# Check error log
cat .claude/memory/errors.md

# Check if plan needs clarification
cat .planning/[task-slug]/task_plan.md

# Option A: Transient error (network, timeout) - just retry
/retry chunk-007

# Option B: Need to clarify requirements
# Edit .planning/[task-slug]/task_plan.md to add details
# Edit .planning/[task-slug]/notes.md with findings
/retry chunk-007

# Option C: Code bug - fix first, then retry
# Fix the code
/retry chunk-007
```

## Updating Plan After Failures

If chunks keep failing, update your plan:

```bash
# Edit .planning/[task-slug]/task_plan.md

## Errors Encountered
- chunk-007 failed: Missing database connection
  → Resolution: Added DB setup to Phase 1

## Decisions Made
- Split Phase 3 into smaller chunks
- Added explicit DB initialization step
```

This documents the fix for future reference.

## When NOT to Retry

- Same chunk fails 3+ times → investigate the task definition
- Circuit breaker tripped → review errors first
- Plan is fundamentally flawed → `/pause`, revise plan, `/resume`
