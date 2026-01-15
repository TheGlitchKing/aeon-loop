# Example: Building a New Project from Scratch

You want to build a REST API for a task management app.

## Start the Workflow

```bash
/aeon-flux
```

## Phase 0: Exploration

```
Claude: I see this is an existing project. Would you like me to explore first?

1. Yes, explore first
2. No, skip exploration
   2.1. I'm familiar with this codebase
   2.2. This is a new/empty project

You: 2.2
```

## Phase 1: Discovery

```
Claude: What would you like to build?

You: A REST API for a task management app. Users can create tasks,
     organize them into projects, and mark them complete.

Claude: Great! A task management API. Let me ask some questions:

1. What's the tech stack?
   1.1. Node.js + Express + TypeScript
   1.2. Python + FastAPI
   1.3. Go + Gin
   1.4. Other

2. What database?
   2.1. PostgreSQL
   2.2. MongoDB
   2.3. SQLite (for simplicity)
   2.4. Other

3. What authentication method?
   3.1. JWT tokens
   3.2. Session-based
   3.3. API keys
   3.4. None (public API)

4. What's the scope for v1?
   4.1. MVP - basic CRUD only
   4.2. Full featured - tags, due dates, priorities
   4.3. Production ready - full features + rate limiting, logging

You: 1.1, 2.1, 3.1, 4.2
```

```
Claude: Got it. A few more questions:

1. User management scope?
   1.1. Registration + login only
   1.2. Full profile management
   1.3. Team/organization support
   1.4. Single-user (no auth needed)

2. API documentation?
   2.1. OpenAPI/Swagger
   2.2. Simple README
   2.3. None needed

3. Testing requirements?
   3.1. Unit tests only
   3.2. Unit + integration tests
   3.3. Full coverage (unit + integration + e2e)

You: 1.1, 2.1, 3.2
```

## Phase 2: PRD Creation

```
Claude: I have enough to create the PRD. Here's what I understand:

- Node.js + Express + TypeScript REST API
- PostgreSQL database
- JWT authentication
- Full featured: tasks, projects, tags, due dates, priorities
- User registration and login
- OpenAPI documentation
- Unit and integration tests

Creating the PRD...

# PRD: Task Management REST API

## Overview
Build a REST API for task management with user authentication,
projects, tasks with metadata, and comprehensive API documentation.

## Goals
- RESTful API following best practices
- JWT-based authentication
- Full CRUD for users, projects, and tasks
- OpenAPI 3.0 documentation
- 80%+ test coverage

## User Stories

### US-001: Project Setup
As a developer, I need the project scaffolded so development can begin.

**Acceptance Criteria:**
- [ ] Express + TypeScript configured
- [ ] PostgreSQL connection working
- [ ] Project structure follows best practices
- [ ] npm scripts for dev, build, test
- [ ] Typecheck passes

### US-002: User Registration
As a new user, I want to register so I can use the API.

**Acceptance Criteria:**
- [ ] POST /api/auth/register endpoint
- [ ] Email and password validation
- [ ] Password hashed with bcrypt
- [ ] Returns user object (no password)
- [ ] Tests pass

### US-003: User Login
As a registered user, I want to log in to get an access token.

**Acceptance Criteria:**
- [ ] POST /api/auth/login endpoint
- [ ] Returns JWT access token
- [ ] Token expires in 24 hours
- [ ] Invalid credentials return 401
- [ ] Tests pass

### US-004: Create Project
As an authenticated user, I want to create projects to organize tasks.

**Acceptance Criteria:**
- [ ] POST /api/projects endpoint
- [ ] Requires authentication
- [ ] Project has name and description
- [ ] Returns created project
- [ ] Tests pass

### US-005: List Projects
As an authenticated user, I want to see my projects.

**Acceptance Criteria:**
- [ ] GET /api/projects endpoint
- [ ] Returns only user's projects
- [ ] Supports pagination
- [ ] Tests pass

### US-006: Create Task
As an authenticated user, I want to create tasks in a project.

**Acceptance Criteria:**
- [ ] POST /api/projects/:id/tasks endpoint
- [ ] Task has title, description, due_date, priority
- [ ] Priority: low, medium, high
- [ ] Returns created task
- [ ] Tests pass

### US-007: List Tasks
As an authenticated user, I want to see tasks in a project.

**Acceptance Criteria:**
- [ ] GET /api/projects/:id/tasks endpoint
- [ ] Supports filtering by status, priority
- [ ] Supports sorting by due_date, priority
- [ ] Pagination support
- [ ] Tests pass

### US-008: Update Task
As an authenticated user, I want to update task details.

**Acceptance Criteria:**
- [ ] PUT /api/tasks/:id endpoint
- [ ] Can update any field
- [ ] Returns updated task
- [ ] Tests pass

### US-009: Complete Task
As an authenticated user, I want to mark tasks complete.

**Acceptance Criteria:**
- [ ] PATCH /api/tasks/:id/complete endpoint
- [ ] Sets completed_at timestamp
- [ ] Returns updated task
- [ ] Tests pass

### US-010: Add Tags
As an authenticated user, I want to add tags to tasks.

**Acceptance Criteria:**
- [ ] POST /api/tasks/:id/tags endpoint
- [ ] Tags are strings
- [ ] Can add multiple tags
- [ ] GET tasks supports filtering by tag
- [ ] Tests pass

### US-011: OpenAPI Documentation
As an API consumer, I want documentation so I can use the API.

**Acceptance Criteria:**
- [ ] OpenAPI 3.0 spec generated
- [ ] Swagger UI available at /docs
- [ ] All endpoints documented
- [ ] Request/response schemas included

...

Does this PRD capture your vision?

You: Yes, looks great
```

