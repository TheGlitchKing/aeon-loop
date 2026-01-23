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

## Phase 1B: Check for Existing Plan

After user confirms the understanding is correct, ask about existing plans:

```
Do you already have a plan or PRD that you'd like to use?

A) **Yes, I have an existing plan**
   - I'll import your plan and continue from there
   - Must have clear tasks/stories and acceptance criteria

B) **No, create a new PRD for me** (Recommended for new projects)
   - I'll generate a PRD based on our discussion
   - Then create a detailed implementation plan
```

**If user chooses A**: Proceed to Phase 1C (Git Safety Gate), then Phase 2B (Import Existing Plan)
**If user chooses B**: Proceed to Phase 1C (Git Safety Gate), then Phase 2 (PRD Creation)

---

## Phase 1C: Git Safety Gate

Before creating any planning files, check for git repository:

```bash
# Check if in a git repository
git rev-parse --git-dir 2>/dev/null
```

### If Git Repository Detected

```
I see you're in a git repository. Before I start creating planning files,
would you like me to create a new branch for this work?

A) **Yes, create a new branch** (Recommended)
   - I'll create: `aeon/[task-slug]` or a name you specify
   - Keeps your main branch clean

B) **No, stay on current branch**
   - I'll work on: [current-branch-name]
```

### If User Chooses A (Create Branch)

1. Ask for branch name preference:
   ```
   What should I name the branch?

   A) Use default: `aeon/[task-slug]`
   B) Custom name: [let me specify]
   ```

2. Create the branch:
   ```bash
   git checkout -b [branch-name]
   ```

3. Confirm before proceeding:
   ```
   Created branch: [branch-name]
   Now on branch [branch-name]. Proceeding with planning...
   ```

### If User Chooses B (Stay on Current Branch)

```
Staying on branch: [current-branch-name]
Proceeding with planning...
```

### If Not a Git Repository

Skip this step entirely and proceed to the next phase.

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

## Phase 2B: Import Existing Plan

**This phase runs instead of Phase 2 if user chose "Yes, I have an existing plan" in Phase 1B.**

(Git Safety Gate already executed in Phase 1C)

### Get Plan Location

```
Where is your plan located?

A) **File path** - Provide the path to your plan file (e.g., `docs/plan.md`, `PLAN.md`)
B) **Paste content** - I'll paste the plan content directly
```

### Read and Analyze Plan

Read the provided plan and identify:

1. **Goal/objective**: Look for headers like "Goal", "Objective", "Overview", "Summary", "Purpose"
2. **Tasks or user stories**: Look for:
   - Task lists (checkboxes, numbered items)
   - User story patterns ("US-XXX", "As a user...")
   - Requirements sections
   - Feature lists
3. **Acceptance criteria**: Look for "Done when", "Success criteria", "Acceptance criteria", "Requirements"

### Provide Guidance if Needed

If the plan is missing key elements or has issues, provide helpful guidance:

```
I've analyzed your plan. Here's what I found:

✓ Goal: [Detected goal/objective]
✓ Tasks: Found [X] tasks/stories
[✓ or ✗] Acceptance criteria: [status]

[If issues found:]
A few suggestions to make it work better with autonomous execution:

1. **Missing acceptance criteria**: Consider adding "done" definitions for:
   - [Task without clear completion criteria]
   - [Another task]

2. **Large tasks to consider splitting** (60% context rule):
   - "[Task name]" seems complex - consider breaking into smaller pieces

3. **Ambiguous items**:
   - "[Task name]" - what specifically needs to happen?

Would you like to:
A) **Proceed as-is** - I'll work with what's here
B) **Refine together** - Let me help improve the plan first
```

### If Plan Looks Good

```
Your plan looks great! I found:
- Goal: [detected goal]
- [X] tasks/stories ready for execution
- Clear acceptance criteria

Ready to proceed with this plan?
```

### Normalize to Aeon-Loop Format

After user confirms (or chooses to proceed as-is):

1. **Generate task slug** from plan name or goal:
   ```bash
   # Convert "Build REST API" → "build-rest-api"
   TASK_SLUG=$(echo "$PLAN_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\+/-/g' | sed 's/^-\|-$//g')
   ```

2. **Create planning directory**:
   ```bash
   mkdir -p .planning/[task-slug]
   ```

3. **Save original plan** (preserved for reference):
   ```bash
   # Copy/save to .planning/[task-slug]/source-plan.md
   ```

4. **Create prd.md** with STATE block:

   Extract tasks from the plan and create the normalized format:

   ```markdown
   # [Plan Name/Goal]

   ## Source
   This PRD was imported from an existing plan.
   Original: `.planning/[task-slug]/source-plan.md`

   ## Overview
   [Goal/objective from the plan]

   ## User Stories / Tasks

   [Original tasks from the plan, preserved]

   <!-- STATE
   source: imported
   stories:
     - id: TASK-001
       title: "[First task from plan]"
       passes: false
       notes: ""
     - id: TASK-002
       title: "[Second task from plan]"
       passes: false
       notes: ""
     - id: TASK-003
       title: "[Third task from plan]"
       passes: false
       notes: ""
   /STATE -->
   ```

5. **Create task_plan.md** with phases:

   Group related tasks into logical phases:

   ```markdown
   # Task Plan: [Plan Name]

   ## Goal
   [One sentence from the plan's objective]

   ## Phases

   - [ ] Phase 1: [Group name] (TASK-001, TASK-002)
   - [ ] Phase 2: [Group name] (TASK-003, TASK-004)
   - [ ] Phase 3: Testing & Verification

   <!-- STATE
   source: imported
   phases:
     - id: 1
       name: "[Phase 1 name]"
       passes: false
     - id: 2
       name: "[Phase 2 name]"
       passes: false
     - id: 3
       name: "Testing & Verification"
       passes: false
   /STATE -->
   ```

### Confirm Import Complete

```
Plan imported successfully!

Created:
- .planning/[task-slug]/source-plan.md (your original plan)
- .planning/[task-slug]/prd.md (normalized with [X] tasks)
- .planning/[task-slug]/task_plan.md ([Y] phases)

Ready to choose execution mode?
```

**After Phase 2B completes, skip Phase 3 and proceed directly to Phase 4 (Execution Mode Choice).**

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

### Re-read Source Document

Read the original source document to verify all requirements:

```bash
# Check if this was an imported plan or generated PRD
grep -q "source: imported" .planning/[task-slug]/prd.md

# If imported plan, also read the original:
cat .planning/[task-slug]/source-plan.md  # Original imported plan (if exists)
cat .planning/[task-slug]/prd.md          # Normalized PRD with STATE block
```

### Verify All Requirements Met

Go through each item from the source document:
- Task/Story - Is it implemented and working?
- Requirement - Is it satisfied?
- Success Criteria - Does it pass?

### If Something Was Missed

```
Reviewing the original [PRD/plan], I found some items that may need attention:

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
All requirements from the original [PRD/plan] have been implemented!

Summary:
- [X] stories/tasks completed
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
├── prd.md          # Product Requirements Document (or normalized from imported plan)
├── source-plan.md  # Original imported plan (only if using existing plan)
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
