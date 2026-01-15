---
name: explore
description: "Explore and analyze the current codebase using parallel subagents. Generates a comprehensive report of project structure, patterns, architecture, and dependencies."
---

# /explore - Codebase Exploration

Spin up parallel subagents to thoroughly explore the current project and generate a comprehensive understanding.

---

## When To Use

- Starting work on an unfamiliar codebase
- Before creating a PRD for a new feature
- Understanding how existing features work
- Auditing dependencies or security
- Onboarding to a project

---

## Usage

```
/explore
```

Or with a specific focus:

```
/explore "authentication system"
/explore "API endpoints"
/explore "database models"
```

---

## Exploration Modes

When the user runs `/explore`, ask what they want to explore:

```
What would you like to explore?

1. Full codebase overview
   1.1. Complete analysis (structure, patterns, architecture, dependencies)
   1.2. Quick overview (just structure and key files)

2. Specific focus area
   2.1. How does [feature] work?
   2.2. Where is [functionality] implemented?
   2.3. What calls/uses [component]?

3. Technical audit
   3.1. Dependencies and versions
   3.2. Security patterns
   3.3. Test coverage
   3.4. Code quality patterns
```

---

## Phase 1: Launch Parallel Exploration Agents

For a full codebase overview, launch these agents **in parallel**:

### Agent 1: Structure Explorer
```
Explore the project structure:
- Directory layout and organization
- Key directories and their purposes
- Entry points (main files, index files)
- Configuration files
- Build/deploy files

Output a structured summary of the project layout.
```

### Agent 2: Pattern Explorer
```
Identify coding patterns in this codebase:
- Naming conventions (files, functions, variables)
- Code organization patterns (MVC, services, etc.)
- Error handling patterns
- Logging patterns
- Common utilities and helpers

Output the key patterns a developer should follow.
```

### Agent 3: Dependency Explorer
```
Analyze project dependencies:
- Package manager (npm, pip, cargo, etc.)
- Key dependencies and their purposes
- Dev dependencies
- Dependency versions (any outdated?)
- Internal module dependencies

Output a dependency overview.
```

### Agent 4: Architecture Explorer
```
Understand the architecture:
- Application type (web app, API, CLI, library, etc.)
- Tech stack (languages, frameworks, databases)
- Data flow (how data moves through the system)
- External integrations (APIs, services)
- Key abstractions and interfaces

Output an architecture summary.
```

### Launching Agents

Use the Task tool with `subagent_type: "Explore"` for each:

```
Launch all 4 agents in parallel using a single message with multiple Task tool calls.

Each agent should:
- Focus on its specific area
- Be thorough but concise
- Output findings in markdown format
- Complete within one context window
```

---

## Phase 2: Aggregate Results

After all agents complete, combine their findings into a single report:

### Report Structure

```markdown
# Codebase Exploration Report

**Project:** [detected project name]
**Generated:** [timestamp]
**Explored by:** Aeon Loop /explore

---

## Overview

[One paragraph summary of what this project is]

---

## Project Structure

[Output from Structure Explorer]

### Key Directories
| Directory | Purpose |
|-----------|---------|
| src/ | ... |
| ... | ... |

### Entry Points
- ...

---

## Architecture

[Output from Architecture Explorer]

### Tech Stack
- **Language:** ...
- **Framework:** ...
- **Database:** ...

### Data Flow
[Diagram or description]

---

## Patterns & Conventions

[Output from Pattern Explorer]

### Naming Conventions
- Files: ...
- Functions: ...
- Variables: ...

### Code Patterns
- ...

---

## Dependencies

[Output from Dependency Explorer]

### Key Dependencies
| Package | Version | Purpose |
|---------|---------|---------|
| ... | ... | ... |

### Potential Issues
- [outdated deps, security concerns, etc.]

---

## Key Files Reference

| File | Purpose |
|------|---------|
| ... | ... |

---

## Recommendations

[Based on exploration, any suggestions for the user]

---

## Next Steps

- To build a new feature: `/aeon-flux`
- To create just a PRD: `/prd`
- To start autonomous work: `/loop "task" --done "COMPLETE"`
```

---

## Phase 3: Save Report

Save the aggregated report:

```bash
mkdir -p .planning/exploration
```

Save to `.planning/exploration/report.md`

If exploring a specific area, save to `.planning/exploration/[area-slug].md`

---

## Focused Exploration

When user wants to explore something specific:

### "How does X work?"

Launch a single focused agent:

```
Trace how [X] works in this codebase:
1. Find the entry point for [X]
2. Follow the code path
3. Identify key functions/methods involved
4. Note any external dependencies
5. Document the flow

Output a clear explanation with file:line references.
```

### "Where is X implemented?"

```
Find where [X] is implemented:
1. Search for relevant files
2. Identify the main implementation
3. Find related files (tests, types, etc.)
4. Note any configuration

Output file paths with brief descriptions.
```

### "What calls/uses X?"

```
Find all usages of [X]:
1. Search for imports/requires
2. Find function calls
3. Identify dependent code
4. Map the dependency graph

Output a list of files and how they use [X].
```

---

## Example Session

```
User: /explore

Claude: What would you like to explore?

1. Full codebase overview
   1.1. Complete analysis
   1.2. Quick overview

2. Specific focus area
   2.1. How does [feature] work?
   2.2. Where is [functionality] implemented?

3. Technical audit
   3.1. Dependencies
   3.2. Security patterns

User: 1.1

Claude: Launching exploration agents...

[Launches 4 parallel agents]

Agent 1 (Structure): Exploring project structure...
Agent 2 (Patterns): Identifying coding patterns...
Agent 3 (Dependencies): Analyzing dependencies...
Agent 4 (Architecture): Understanding architecture...

[Agents complete]

Claude: Here's what I found:

# Codebase Exploration Report
[Full report]

Saved to .planning/exploration/report.md

Would you like to:
- Dive deeper into any area?
- Start building with /aeon-flux?
- Create a PRD for a feature?
```

---

## Integration with Aeon Flux

When `/aeon-flux` offers exploration first, it should:

1. Ask: "Would you like me to explore the codebase first?"
2. If yes: Run `/explore` with quick overview (1.2)
3. Use findings to inform PRD questions
4. Reference exploration report in planning

The exploration report becomes context for better PRD creation.

---

## Output Files

```
.planning/
└── exploration/
    ├── report.md           # Full codebase report
    ├── auth-system.md      # Focused exploration
    └── api-endpoints.md    # Focused exploration
```

---

## Checklist

Before completing exploration:

- [ ] Launched appropriate agents (parallel for full, single for focused)
- [ ] Aggregated all agent outputs
- [ ] Generated structured report
- [ ] Saved to .planning/exploration/
- [ ] Offered next steps to user
