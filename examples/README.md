# Aeon Loop Examples

Learn how to use Aeon Loop effectively through these examples.

## The Unified Workflow

For most projects, start with:

```bash
/aeon-flux
```

This single command guides you through the entire project lifecycle:

1. **Exploration** - Understand the existing codebase (optional)
2. **Discovery** - Answer questions until requirements are clear
3. **PRD Creation** - Generate Product Requirements Document
4. **Planning** - Create implementation plan with phases
5. **Approval** - Review and approve before execution
6. **Execution** - Autonomous or collaborative mode
7. **Testing** - Comprehensive test creation and verification
8. **Verification** - Confirm all PRD requirements are met

## Examples by Use Case

| Example | Description |
|---------|-------------|
| [01-simple-feature.md](01-simple-feature.md) | Add a feature to an existing project |
| [02-bug-fix.md](02-bug-fix.md) | Fix a bug with proper testing |
| [03-new-project.md](03-new-project.md) | Build something from scratch |
| [04-individual-commands.md](04-individual-commands.md) | Using `/explore`, `/prd`, `/loop` separately |

## Quick Reference

### Start Any Project
```bash
/aeon-flux
```

### Check Progress (During Execution)
```bash
/status
```

### Stop Execution
```bash
/abort
```

### Pause and Resume
```bash
/pause
/resume
```

## Files Created

```
.planning/[task-slug]/
├── prd.md              # Product Requirements Document
├── task_plan.md        # Implementation plan with phases
└── notes.md            # Research and findings

.planning/exploration/
└── report.md           # Codebase exploration report (if explored)

.claude/
├── loop-state.md       # Loop execution state
└── memory/
    ├── checkpoint.md   # Progress snapshot
    ├── attention.md    # Critical context
    └── patterns.md     # Learned patterns
```
