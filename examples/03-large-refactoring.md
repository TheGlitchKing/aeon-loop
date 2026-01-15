# Example: Large Refactoring Task

## When to Use
- Many files to modify
- Repetitive transformations
- Need parallel execution for speed

## Plan First (Highly Recommended)

For large tasks, always plan first to customize the scope:

```bash
# 1. Create planning structure
/start-planning "Migrate class components to hooks"

# 2. Customize task_plan.md with specific scope
# Edit .planning/migrate-class-components-to-hooks/task_plan.md:
#
# ## Goal
# Migrate all class components in src/components/ to functional components
#
# ## Phases
# - [ ] Phase 1: Inventory all class components
# - [ ] Phase 2: Migrate simple components (no state)
# - [ ] Phase 3: Migrate stateful components
# - [ ] Phase 4: Migrate components with lifecycle methods
# - [ ] Phase 5: Update tests
# - [ ] Phase 6: Final verification
#
# ## Key Questions
# 1. How many components total?
# 2. Which have complex lifecycle methods?
# 3. Test coverage requirements?
#
# ## Decisions Made
# - Migrate in order of complexity (simple first)
# - Keep same file names

# 3. Add research notes
# Edit .planning/migrate-class-components-to-hooks/notes.md:
#
# ## Component Inventory
# - SimpleButton.tsx (stateless)
# - UserCard.tsx (stateless)
# - LoginForm.tsx (useState, useEffect)
# - Dashboard.tsx (complex lifecycle)
# ...

# 4. Start the loop
/loop "Migrate class components to hooks" --done "MIGRATION COMPLETE" --max-iters 50
```

## What Happens with Orchestration

1. **Orchestrator** reads task_plan.md
2. Breaks task into chunks (one component per chunk)
3. Spawns workers (up to 3 concurrent)
4. Each worker:
   - Reads attention.md for context
   - Migrates one component + its tests
   - Updates progress
5. Orchestrator tracks completion
6. Outputs `<promise>MIGRATION COMPLETE</promise>` when all done

## Checking Progress Mid-Loop

```bash
/status
```

Shows:
- Current iteration
- Chunks completed vs total
- Any failures
- Worker status

## Files Structure During Execution

```
.planning/migrate-class-components-to-hooks/
├── task_plan.md    # Updated as phases complete
└── notes.md        # Component inventory, findings

.claude/
├── loop-state.md   # Iteration: 15, active: true
├── orchestration/
│   ├── manifest.md # DAG, chunk status, cost tracking
│   ├── chunks/
│   │   ├── chunk-001.md  # SimpleButton migration
│   │   ├── chunk-002.md  # UserCard migration
│   │   └── ...
│   └── heartbeats/
│       └── worker-*.txt  # Liveness signals
└── memory/
    ├── checkpoint.md   # Progress snapshot
    ├── attention.md    # Critical context for workers
    ├── patterns.md     # Learned patterns (e.g., hook conversion rules)
    └── errors.md       # Error log
```

## Why Higher --max-iters?

Large refactoring needs more iterations:
- Each component may take 1-2 iterations
- Tests take additional iterations
- Default 100 is usually enough, but 50 explicit is safer for estimation
