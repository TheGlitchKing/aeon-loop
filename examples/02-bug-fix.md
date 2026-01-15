# Example: Fixing a Bug

You've discovered a race condition in your authentication system.

## Start the Workflow

```bash
/aeon-flux
```

## Phase 0: Exploration

```
Claude: I see this is an existing project. Would you like me to explore first?

1. Yes, explore first
   1.1. Full analysis
   1.2. Quick overview

2. No, skip exploration
   2.1. I'm familiar with this codebase
   2.2. This is a new project

You: 2.1
```

## Phase 1: Discovery

```
Claude: What would you like to build?

You: There's a race condition in the auth system. When two requests hit
     the session endpoint simultaneously, sometimes both get authenticated
     even though one should fail.

Claude: I understand - a race condition in session handling. Let me ask:

1. Where is the issue occurring?
   1.1. Login endpoint
   1.2. Session validation middleware
   1.3. Token refresh
   1.4. Not sure - need investigation

2. What should happen when concurrent requests occur?
   2.1. First request wins, second fails
   2.2. Both should work (parallel sessions allowed)
   2.3. Queue and process sequentially
   2.4. Need to determine correct behavior

3. What's the priority?
   3.1. Critical - security issue, fix immediately
   3.2. High - causes user problems
   3.3. Medium - edge case, fix when possible

You: 1.2, 2.1, 3.1
```

## Phase 2: PRD Creation

```
Claude: Creating the PRD...

# PRD: Fix Session Validation Race Condition

## Overview
Fix the race condition in session validation middleware where concurrent
requests can both succeed when only one should.

## Goals
- Prevent duplicate session validation for same user
- Ensure first-request-wins behavior
- Add regression tests to prevent recurrence
- Zero security vulnerabilities

## User Stories

### US-001: Investigate Race Condition
As a developer, I need to understand the exact cause of the race
condition so that I can implement the correct fix.

**Acceptance Criteria:**
- [ ] Identify the vulnerable code path
- [ ] Document how the race occurs
- [ ] Determine correct locking strategy
- [ ] Update notes.md with findings

### US-002: Implement Fix
As a developer, I need to fix the race condition so that concurrent
requests are handled correctly.

**Acceptance Criteria:**
- [ ] Add appropriate locking/mutex
- [ ] First request wins, second returns 409 Conflict
- [ ] No deadlock possible
- [ ] Typecheck passes
- [ ] Existing tests pass

### US-003: Add Regression Tests
As a developer, I need regression tests so that this bug cannot
recur undetected.

**Acceptance Criteria:**
- [ ] Test concurrent requests to same session
- [ ] Test first-wins behavior
- [ ] Test no deadlock under load
- [ ] All tests pass

### US-004: Verify Fix
As a developer, I need to verify the fix works in realistic
conditions.

**Acceptance Criteria:**
- [ ] Manual test with concurrent requests
- [ ] Load test with 100 concurrent users
- [ ] No race condition observed
- [ ] Performance acceptable (< 50ms added latency)

...

Does this capture the fix needed?

You: Yes
```

## Phase 3: Planning

```
Claude: Creating the implementation plan...

## Phases
1. Investigation - US-001
2. Implementation - US-002
3. Testing - US-003
4. Verification - US-004

Ready to start?

You: Yes
```

## Phase 4: Execution Mode

```
Claude: How would you like to proceed?

A) Set it and forget it
B) Be in the loop

You: B
```

Since this is a critical security fix, collaborative mode lets you review each step.

## Phase 5: Collaborative Execution

```
Claude: Starting with Phase 1: Investigation

US-001: Investigate Race Condition

[Claude explores the codebase, finds the issue]

Found the issue in src/middleware/session.ts:47

The problem: Session lookup and validation happen in two separate
database calls without a transaction or lock:

1. Check if session exists (SELECT)
2. Validate session (UPDATE)

Between steps 1 and 2, another request can also pass step 1.

Recommended fix: Use SELECT FOR UPDATE or add Redis-based locking.

US-001 complete!

Progress: 1/4 stories done
Next: US-002 - Implement Fix

Continue?

You: Yes, use Redis locking - we already have Redis for caching
```

```
Claude: Implementing Redis-based distributed lock...

[Claude implements the fix]

US-002 complete!

Changes made:
- Added src/utils/sessionLock.ts
- Modified src/middleware/session.ts to acquire lock before validation
- Lock TTL: 5 seconds (prevents deadlock)
- Returns 409 Conflict if lock acquisition fails

Progress: 2/4 stories done
Next: US-003 - Add Regression Tests

Continue?

You: Yes
```

```
Claude: Writing regression tests...

[Claude creates tests]

US-003 complete!

Created tests in src/__tests__/session-race.test.ts:
- test_concurrent_requests_first_wins
- test_second_request_gets_409
- test_no_deadlock_under_load
- test_lock_releases_after_ttl

All 4 tests passing.

Progress: 3/4 stories done
Next: US-004 - Verify Fix

Continue?

You: Yes
```

## Phase 6: Testing

```
Claude: Running comprehensive test suite...

Test Results: 127 passed, 0 failed

All existing tests still pass.
New regression tests pass.
No security vulnerabilities detected.
```

## Phase 7: Verification

```
Claude: Verifying against original PRD...

All requirements met:
- [x] Race condition identified and documented
- [x] Fix implemented with Redis locking
- [x] First-request-wins behavior confirmed
- [x] Regression tests added
- [x] All tests passing
- [x] No deadlock possible (TTL prevents)

The race condition fix is complete!

Files modified:
- src/middleware/session.ts (added locking)
- src/utils/sessionLock.ts (new)
- src/__tests__/session-race.test.ts (new)

Recommended next steps:
- Deploy to staging for load testing
- Monitor for 409 responses in production
- Consider adding metrics for lock contention
```

## Files Created

```
.planning/fix-session-race-condition/
├── prd.md              # Full PRD with security context
├── task_plan.md        # Implementation phases
└── notes.md            # Investigation findings, code paths

.claude/memory/
├── checkpoint.md       # Final state
└── patterns.md         # Learned: Redis locking pattern
```
