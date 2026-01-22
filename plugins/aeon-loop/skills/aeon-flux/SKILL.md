---
name: aeon-flux
description: "Unified project workflow: PRD generation → Planning → Approval → Execution. Start here for any new project. Guides you through requirements, creates plans, and executes autonomously or collaboratively."
---

# Aeon Flux - Unified Project Workflow

The complete workflow for taking a project from idea to implementation.

---

## Overview

Aeon Flux guides users through:
1. **Exploration (Optional)** - Understand existing codebase first
2. **Discovery** - Ask questions until 90% confident
3. **PRD Creation** - Generate Product Requirements Document
4. **Planning** - Create task plan with right-sized stories
5. **Approval** - User reviews and approves plan
6. **Execution Mode Choice** - Autonomous or collaborative
7. **Implementation** - Execute until all stories complete
8. **Comprehensive Testing** - Create and run tests for entire product
9. **Verification** - Check PRD for completeness

---

## Phase 0: Exploration (Optional)

When the user runs `/aeon-flux`, first check if exploration would help:

### Detect Existing Codebase

Check if there's an existing project:
```bash
# Look for common project indicators
ls package.json Cargo.toml pyproject.toml go.mod pom.xml *.csproj 2>/dev/null
```

### Offer Exploration

If an existing codebase is detected:

```
I see this is an existing project. Would you like me to explore the codebase first?

1. Yes, explore first
   1.1. Full analysis (structure, patterns, architecture)
   1.2. Quick overview (just structure and key files)

2. No, skip exploration
   2.1. I'm familiar with this codebase
   2.2. This is a new/empty project
```

### If User Chooses Exploration

Run the `/explore` skill internally:

1. Launch parallel exploration agents (or quick overview)
2. Generate exploration report
3. Save to `.planning/exploration/report.md`
4. Use findings to inform subsequent questions

```
Exploring the codebase...

[Launch exploration agents]

Here's what I found:
[Brief summary]

Full report saved to .planning/exploration/report.md

Now let's discuss what you want to build...
```

### Skip Exploration If:
- User says they're familiar with the codebase
- This is a new/empty project
- User explicitly wants to skip

---

## Phase 1: Discovery

After exploration (or skipping it):

### Start the Conversation

```
What would you like to build?
```

Or if they already described it:

```
I'd like to help you build [their idea]. Let me ask a few questions to make sure I understand what you need.
```

### Use Exploration Context

If exploration was done, reference findings in questions:

```
Based on the codebase exploration, I see you're using [framework] with [patterns].

1. Should this new feature follow the existing patterns?
   1.1. Yes, match existing architecture
   1.2. No, this needs a different approach
   1.3. Let's discuss the tradeoffs
```

### Ask Clarifying Questions

Ask 3-5 essential questions with numbered sub-options for quick answers:

```
1. What is the primary goal?
   1.1. New product/feature from scratch
   1.2. Enhancement to existing system
   1.3. Fix or refactor existing code
   1.4. Other: [please specify]

2. What's the target scope?
   2.1. Minimal viable version (MVP)
   2.2. Full-featured implementation
   2.3. Proof of concept / prototype
   2.4. Production-ready with tests

3. What technologies/frameworks?
   3.1. Use existing stack (I'll detect from codebase)
   3.2. [Suggest based on project type]
   3.3. [Suggest alternative]
   3.4. Other: [please specify]
```

User can respond: "1.1, 2.2, 3.1"

### Continue Until 90% Confident

Keep asking until you can confidently:
- Describe what "done" looks like
- List the core features
- Identify technical constraints
- Define out-of-scope items

### Transition Signal

When ready:

```
I think I have enough to create a PRD. Here's what I understand:

[Brief summary of the project]

Does this capture what you want to build?
```

---

## Phase 2: PRD Creation

After user confirms understanding:

```
Creating the Product Requirements Document...
```

### Generate PRD Content

Create the PRD following the standard structure:

