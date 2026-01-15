---
name: loop
description: Start autonomous task execution loop. Works until completion promise is output or max iterations reached.
argument-hint: "TASK [--done TEXT] [--max-iters N] [--workers N]"
allowed-tools: ["Bash(${CLAUDE_PLUGIN_ROOT}/scripts/setup-loop.sh:*)"]
---

# Loop Command

Start an autonomous execution loop that continues until:
1. You output the completion promise: `<promise>TEXT</promise>`
2. Maximum iterations reached
3. User runs `/abort`

## Usage

```
/loop "Your task description" --done "COMPLETE" [options]
```

## Options

| Option | Default | Description |
|--------|---------|-------------|
| `--done <text>` | (none) | Completion promise phrase |
| `--max-iters <n>` | 100 | Maximum iterations |
| `--workers <n>` | 3 | Max concurrent workers (capped at 3) |
| `--chunk-size <n>` | 5 | Tasks per chunk |
| `--cost-limit <n>` | 10 | Max USD to spend |

## Examples

```bash
/loop Build a REST API with JWT auth and tests --done "COMPLETE"
/loop Fix all failing tests in src/ --done "ALL TESTS PASS" --max-iters 20
/loop Refactor authentication module --done "DONE" --workers 2
```

## Execution

Run the setup script to initialize loop state:

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/setup-loop.sh" $ARGUMENTS
```

## What Happens

1. Creates `.claude/loop-state.md` with iteration tracking
2. Creates `.planning/[task-slug]/task_plan.md` with phases
3. Creates `.claude/memory/` files for context persistence
4. Stop hook will block exit and re-inject your prompt each iteration
5. Context is preserved across iterations via checkpoint files

## During the Loop

- Work on the task iteratively
- Update `.planning/[task-slug]/task_plan.md` as you complete phases
- Your progress is automatically checkpointed
- Errors are captured to `.claude/memory/errors.md`
- Patterns are learned in `.claude/memory/patterns.md`

## Completion

When the task is truly complete, output:

```
<promise>YOUR_COMPLETION_TEXT</promise>
```

**CRITICAL**: Only output the promise when the statement is completely TRUE.
Do NOT lie to exit the loop.

## Monitoring

- `/status` - Check current progress
- `/pause` - Pause after current iteration
- `/abort` - Stop immediately
