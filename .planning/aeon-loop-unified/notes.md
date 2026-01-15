# Notes: Aeon Loop Unified Plugin Research

## Sources

### Source 1: ralph-loop Plugin (Deep Dive)
- Location: `~/.claude/plugins/marketplaces/claude-plugins-official/plugins/ralph-loop/`
- State file: `.claude/ralph-loop.local.md` (YAML frontmatter + prompt)
- Key mechanisms:
  - **Setup**: `/ralph-loop` command writes state file with iteration=1
  - **Stop hook**: Reads state file, checks completion, outputs `{"decision":"block","reason":"prompt"}`
  - **Completion**: Detects `<promise>TEXT</promise>` in assistant output
  - **Iteration tracking**: Updates iteration count in state file each loop
  - **Max iterations**: Safety net, removes state file when reached
- Commands: `/ralph-loop`, `/cancel-ralph`, `/help`
- Philosophy: "Start and walk away" - fully autonomous until done

**Critical insight**: The Stop hook returns JSON with `decision: block` and `reason: <prompt>` to re-inject the same prompt. This is the core loop mechanism.

### Source 2: aeon-flux Plugin
- Location: `/mnt/e/docker-containers/aeon-flux/plugins/aeon-flux/`
- Key mechanisms:
  - PreToolUse hook checks abort signal before every action
  - Signal file: `/tmp/aeon-flux-abort-{hash}`
  - Attention markers survive compaction
  - Subagents: executor, verifier, learner, orchestrator
- Philosophy: "Shut up and calculate" - action over explanation

### Source 3: mind-glaive Plugin
- Location: `/mnt/e/docker-containers/mind-glaive/`
- Key mechanisms:
  - SessionStart loads context
  - SessionEnd captures focus
  - PreCompact preserves critical info
  - Pattern learning from repeated corrections
- Philosophy: Intelligent memory management

### Source 4: planning-with-files Skill
- Location: `~/.claude/skills/planning-with-files/`
- Key mechanisms:
  - `.planning/[task-slug]/` directory per task
  - `task_plan.md` with Goal, Phases, Decisions, Errors, Status
  - `notes.md` for research and findings
  - `init-planning.sh` script for setup
  - Task name → slug conversion (spaces/special chars → hyphens)
- Philosophy: Manus-style "filesystem as external memory"
- Key principles:
  1. **Filesystem as External Memory** - Store large content in files, keep only paths in context
  2. **Attention Manipulation** - Re-read task_plan.md to keep goals in attention window
  3. **Keep Failure Traces** - Log errors, don't hide and retry
  4. **Avoid Few-Shot Overfitting** - Vary phrasings to prevent drift
  5. **Stable Prefixes** - Structure for cache hits
  6. **Append-Only Context** - Never modify previous messages

## Synthesized Findings

### Hook Consolidation
| Hook | ralph-loop | aeon-flux | mind-glaive | planning-with-files | Unified |
|------|-----------|-----------|-------------|---------------------|---------|
| SessionStart | - | Load checkpoint | Load context | - | Load all memory + read task_plan.md |
| PreToolUse | - | Abort check | - | - | Abort check |
| PreCompact | - | Save attention | Preserve critical | - | Save attention + checkpoint |
| PostToolUse[Bash] | - | Capture errors | - | - | Capture errors → patterns |
| PostToolUse[Edit] | - | Auto-verify | - | - | Auto-verify |
| Stop | Re-inject prompt | Quality gate | Capture focus | - | Re-inject OR complete |

### Dual-Layer Integration
```
PLANNING LAYER (.planning/)          RUNTIME LAYER (.claude/)
┌─────────────────────────┐          ┌─────────────────────────┐
│ task_plan.md            │◄────────►│ loop-state.md           │
│ - Goal                  │  linked  │ - task_slug             │
│ - Phases                │  via     │ - iteration             │
│ - Decisions             │  slug    │ - completion_promise    │
│ - Errors                │          │                         │
│ - Status                │          │ checkpoint.md           │
│                         │          │ - progress snapshot     │
│ notes.md                │          │                         │
│ - Research              │          │ attention.md            │
│ - Findings              │          │ - survives compaction   │
│                         │          │                         │
│                         │          │ patterns.md             │
│                         │          │ - learned from errors   │
│                         │          │                         │
│                         │          │ errors.md               │
│                         │          │ - raw error log         │
└─────────────────────────┘          └─────────────────────────┘
   Human-readable                       Machine-readable
   Updated by Claude                    Updated by hooks
   Persists across sessions             Enables autonomous loop
```

### Memory File Structure
```
.claude/memory/
├── loop-state.md      # Current loop iteration, prompt, settings
├── checkpoint.md      # Task state (what's done, what's next)
├── attention.md       # Critical info for compaction survival
├── patterns.md        # Learned corrections
├── progress.md        # Human-readable progress report
└── errors.md          # Error log for debugging
```

### Subagent Context Protocol
Problem: Subagents start with empty context.
Solution: Inject filesystem reads into agent prompts.

```markdown
# Agent: executor

## Before Starting
Read these files for context:
- .claude/memory/checkpoint.md (current state)
- .claude/memory/attention.md (critical info)

## After Completing
Append results to:
- .claude/memory/progress.md
```

### Abort Signal Flow
```
User presses Ctrl+C or runs /abort
         │
         ▼
Creates /tmp/aeon-loop-abort-{hash}
         │
         ├──▶ Main agent: PreToolUse blocks next action
         │
         ├──▶ Subagent 1: PreToolUse blocks next action
         │
         └──▶ Subagent N: PreToolUse blocks next action

All agents stop at next tool boundary.
```

### Loop State Machine
```
IDLE ──/loop──▶ RUNNING ──promise──▶ COMPLETE
                  │                      │
                  │ max_iter             │
                  ▼                      │
               TIMEOUT ◀─────────────────┘
                  │
              /abort
                  │
                  ▼
              ABORTED
```

## Open Questions

### Q1: Backward Compatibility
Options:
a) Break compatibility, new plugin name "aeon-loop"
b) Keep aeon-flux name, major version bump
c) Provide migration script

Recommendation: Option (a) - clean break, new name

### Q2: Subagent Memory Discovery
Options:
a) Hardcode `.claude/memory/` path
b) Use environment variable `$AEON_MEMORY_DIR`
c) Pass via agent prompt injection

Recommendation: Option (a) with (c) as reinforcement

### Q3: Checkpoint Frequency
Options:
a) Every iteration (safe but slow)
b) On-demand via /checkpoint (fast but risky)
c) Every N iterations (balanced)
d) On significant state change (smart)

Recommendation: Option (d) with (a) as fallback

### Q4: Nested Subagents
Problem: Orchestrator spawns executor, which spawns verifier.
How do we track this tree?

Options:
a) Flat - all subagents equal, no nesting
b) Tree - track parent-child in memory file
c) Limited depth - max 2 levels

Recommendation: Option (a) for simplicity

## Implementation Priority
1. Stop hook (core loop mechanism)
2. Memory file system (persistence)
3. Abort signal (safety)
4. Subagent coordination (power)
5. Progress reporting (visibility)
