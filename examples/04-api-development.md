# Example: API Development

## When to Use
- Building new API endpoints
- Multiple interconnected features
- Need architecture decisions tracked

## Plan First (Essential for APIs)

```bash
# 1. Create planning structure
/start-planning "Build user management REST API"

# 2. Define detailed requirements in task_plan.md
# Edit .planning/build-user-management-rest-api/task_plan.md:
#
# ## Goal
# Build REST API for user management with JWT auth and 80% test coverage
#
# ## Phases
# - [ ] Phase 1: Project setup (Express, TypeScript, structure)
# - [ ] Phase 2: User model and database schema
# - [ ] Phase 3: CRUD endpoints (/users)
# - [ ] Phase 4: JWT authentication
# - [ ] Phase 5: Input validation and error handling
# - [ ] Phase 6: Write tests (target 80% coverage)
# - [ ] Phase 7: Final review and documentation
#
# ## Key Questions
# 1. Which JWT library? (jsonwebtoken recommended)
# 2. Access token expiry? (15 min access, 7 day refresh)
# 3. Database? (PostgreSQL or SQLite for dev)
# 4. Password hashing? (bcrypt, 10 rounds)
#
# ## Decisions Made
# - (to be filled)

# 3. Add research/references to notes.md
# Edit .planning/build-user-management-rest-api/notes.md:
#
# ## References
# - OWASP JWT Cheat Sheet
# - Express security best practices
#
# ## API Design
# POST /api/users - Create user
# GET /api/users - List users (admin)
# GET /api/users/:id - Get user
# PUT /api/users/:id - Update user
# DELETE /api/users/:id - Delete user
# POST /api/auth/login - Login
# POST /api/auth/refresh - Refresh token

# 4. Start the loop
/loop "Build user management REST API" --done "API COMPLETE"
```

## How the Plan Guides Execution

Each iteration, Claude:
1. Reads task_plan.md (via SessionStart hook)
2. Sees current phase and requirements
3. Works on next incomplete phase
4. Updates task_plan.md with:
   - Decisions made
   - Errors encountered
   - Phase completion
5. Saves notes.md with findings
6. Checkpoint saved before next iteration

## Example: task_plan.md Mid-Execution

```markdown
## Phases
- [x] Phase 1: Project setup (Express, TypeScript, structure)
- [x] Phase 2: User model and database schema
- [x] Phase 3: CRUD endpoints (/users)
- [ ] Phase 4: JWT authentication  ← CURRENT
- [ ] Phase 5: Input validation and error handling
- [ ] Phase 6: Write tests (target 80% coverage)
- [ ] Phase 7: Final review and documentation

## Decisions Made
- Using Express 4.18 + TypeScript 5.0
- PostgreSQL with Prisma ORM
- bcrypt with 10 rounds for passwords
- jsonwebtoken for JWT

## Errors Encountered
- Prisma migration failed on first attempt
  → Resolution: Added explicit id field type

## Status
**Currently in Phase 4** - Implementing JWT middleware
```

## Why Planning First Matters for APIs

1. **Architecture decisions** are documented before coding
2. **API design** is reviewed before implementation
3. **Test requirements** are clear (80% coverage)
4. **Each iteration** knows exactly what to work on
5. **Decisions persist** across iterations and sessions
