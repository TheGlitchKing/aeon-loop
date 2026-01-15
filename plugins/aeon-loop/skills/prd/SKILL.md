---
name: prd
description: "Generate a Product Requirements Document (PRD) for planning. Use when starting a new feature, project, or complex task. Triggers on: create a prd, write prd for, plan this feature, requirements for, spec out, prd for."
---

# PRD Generator

Create detailed Product Requirements Documents that integrate with Aeon Loop's planning system.

---

## Unified Workflow Available

For a complete guided experience (PRD → Planning → Approval → Execution), use:

```
/aeon-flux
```

This skill (`/prd`) creates just the PRD. Use `/aeon-flux` for the full workflow.

---

## The Job

1. Receive a feature/task description from the user
2. Ask 3-5 essential clarifying questions (with numbered sub-options)
3. Generate a structured PRD based on answers
4. Save to `.planning/[task-slug]/prd.md`
5. **After PRD is created**, ask if user wants to continue with planning:
   - If yes → Guide them to run `/aeon-flux` to continue the workflow
   - If no → End here, they can manually run `/loop` later

**Important:** Do NOT start implementing. Just create the PRD.

---

## Step 1: Clarifying Questions

Ask only critical questions where the initial prompt is ambiguous. Focus on:

- **Problem/Goal:** What problem does this solve?
- **Core Functionality:** What are the key actions?
- **Scope/Boundaries:** What should it NOT do?
- **Success Criteria:** How do we know it's done?

### Format Questions Like This:

```
1. What is the primary goal of this feature?
   1.1. Improve user experience
   1.2. Add new functionality
   1.3. Fix existing issues
   1.4. Other: [please specify]

2. What is the scope?
   2.1. Minimal viable version
   2.2. Full-featured implementation
   2.3. Just the backend/API
   2.4. Just the UI

3. What are the key constraints?
   3.1. Must integrate with existing code
   3.2. Greenfield implementation
   3.3. Performance critical
   3.4. Security critical
```

This lets users respond with "1.1, 2.2, 3.1" for quick iteration.

---

## Step 2: PRD Structure

Generate the PRD with these sections:

### 1. Overview
Brief description of the feature and the problem it solves.

### 2. Goals
Specific, measurable objectives (bullet list).

### 3. User Stories
Each story needs:
- **Title:** Short descriptive name
- **Description:** "As a [user], I want [feature] so that [benefit]"
- **Acceptance Criteria:** Verifiable checklist of what "done" means

Each story should be small enough to implement in one focused session.

**Format:**
```markdown
### US-001: [Title]
**Description:** As a [user], I want [feature] so that [benefit].

**Acceptance Criteria:**
- [ ] Specific verifiable criterion
- [ ] Another criterion
- [ ] Tests pass
```

**Important:**
- Acceptance criteria must be verifiable, not vague
- "Works correctly" is bad
- "Button shows confirmation dialog before deleting" is good

### 4. Functional Requirements
Numbered list of specific functionalities:
- "FR-1: The system must allow users to..."
- "FR-2: When a user clicks X, the system must..."

Be explicit and unambiguous.

### 5. Non-Goals (Out of Scope)
What this feature will NOT include. Critical for managing scope.

### 6. Technical Considerations
- Known constraints or dependencies
- Integration points with existing systems
- Performance requirements

### 7. Success Criteria
How will success be measured? What does "done" look like?

### 8. Open Questions
Remaining questions or areas needing clarification.

---

## Story-Sizing Discipline (Ralph Method)

**Critical Rule:** Each user story must be completable in ONE context window (one loop iteration).

### Right-Sized Stories (GOOD)
- Adding a database column with migration
- Creating a single UI component
- Implementing one API endpoint
- Adding a filter dropdown to a list
- Writing tests for one module

### Too Large - Must Split (BAD)
- "Build entire dashboard" → Split into individual widgets
- "Implement authentication system" → Split into register, login, logout, session
- "Refactor entire API" → Split by endpoint or module

### The 2-3 Sentence Rule
**If you cannot describe the change in 2-3 sentences, it is too big.**

### Mandatory Acceptance Criteria
Every story MUST include at minimum:
- [ ] Typecheck passes (for TypeScript/typed projects)
- [ ] Tests pass (if tests exist for this area)
- [ ] Verify in browser (for UI changes)

---

## Writing for Implementation

The PRD reader may be an AI agent executing via `/loop`. Therefore:

- Be explicit and unambiguous
- Avoid jargon or explain it
- Provide enough detail to understand purpose and core logic
- Number requirements for easy reference
- Use concrete examples where helpful
- Include file paths when known

---

## Output

- **Format:** Markdown (`.md`)
- **Location:** `.planning/[task-slug]/`
- **Filename:** `prd.md`

