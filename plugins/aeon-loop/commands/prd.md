---
name: prd
description: Generate a Product Requirements Document for planning
arguments:
  - name: feature
    description: The feature or task to create a PRD for
    required: true
---

# /prd Command

Generate a Product Requirements Document (PRD) that integrates with Aeon Loop's planning system.

## Usage

```
/prd "User authentication system"
/prd "Add dark mode toggle"
/prd "Refactor database layer"
```

## What This Does

1. **Asks clarifying questions** - 3-5 questions with lettered options (respond like "1A, 2B, 3C")
2. **Generates structured PRD** - Complete requirements document with user stories
3. **Creates planning files** - Saves to `.planning/[task-slug]/prd.md`
4. **Sets up task_plan.md** - Creates execution plan based on user stories

## After Running /prd

Once the PRD is generated, you can:

```bash
# Review and edit the PRD
cat .planning/[task-slug]/prd.md

# Start autonomous execution
/loop "[task]" --done "COMPLETE"
```

## PRD Sections Generated

- **Overview** - Problem statement and solution summary
- **Goals** - Measurable objectives
- **User Stories** - With acceptance criteria
- **Functional Requirements** - Numbered, specific requirements
- **Non-Goals** - Explicit scope boundaries
- **Technical Considerations** - Constraints and dependencies
- **Success Criteria** - Definition of done
- **Open Questions** - Items needing clarification

## Tips

- Be specific in your feature description
- Answer clarifying questions thoroughly
- Review the generated PRD before running `/loop`
- Edit `.planning/[task-slug]/task_plan.md` to adjust phases

## Integration with /loop

The PRD creates a foundation for autonomous execution:

```
/prd "Build REST API"     # Creates detailed requirements
                          # Review and approve PRD
/loop "Build REST API" --done "COMPLETE"  # Execute with guidance
```