## Phase 3: Planning

```
Claude: Creating the implementation plan...

## Phases

### Phase 1: Foundation
- US-001: Project Setup

### Phase 2: Authentication
- US-002: User Registration
- US-003: User Login

### Phase 3: Projects
- US-004: Create Project
- US-005: List Projects

### Phase 4: Tasks
- US-006: Create Task
- US-007: List Tasks
- US-008: Update Task
- US-009: Complete Task

### Phase 5: Features
- US-010: Add Tags

### Phase 6: Documentation
- US-011: OpenAPI Documentation

### Phase 7: Testing & Verification

Does this plan look good?

You: Yes
```

## Phase 4: Execution Mode

```
Claude: Ready to start implementation!

How would you like to proceed?

A) Set it and forget it (Recommended)
   - I'll work autonomously until complete
   - Check /status anytime

B) Be in the loop
   - I'll check in after each story

You: A
```

## Phases 5-7: Autonomous Execution

Claude works through all stories:

```
Claude: Starting autonomous execution.

You can:
- Check progress: /status
- Stop execution: /abort

I'll let you know when complete!
```

### Checking Progress

```bash
/status
```

```
=== Aeon Loop Status ===

Loop: ACTIVE
Iteration: 23 / 100
Task: task-management-rest-api

Stories: 8/11 complete
- [x] US-001: Project Setup
- [x] US-002: User Registration
- [x] US-003: User Login
- [x] US-004: Create Project
- [x] US-005: List Projects
- [x] US-006: Create Task
- [x] US-007: List Tasks
- [x] US-008: Update Task
- [ ] US-009: Complete Task (CURRENT)
- [ ] US-010: Add Tags
- [ ] US-011: OpenAPI Documentation

Phases: 4/7 complete

Abort Signal: INACTIVE
```

### Completion

```
Claude: All requirements from the original PRD have been implemented!

Summary:
- 11 stories completed
- 7 phases finished
- All tests passing (47 tests)
- 85% code coverage

Files created:
src/
├── index.ts
├── config/
│   └── database.ts
├── middleware/
│   ├── auth.ts
│   └── errorHandler.ts
├── routes/
│   ├── auth.ts
│   ├── projects.ts
│   └── tasks.ts
├── models/
│   ├── User.ts
│   ├── Project.ts
│   └── Task.ts
├── services/
│   ├── authService.ts
│   ├── projectService.ts
│   └── taskService.ts
└── __tests__/
    ├── auth.test.ts
    ├── projects.test.ts
    └── tasks.test.ts

API Documentation: http://localhost:3000/docs

Next steps:
- Run: npm run dev
- Test: npm test
- Build: npm run build
```

## Files Created

```
.planning/task-management-rest-api/
├── prd.md              # Complete PRD with all stories
├── task_plan.md        # Implementation phases
└── notes.md            # Architecture decisions, API design

.claude/memory/
├── checkpoint.md       # Final state
└── patterns.md         # Learned patterns (Express structure, etc.)
```
