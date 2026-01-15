---
name: start-planning
description: "Initialize persistent planning structure for a task. Creates .planning/[task-slug]/ with task_plan.md and notes.md. Use when you want to plan without autonomous execution."
---

# /start-planning

Initialize the persistent planning structure for a task without starting autonomous execution.

---

## Usage

```
/start-planning "Your task name here"
```

## Examples

```
/start-planning "Refactor authentication system"
/start-planning "Build REST API with JWT"
/start-planning "Fix memory leak in worker process"
```

---

## What To Do

When the user runs `/start-planning "Task Name"`:

1. Run the init script:
```bash
bash "${CLAUDE_PROJECT_DIR:-$(pwd)}/plugins/aeon-loop/scripts/init-planning.sh" "Task Name"
```

2. After the script completes, remind the user:
   - Edit `.planning/[task-slug]/task_plan.md` to define phases
   - Update the Status section as they work
   - Save findings to `.planning/[task-slug]/notes.md`
   - To start autonomous execution instead, use `/loop`

---

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

---

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