1. **Overview** - Brief description
2. **Goals** - Bullet list of objectives
3. **User Stories** - Right-sized stories (2-3 sentence rule)
4. **Functional Requirements** - Numbered FR-1, FR-2, etc.
5. **Non-Goals** - What's explicitly out of scope
6. **Technical Considerations** - Constraints, integrations
7. **Success Criteria** - How to verify completion
8. **Open Questions** - Remaining unknowns

### Story-Sizing Discipline

**Critical:** Each user story MUST be completable in the **first 60% of a context window**.

The 60% rule:
- 20% for context loading
- 60% for actual work
- 20% buffer for errors

Right-sized examples (fit in 60%):
- Add a database column with migration (~30 lines)
- Create a single UI component (~50 lines)
- Implement one API endpoint with tests (~80 lines)

Too large (must split):
- "Build entire dashboard" → Split into individual widgets (5-10 stories)
- "Implement auth system" → Split into US-001: Register, US-002: Login, US-003: Logout, US-004: Sessions

**Verification:** After generating stories, check each one:
- Can describe in 2-3 sentences?
- Touches only 1-3 files?
- Requires <200 lines of code?
- If NO to any → split it

### Add State Block

After user stories, add the machine-parseable state block:

```markdown
<!-- STATE
stories:
  - id: US-001
    title: "Story title"
    passes: false
    notes: ""
  - id: US-002
    title: "Story title"
    passes: false
    notes: ""
/STATE -->
```

### Save PRD

Generate task slug from project name and save:

```bash
# Create planning directory
mkdir -p .planning/[task-slug]

# Save PRD
# Write to .planning/[task-slug]/prd.md
```

### Verify Story Sizing

Before presenting to user, verify all stories follow the 60% rule:

```
Checking story sizes...

✓ US-001: User Registration (1 file, ~40 lines) - fits in 60%
✓ US-002: Login Form (1 file, ~50 lines) - fits in 60%
✓ US-003: Session Management (2 files, ~80 lines) - fits in 60%
✗ US-004: Complete Dashboard (8 files, ~400 lines) - TOO LARGE

US-004 needs to be split. I'll break it into smaller stories...
```

If any story is too large, automatically split it before showing the PRD to the user.

### Present for Approval

```
Here's the PRD with [N] right-sized user stories:

[Show full PRD content]

All stories sized to complete in 60% of context window (leaves buffer for errors).

Does this capture all the features we discussed? Any changes needed?
```

---

## Phase 3: Planning

After PRD approval:

```
Creating the implementation plan...
```

### Run Planning Setup

Execute the planning initialization:

```bash
bash "${CLAUDE_PROJECT_DIR:-$(pwd)}/plugins/aeon-loop/scripts/init-planning.sh" "[Project Name]"
```

### Create Task Plan from PRD

Convert user stories into phases in `task_plan.md`:

- Group related stories into phases
- Ensure dependency order (schema → backend → frontend)
- Each phase should be 2-4 stories max

### Add State Block to Task Plan

```markdown
<!-- STATE
phases:
  - id: 1
    name: "Phase name"
    passes: false
  - id: 2
    name: "Phase name"
    passes: false
stories:
  - id: US-001
    passes: false
  - id: US-002
    passes: false
/STATE -->
```

### Present Plan for Approval

```
Here's the implementation plan:

## Phases
1. [Phase 1 name] - Stories US-001, US-002
2. [Phase 2 name] - Stories US-003, US-004
3. [Phase 3 name] - Stories US-005
4. Testing & Verification

[Show task_plan.md content]

Does this plan look good? Any changes before we start?
```

---

## Phase 4: Execution Mode Choice

After plan approval:

```
Ready to start implementation!

How would you like to proceed?

A) **Set it and forget it** (Recommended)
   - I'll work autonomously until complete
   - Check /status anytime to see progress
   - Use /abort if you need to stop

B) **Be in the loop**
   - I'll check in with you periodically
   - You can guide decisions as we go
   - More collaborative but slower
```

