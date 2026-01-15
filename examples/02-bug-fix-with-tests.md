# Example: Bug Fix with Tests

## When to Use
- Known bug location
- Need verification via tests
- Want regression prevention

## Recommended: Plan First

```bash
# 1. Set up planning structure
/start-planning "Fix race condition in user auth"

# 2. Customize the plan with bug details
# Edit .planning/fix-race-condition-in-user-auth/task_plan.md:
#
# ## Goal
# Fix race condition in src/auth/session.ts and add regression tests
#
# ## Phases
# - [ ] Phase 1: Reproduce and understand the bug
# - [ ] Phase 2: Implement the fix
# - [ ] Phase 3: Write regression tests
# - [ ] Phase 4: Verify all tests pass
#
# ## Key Questions
# 1. What triggers the race condition?
# 2. What's the expected behavior?

# 3. Start the loop with test verification
/loop "Fix race condition in user auth" --done "FIXED AND TESTED"
```

## What Happens

1. Loop reads your customized task_plan.md
2. Investigates the race condition
3. Implements a fix
4. Writes regression tests
5. Runs tests to verify
6. Updates task_plan.md with decisions/errors
7. Outputs `<promise>FIXED AND TESTED</promise>` when tests pass

## How Planning Files Are Used

**During work, Claude:**
- Reads `task_plan.md` at start of each iteration (via SessionStart hook)
- Updates Status section as phases complete
- Records errors encountered
- Documents decisions made

**Example task_plan.md after completion:**
```markdown
## Phases
- [x] Phase 1: Reproduce and understand the bug
- [x] Phase 2: Implement the fix
- [x] Phase 3: Write regression tests
- [x] Phase 4: Verify all tests pass

## Decisions Made
- Used mutex lock instead of semaphore
- Added 3 test cases for edge conditions

## Errors Encountered
- First fix attempt failed (didn't handle async case)
- Resolution: Added await to lock acquisition

## Status
**Completed** - All phases done
```

## Why "FIXED AND TESTED"?

Using a specific completion promise ensures:
- Bug is actually fixed (not just attempted)
- Tests are written AND passing
- Claude can't exit early by claiming "done"
