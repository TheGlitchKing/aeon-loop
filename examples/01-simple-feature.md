# Example: Adding a Feature to an Existing Project

You have an existing React app and want to add a dark mode toggle.

## Start the Workflow

```bash
/aeon-flux
```

## Phase 0: Exploration

```
Claude: I see this is an existing project. Would you like me to explore the codebase first?

1. Yes, explore first
   1.1. Full analysis (structure, patterns, architecture)
   1.2. Quick overview (just structure and key files)

2. No, skip exploration
   2.1. I'm familiar with this codebase
   2.2. This is a new/empty project

You: 1.2
```

Claude launches exploration agents and generates a report.

```
Claude: Here's what I found:

- React 18 app with TypeScript
- Uses Tailwind CSS for styling
- State management via React Context
- Components in src/components/

Full report saved to .planning/exploration/report.md

Now let's discuss what you want to build...
```

## Phase 1: Discovery

```
Claude: What would you like to build?

You: I want to add a dark mode toggle to the app

Claude: Great! Let me ask a few questions:

1. Where should the toggle be placed?
   1.1. Header/navbar
   1.2. Settings page
   1.3. Floating button
   1.4. Other

2. How should the preference be stored?
   2.1. localStorage (persists across sessions)
   2.2. User account (requires backend)
   2.3. Session only (resets on reload)

3. What's the scope?
   3.1. Just the toggle + theme switching
   3.2. Full theme system with multiple themes
   3.3. System preference detection + manual override

You: 1.1, 2.1, 3.3
```

## Phase 2: PRD Creation

```
Claude: Creating the PRD...

# PRD: Dark Mode Toggle

## Overview
Add a dark mode toggle to the header that respects system preferences
and persists user choice in localStorage.

## User Stories

### US-001: System Preference Detection
As a user, I want the app to detect my system preference so that
dark mode is automatically enabled if my OS is in dark mode.

**Acceptance Criteria:**
- [ ] Detect prefers-color-scheme media query
- [ ] Apply correct theme on initial load
- [ ] Tests pass

### US-002: Manual Toggle
As a user, I want to toggle dark mode manually so that I can
override the system preference.

**Acceptance Criteria:**
- [ ] Toggle button visible in header
- [ ] Clicking toggles between light/dark
- [ ] Theme changes immediately
- [ ] Tests pass

### US-003: Preference Persistence
As a user, I want my preference saved so that it persists
across browser sessions.

**Acceptance Criteria:**
- [ ] Save preference to localStorage
- [ ] Load preference on app start
- [ ] Manual choice overrides system preference
- [ ] Tests pass

...

Does this capture what you want to build?

You: Yes
```

## Phase 3: Planning

```
Claude: Creating the implementation plan...

## Phases
1. Theme Context Setup - US-001
2. Toggle Component - US-002
3. Persistence Layer - US-003
4. Testing & Verification

Here's the plan. Ready to start?

You: Yes
```

## Phase 4: Execution Mode

```
Claude: How would you like to proceed?

A) Set it and forget it (Recommended)
   - I'll work autonomously until complete
   - Check /status anytime

B) Be in the loop
   - I'll check in after each story
   - More collaborative but slower

You: A
```

## Phase 5-7: Implementation, Testing, Verification

Claude works autonomously:
- Implements each user story
- Updates STATE blocks as stories complete
- Creates tests for new functionality
- Runs test suite
- Verifies all PRD requirements met

```
Claude: All requirements from the original PRD have been implemented!

Summary:
- 3 stories completed
- 4 phases finished
- All tests passing

Files created:
- src/contexts/ThemeContext.tsx
- src/components/ThemeToggle.tsx
- src/hooks/useTheme.ts
- src/__tests__/theme.test.tsx

The dark mode toggle is ready!
```

## Checking Progress Mid-Execution

At any point during autonomous execution:

```bash
/status
```

Shows:
```
=== Aeon Loop Status ===

Loop: ACTIVE
Iteration: 5 / 100
Task: dark-mode-toggle

Stories: 2/3 complete
- [x] US-001: System Preference Detection
- [x] US-002: Manual Toggle
- [ ] US-003: Preference Persistence (CURRENT)

Abort Signal: INACTIVE
```

## Files Created

```
.planning/dark-mode-toggle/
├── prd.md              # Full PRD with STATE block
├── task_plan.md        # Implementation phases
└── notes.md            # Research findings

.planning/exploration/
└── report.md           # Codebase analysis
```
