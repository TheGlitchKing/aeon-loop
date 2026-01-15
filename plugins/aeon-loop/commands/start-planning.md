---
name: start-planning
description: Initialize persistent planning structure for a task. Creates .planning/[task-slug]/ with task_plan.md and notes.md templates.
arguments:
  - name: task_name
    description: Name of the task to create planning structure for
    required: true
---

# /start-planning

Initialize the Manus-style persistent planning structure for a task.

## Usage

```
/start-planning "Your task name here"
```

## Examples

```bash
/start-planning "Refactor authentication system"
/start-planning "Build REST API with JWT"
/start-planning "Fix memory leak in worker process"
```

## What It Creates

```
.planning/
└── [task-slug]/
    ├── task_plan.md    # Track phases and progress
    └── notes.md        # Store research and findings
```

## Task Slug Conversion

Task names are converted to URL-friendly slugs:
- "Refactor Authentication" → `refactor-authentication`
- "Build REST API" → `build-rest-api`
- "Fix Bug #123" → `fix-bug-123`

## Multiple Concurrent Tasks

You can have multiple tasks without conflicts:

```bash
/start-planning "Refactor auth"
# Creates .planning/refactor-auth/

/start-planning "Add dark mode"
# Creates .planning/add-dark-mode/

# Both coexist independently!
```

## Difference from /loop

| Command | Purpose |
|---------|---------|
| `/start-planning` | Create planning structure only (manual work) |
| `/loop` | Create planning + start autonomous execution |

Use `/start-planning` when you want to:
- Plan without autonomous execution
- Set up structure before a loop
- Work manually with persistent plans

Use `/loop` when you want:
- Autonomous execution
- "Start and walk away" behavior
- Full loop iteration system

## Implementation

When you run `/start-planning "Task Name"`:

1. Run the init script to create the structure:
```bash
bash "${CLAUDE_PROJECT_DIR}/.claude/plugins/aeon-loop/scripts/init-planning.sh" "Task Name"
```

2. The script creates:
   - `.planning/` directory (if needed)
   - `.planning/[task-slug]/` directory
   - `task_plan.md` with template
   - `notes.md` with template
   - Adds `.planning/` to `.gitignore` (if exists)

3. Start working on your task using the planning files

## After Running

1. Edit `.planning/[task-slug]/task_plan.md` to define your phases
2. Update the Status section as you work
3. Save findings to `.planning/[task-slug]/notes.md`
4. Re-read `task_plan.md` before major decisions

## Cleanup

When task is complete:
```bash
rm -rf .planning/[task-slug]/
```

Or clean all planning files:
```bash
rm -rf .planning/
```