---

## Phase 5A: Autonomous Execution ("Set it and forget it")

If user chooses A:

```
Starting autonomous execution.

You can:
- Check progress anytime: /status
- Stop execution: /abort

I'll let you know when it's complete!
```

### Initialize Loop

Create loop state and begin execution:

```bash
# This is what happens internally - execute the loop setup
bash "${CLAUDE_PROJECT_DIR:-$(pwd)}/plugins/aeon-loop/scripts/setup-loop.sh" "[Task description from PRD]" --done "COMPLETE"
```

### Execution Behavior

- Work through stories in dependency order
- Update STATE block as stories complete
- No user interaction unless blocked
- Continue until all stories pass

### Completion Check

When all stories have `passes: true` in STATE block:

1. Verify all STATE blocks show `passes: true`
2. Proceed to Phase 6: Comprehensive Testing

---

## Phase 5B: Collaborative Execution ("Be in the loop")

If user chooses B:

```
Let's work through this together.

Starting with Phase 1: [Phase name]

First story: US-001 - [Story title]
[Story description]

Ready to begin?
```

### Execution Behavior

- Work on one story at a time
- After each story, show progress and ask to continue
- User can redirect, pause, or modify approach
- Update STATE block as stories complete

### Checkpoint Prompts

After each story:

```
US-001 complete!

Progress: 1/[total] stories done
Next: US-002 - [Story title]

Continue, or would you like to review/adjust anything?
```

### Allow Commands

In collaborative mode, remind user they can:
- `/status` - See full progress
- `/checkpoint` - Save current state
- `/pause` - Pause and come back later
- `/abort` - Stop completely

When all stories complete, proceed to Phase 6: Comprehensive Testing.

---

## Phase 6: Comprehensive Testing

**Only proceed to this phase after verifying all stories have `passes: true` in STATE block.**

### Pre-Testing Verification

Before running tests, confirm:

```bash
# Check all stories are complete
grep -c "passes: false" .planning/*/prd.md
# Should return 0
```

If any stories are incomplete, return to implementation phase.

### Detect Test Framework

Identify the project's test setup:

```bash
# Check for common test frameworks
ls package.json 2>/dev/null && grep -E "jest|mocha|vitest|ava" package.json
ls pytest.ini pyproject.toml setup.py 2>/dev/null
ls Cargo.toml 2>/dev/null && grep -q "\[dev-dependencies\]" Cargo.toml
ls *_test.go 2>/dev/null
ls build.gradle pom.xml 2>/dev/null
```

### Determine Test Command

Based on detected framework:

| Framework | Test Command |
|-----------|--------------|
| Jest | `npm test` or `npx jest` |
| Pytest | `pytest` or `python -m pytest` |
| Go | `go test ./...` |
| Cargo | `cargo test` |
| JUnit | `./gradlew test` or `mvn test` |

### Create Missing Tests

For each user story in the PRD, verify tests exist:

```
Checking test coverage for implemented features...

US-001: User Registration
  → Found: src/tests/auth.test.ts (registration tests)

US-002: User Login
  → Missing tests! Creating...
  → Created: src/tests/login.test.ts

US-003: API Endpoints
  → Found: src/tests/api.test.ts (partial)
  → Adding missing endpoint tests...
```

### Test Creation Guidelines

When creating tests:

1. **Unit tests** for individual functions/methods
2. **Integration tests** for API endpoints and data flow
3. **Edge cases** based on acceptance criteria in PRD
4. **Error handling** tests for failure scenarios

### Run Full Test Suite

```bash
# Run all tests
[detected test command]

# Example outputs to handle:
# ✓ All tests passed → proceed to verification
# ✗ Tests failed → fix and re-run
```

### Handle Test Failures

If tests fail:

1. Analyze failure output
2. Identify root cause (implementation bug vs test bug)
3. Fix the issue
4. Re-run tests
5. Repeat until all pass