After creating the PRD, also create/update `task_plan.md` in the same directory with phases derived from the user stories.

### State Block (Machine-Parseable Progress)

After the user stories section, add a state block for progress tracking:

```markdown
<!-- STATE
stories:
  - id: US-001
    title: "User Registration"
    passes: false
    notes: ""
  - id: US-002
    title: "User Login"
    passes: false
    notes: ""
/STATE -->
```

This block:
- Lives inside `prd.md` (no separate JSON file needed)
- Is updated by Claude when stories complete (`passes: false` → `passes: true`)
- Is parsed by hooks for progress tracking
- Preserves human readability (inside HTML comment, invisible when rendered)

**Update protocol:** After completing a story, update its `passes` field:
```bash
sed -i '/id: US-001/,/notes:/{s/passes: false/passes: true/}' .planning/*/prd.md
```

---

## Integration with Aeon Loop

After generating the PRD:

1. Create `.planning/[task-slug]/prd.md` with the full PRD
2. Create `.planning/[task-slug]/task_plan.md` with phases based on user stories
3. Inform user they can run `/loop "[task]" --done "COMPLETE"` to execute

The `/loop` command will use the PRD and task_plan.md to guide implementation.

---

## Example PRD

```markdown
# PRD: User Authentication System

## Overview

Implement user authentication with login, logout, and session management. Users should be able to securely access their accounts and have their sessions persist across browser restarts.

## Goals

- Secure user authentication with password hashing
- Session persistence using secure cookies
- Clear login/logout user flow
- Protection against common auth vulnerabilities

## User Stories

### US-001: User Registration
**Description:** As a new user, I want to create an account so that I can access the application.

**Acceptance Criteria:**
- [ ] Registration form with email and password fields
- [ ] Password minimum 8 characters with complexity requirements
- [ ] Email uniqueness validation
- [ ] Success redirects to login page
- [ ] Tests pass

### US-002: User Login
**Description:** As a registered user, I want to log in so that I can access my data.

**Acceptance Criteria:**
- [ ] Login form with email and password fields
- [ ] Invalid credentials show error message (no info leak)
- [ ] Successful login redirects to dashboard
- [ ] Session cookie set with secure flags
- [ ] Tests pass

### US-003: User Logout
**Description:** As a logged-in user, I want to log out so that I can secure my session.

**Acceptance Criteria:**
- [ ] Logout button visible when authenticated
- [ ] Clicking logout clears session
- [ ] Redirects to login page
- [ ] Tests pass

### US-004: Session Persistence
**Description:** As a user, I want my session to persist so I don't have to log in every time.

**Acceptance Criteria:**
- [ ] Session survives browser restart
- [ ] Session expires after 7 days of inactivity
- [ ] Remember me option for 30-day sessions
- [ ] Tests pass

## Functional Requirements

- FR-1: Hash passwords using bcrypt with cost factor 12
- FR-2: Store sessions in database with expiration timestamp
- FR-3: Set HttpOnly, Secure, SameSite=Strict on session cookies
- FR-4: Rate limit login attempts (5 per minute per IP)
- FR-5: Log authentication events for audit trail

## Non-Goals

- Social login (OAuth) - future enhancement
- Two-factor authentication - future enhancement
- Password reset via email - separate PRD
- User profile management - separate PRD

## Technical Considerations

- Use existing database connection pool
- Session table needs index on token and user_id
- Consider Redis for session storage if scale requires

## Success Criteria

- Users can register, login, and logout without errors
- Sessions persist correctly across browser restarts
- No security vulnerabilities in OWASP top 10
- All tests pass

## Open Questions

- What should session timeout be? (defaulting to 7 days)
- Should we support "remember me" from launch?

<!-- STATE
stories:
  - id: US-001
    title: "User Registration"
    passes: false
    notes: ""
  - id: US-002
    title: "User Login"
    passes: false
    notes: ""
  - id: US-003
    title: "User Logout"
    passes: false
    notes: ""
  - id: US-004
    title: "Session Persistence"
    passes: false
    notes: ""
/STATE -->
```

---

## Checklist

Before saving the PRD:

- [ ] Asked clarifying questions with numbered sub-options (1.1, 1.2, etc.)
- [ ] Incorporated user's answers
- [ ] User stories are small and specific (2-3 sentence rule)
- [ ] Each story has mandatory acceptance criteria (typecheck, tests, browser verify)
- [ ] Functional requirements are numbered and unambiguous
- [ ] Non-goals section defines clear boundaries
- [ ] Added STATE block with all stories (passes: false)
- [ ] Saved to `.planning/[task-slug]/prd.md`
- [ ] Created corresponding `task_plan.md` with phases
