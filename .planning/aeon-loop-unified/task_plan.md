# Task Plan: Aeon Loop - Unified Autonomous Agent Plugin

## Goal
Combine aeon-flux, mind-glaive, and ralph-loop into a single plugin that enables "start and walk away" autonomous task execution with full context persistence across iterations, compactions, and subagents.

## Phases
- [x] Phase 1: Architecture design and file structure
- [x] Phase 2: Orchestration design (DAG execution, worker pattern, safety limits)
- [ ] Phase 3: Core loop engine (Stop hook with re-injection)
- [ ] Phase 4: Context persistence system (shared memory files)
- [ ] Phase 5: Orchestrator implementation (chunk creation, worker spawning)
- [ ] Phase 6: Worker agent implementation (tiered context, heartbeat)
- [ ] Phase 7: Abort system (signal file pattern for all agents)
- [ ] Phase 8: Commands (/loop, /abort, /status, /pause, /resume, /retry)
- [ ] Phase 9: Safety systems (circuit breaker, cost tracking, idempotency)
- [ ] Phase 10: Testing and validation
- [ ] Phase 11: Documentation and publish

## Key Questions (Resolved)
1. ~~Should we keep backward compatibility?~~ → Clean break, new plugin name "aeon-loop"
2. ~~How do subagents discover shared memory?~~ → Hardcoded `.claude/memory/` + prompt injection
3. ~~Checkpoint frequency?~~ → Every iteration via Stop hook
4. ~~Nested subagent spawning?~~ → Flat structure, no nesting (workers don't spawn workers)
5. ~~Parallel vs sequential execution?~~ → DAG-based waves (dependency-aware parallelism)
6. ~~Worker communication?~~ → Filesystem polling + heartbeat (simple, crash-resistant)
7. ~~Context size per worker?~~ → Tiered lazy loading (Tier 1 always, Tier 2 on demand)
8. ~~Subagent limits?~~ → 3 concurrent, 50 total, circuit breaker at 5 failures

## Decisions Made
- [Filesystem as shared brain]: Subagents read/write to .claude/memory/ instead of relying on conversation context
- [Six core commands]: /loop, /abort, /status, /pause, /resume, /retry
- [Signal file abort]: Works across main agent and all subagents
- [Orchestrator-Worker pattern]: Main loop orchestrates, spawns worker subagents for chunks
- [DAG execution]: Tasks analyzed for dependencies, executed in waves
- [Safety limits]: 3 concurrent workers, 50 total, 3 retries, circuit breaker at 5 failures
- [Tiered context]: Workers get minimal context (Tier 1), load more on demand (Tier 2)
- [Heartbeat protocol]: Workers signal liveness every 30s, stale after 90s
- [Atomic file writes]: Write to .tmp then mv to prevent corruption
- [Cost tracking]: Estimate tokens, hard stop at configurable limit

## Errors Encountered
- (none yet)

## Status
**Currently in Phase 2** - Orchestration design complete, ready for Phase 3 (implementation)

## Source Plugins Analysis

### From ralph-loop
- Stop hook that blocks exit and re-injects prompt
- Completion promise detection (`<promise>TEXT</promise>`)
- Max iterations safety net
- `/ralph-loop` and `/cancel-ralph` commands
- State file: `.claude/ralph-loop.local.md`

### From aeon-flux
- PreToolUse abort signal check
- Attention markers (`<!-- ATTENTION -->`)
- Checkpoint/resume system
- Subagent definitions (executor, verifier, learner, orchestrator)
- Bash Loop philosophy (action over explanation)
- Runtime files: `.claude/memory/`

### From mind-glaive
- SessionStart context loading
- SessionEnd context capture
- PreCompact attention preservation
- Pattern learning from corrections
- Context health metrics

### From planning-with-files
- `.planning/[task]/task_plan.md` - Human-readable plan with phases
- `.planning/[task]/notes.md` - Research and findings storage
- Manus principles: filesystem as memory, attention manipulation
- `/start-planning` command with slug generation
- Multiple concurrent tasks support
- "Read before decide" pattern

## Architecture Decisions Made
1. **Dual-layer file system**: Planning layer (`.planning/`) + Runtime layer (`.claude/`)
2. **YAML frontmatter** for machine-readable files (loop-state, checkpoint)
3. **Markdown** for human-readable files (task_plan, notes)
4. **task_slug** links runtime to planning (e.g., `task_slug: "build-rest-api"` → `.planning/build-rest-api/`)

## Architecture Decisions Needed
1. Should `/loop` auto-create task_plan.md or require `/start-planning` first?
2. How verbose should iteration transitions be?
3. Should we support multiple concurrent loops?