```
Test Results: 47 passed, 2 failed

Failed:
  ✗ login.test.ts: should reject invalid credentials
  ✗ api.test.ts: should return 404 for missing resource

Fixing issues...
[Makes fixes]

Re-running tests...
Test Results: 49 passed, 0 failed

All tests passing! Proceeding to verification.
```

### Test Completion Criteria

Before proceeding to verification:

- [ ] All existing tests pass
- [ ] New tests created for each user story
- [ ] Edge cases covered
- [ ] No skipped or pending tests
- [ ] Test coverage acceptable for project

---

## Phase 7: Final Verification

When all stories are marked complete AND all tests pass:

### Re-read PRD

```bash
cat .planning/[task-slug]/prd.md
```

### Verify All Requirements Met

Go through each:
- User Story - Is it implemented and working?
- Functional Requirement - Is it satisfied?
- Success Criteria - Does it pass?

### If Something Was Missed

```
Reviewing the original PRD, I found some items that may need attention:

- [Missed item 1]
- [Missed item 2]

Would you like me to:
A) Create a follow-up plan to address these
B) Mark as out of scope for now
C) These are actually complete (explain why)
```

If A: Loop back to Phase 3 (Planning) with missed items only.

### If Everything Complete

```
All requirements from the original PRD have been implemented!

Summary:
- [X] stories completed
- [X] phases finished
- All acceptance criteria passing

The project is complete.

Files created:
- [List key files]

Next steps you might consider:
- Run full test suite: [command]
- Deploy to staging: [command]
- Review documentation
```

---

## Quick Reference

### Commands Available During Execution

| Command | Purpose |
|---------|---------|
| `/status` | Show current progress |
| `/abort` | Stop all execution |
| `/pause` | Pause loop (autonomous mode) |
| `/resume` | Resume paused loop |
| `/checkpoint` | Force save current state |

### Files Created

```
.planning/[task-slug]/
├── prd.md          # Product Requirements Document
├── task_plan.md    # Implementation plan with phases
└── notes.md        # Research and findings

.claude/
├── loop-state.md   # Loop execution state (autonomous mode)
├── memory/
│   ├── checkpoint.md
│   ├── attention.md
│   └── patterns.md
└── orchestration/  # Worker coordination (if parallel)
```

---

## Example Session

```
User: /aeon-flux

Claude: What would you like to build?

User: A mobile weather app

Claude: Great! Let me ask a few questions:

1. What platforms?
   A. iOS only
   B. Android only
   C. Both (React Native/Flutter)
   D. Web-based (PWA)

2. What weather data features?
   A. Current conditions only
   B. Current + 7-day forecast
   C. Current + forecast + alerts
   D. Full featured (radar, maps, etc.)

3. Scope for initial version?
   A. MVP - core features only
   B. Full app with polish
   C. Prototype/proof of concept

User: 1C, 2B, 3A

Claude: Got it - React Native app with current weather and 7-day forecast, MVP scope.

A few more questions:
[continues until 90% confident]

Claude: I think I have enough. Here's what I understand:
[summary]
Does this capture what you want?

User: Yes

Claude: Creating the PRD...
[shows PRD]
Does this look complete?

User: Yes

Claude: Creating the implementation plan...
[shows plan]
Ready to start?

User: Yes

Claude: How would you like to proceed?
A) Set it and forget it
B) Be in the loop

User: A

Claude: Starting autonomous execution. Check /status anytime!
[begins /loop internally]

[... time passes ...]

Claude: All stories complete! Verifying against PRD...

Everything looks good! Your weather app is ready.
[summary of what was built]

<promise>COMPLETE</promise>
```

---

## Checklist

Before starting execution, verify:

- [ ] User confirmed understanding of project
- [ ] PRD created with right-sized stories
- [ ] STATE block added to PRD
- [ ] Task plan created with phases
- [ ] STATE block added to task plan
- [ ] User approved the plan
- [ ] User chose execution mode
- [ ] Loop initialized (if autonomous)
