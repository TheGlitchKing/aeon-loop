#!/bin/bash

###############################################################################
# init-planning.sh
#
# Initialize persistent planning structure for a specific task
# Part of the aeon-loop plugin (persistent planning)
#
# Usage:
#   bash scripts/init-planning.sh "Task name"
#   bash scripts/init-planning.sh "Refactor authentication system"
#
# What it does:
#   1. Creates .planning/[task-slug]/ directory
#   2. Creates task_plan.md with templates
#   3. Creates notes.md with templates
#   4. Adds .planning/ to .gitignore (optional)
#   5. Shows other active tasks if any
###############################################################################

set -e

# Validate that task name was provided
if [ -z "$1" ]; then
    echo "Error: Task name required"
    echo ""
    echo "Usage: bash scripts/init-planning.sh \"Your Task Name\""
    echo ""
    echo "Examples:"
    echo "  bash scripts/init-planning.sh \"Refactor authentication\""
    echo "  bash scripts/init-planning.sh \"Build REST API\""
    exit 1
fi

TASK_NAME="$1"

# Function to convert task name to slug
task_name_to_slug() {
    local name="$1"
    # Convert to lowercase
    name=$(echo "$name" | tr '[:upper:]' '[:lower:]')
    # Replace spaces and underscores with hyphens
    name=$(echo "$name" | sed 's/[[:space:]_]\+/-/g')
    # Remove special characters, keep only alphanumeric and hyphens
    name=$(echo "$name" | sed 's/[^a-z0-9-]//g')
    # Remove leading/trailing hyphens
    name=$(echo "$name" | sed 's/^-\+\|-\+$//g')
    # Replace multiple consecutive hyphens with single hyphen
    name=$(echo "$name" | sed 's/-\+/-/g')
    echo "$name"
}

TASK_SLUG=$(task_name_to_slug "$TASK_NAME")

# Validate slug
if [ -z "$TASK_SLUG" ]; then
    echo "Error: Task name must contain at least one alphanumeric character"
    echo "Provided: $TASK_NAME"
    exit 1
fi

# Determine project root
PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
PLANNING_DIR="${PROJECT_ROOT}/.planning"
TASK_DIR="${PLANNING_DIR}/${TASK_SLUG}"

echo "Initializing Planning Structure"
echo ""

# Step 1: Create .planning directory
if [ ! -d "$PLANNING_DIR" ]; then
    mkdir -p "$PLANNING_DIR"
    echo "[+] Created .planning/ directory"
else
    echo "[=] .planning/ directory exists"
fi

# Step 2: Create task directory
if [ ! -d "$TASK_DIR" ]; then
    mkdir -p "$TASK_DIR"
    echo "[+] Created task directory: .planning/${TASK_SLUG}/"
else
    echo "[=] Task directory already exists: .planning/${TASK_SLUG}/"
fi

# Step 3: Create task_plan.md
TASK_PLAN_FILE="${TASK_DIR}/task_plan.md"
if [ ! -f "$TASK_PLAN_FILE" ]; then
    cat > "$TASK_PLAN_FILE" << PLANEOF
# Task Plan: ${TASK_NAME}

## Goal
[One sentence describing the end state]

## Phases
- [ ] Phase 1: Plan and setup
- [ ] Phase 2: Research/gather information
- [ ] Phase 3: Execute/build
- [ ] Phase 4: Review and deliver

## Key Questions
1. [Question to answer]
2. [Question to answer]

## Decisions Made
- [Decision]: [Rationale]

## Errors Encountered
- [Error]: [Resolution]

## Status
**Currently in Phase 1** - Setting up planning structure

---

## Notes
- This file persists across sessions
- Update status after each phase
- Mark completed phases with [x]
- Save research to notes.md instead of stuffing context
PLANEOF
    echo "[+] Created task_plan.md"
else
    echo "[=] task_plan.md already exists"
fi

# Step 4: Create notes.md
NOTES_FILE="${TASK_DIR}/notes.md"
if [ ! -f "$NOTES_FILE" ]; then
    cat > "$NOTES_FILE" << NOTESEOF
# Notes: ${TASK_NAME}

## Key Findings
- [Finding 1]
- [Finding 2]

## Research Sources
- [Source 1]: [URL or reference]
- [Source 2]: [URL or reference]

## Synthesized Findings

### [Category/Topic 1]
- [Finding]
- [Finding]

### [Category/Topic 2]
- [Finding]
- [Finding]

## Decisions Made
- [Decision]: [Rationale]

## Errors & Solutions
- [Error]: [Resolution]

---

## Append-Only Log
Store findings here as you discover them.

### $(date +%Y-%m-%d)
- Planning structure initialized
NOTESEOF
    echo "[+] Created notes.md"
else
    echo "[=] notes.md already exists"
fi

# Step 5: Update .gitignore
if [ -f "${PROJECT_ROOT}/.gitignore" ]; then
    if ! grep -q "^\.planning/" "${PROJECT_ROOT}/.gitignore" 2>/dev/null; then
        echo ".planning/" >> "${PROJECT_ROOT}/.gitignore"
        echo "[+] Added .planning/ to .gitignore"
    else
        echo "[=] .planning/ already in .gitignore"
    fi
else
    echo "[=] No .gitignore found (skipped)"
fi

# Step 6: List other active tasks
OTHER_TASKS=$(find "$PLANNING_DIR" -maxdepth 1 -type d ! -name ".planning" ! -path "$TASK_DIR" 2>/dev/null | wc -l)
if [ "$OTHER_TASKS" -gt 0 ]; then
    echo ""
    echo "Other active tasks:"
    find "$PLANNING_DIR" -maxdepth 1 -type d ! -name ".planning" ! -path "$TASK_DIR" 2>/dev/null | sort | while read dir; do
        echo "  - .planning/$(basename "$dir")/"
    done
fi

# Step 7: Summary
echo ""
echo "====================================="
echo "Planning Structure Ready!"
echo "====================================="
echo ""
echo "Task: ${TASK_NAME}"
echo "Location: .planning/${TASK_SLUG}/"
echo ""
echo "Files:"
echo "  - task_plan.md (your task plan)"
echo "  - notes.md (research & findings)"
echo ""
echo "Next steps:"
echo "  1. Edit .planning/${TASK_SLUG}/task_plan.md to define phases"
echo "  2. Update Status section as you work"
echo "  3. Save findings to notes.md"
echo "  4. Re-read task_plan.md before major decisions"
echo ""
echo "To start autonomous loop instead:"
echo "  /loop \"${TASK_NAME}\" --done \"COMPLETE\""
echo ""
