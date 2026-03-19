#!/usr/bin/env bash
#
# update-recommended-order.sh - Manage the Recommended Order section in TODO.md
#
# Usage:
#   update-recommended-order.sh add TASK_NUM     - Insert task based on dependency position
#   update-recommended-order.sh remove TASK_NUM  - Remove task entry from section
#   update-recommended-order.sh refresh          - Regenerate entire section from state.json
#
# The Recommended Order section provides a topologically-sorted list of tasks
# based on their dependencies, with action hints derived from task status.
#
# Section format:
#   ## Recommended Order
#   1. **995** -> plan + implement (unblocks 988, 989, 997)
#   2. **996** -> research (independent)

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
TODO_FILE="${PROJECT_ROOT}/specs/TODO.md"
STATE_FILE="${PROJECT_ROOT}/specs/state.json"

# ============================================================================
# Helper Functions
# ============================================================================

# Check if TODO.md exists
check_todo_exists() {
    if [[ ! -f "$TODO_FILE" ]]; then
        echo "ERROR: TODO.md not found at $TODO_FILE" >&2
        return 1
    fi
}

# Check if state.json exists
check_state_exists() {
    if [[ ! -f "$STATE_FILE" ]]; then
        echo "ERROR: state.json not found at $STATE_FILE" >&2
        return 1
    fi
}

# Get the line number where "## Recommended Order" section starts
# Returns 0 if section doesn't exist
get_section_start() {
    local line_num
    line_num=$(grep -n "^## Recommended Order" "$TODO_FILE" 2>/dev/null | head -1 | cut -d: -f1)
    echo "${line_num:-0}"
}

# Get the line number where the next ## section starts after Recommended Order
# Returns 0 if no next section (EOF)
get_section_end() {
    local start_line="$1"
    if [[ "$start_line" -eq 0 ]]; then
        echo "0"
        return
    fi

    local next_section
    next_section=$(tail -n +"$((start_line + 1))" "$TODO_FILE" | grep -n "^## " | head -1 | cut -d: -f1)

    if [[ -n "$next_section" ]]; then
        echo "$((start_line + next_section))"
    else
        echo "0"  # EOF
    fi
}

# Derive action hint from task status
# Returns: "research", "plan", "implement", or "complete"
get_action_hint() {
    local status="$1"
    case "$status" in
        not_started|researching)
            echo "research"
            ;;
        researched|planning)
            echo "plan"
            ;;
        planned|implementing|partial)
            echo "implement"
            ;;
        completed)
            echo "complete"
            ;;
        blocked)
            echo "blocked"
            ;;
        abandoned|expanded)
            echo "skip"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# ============================================================================
# remove_from_recommended_order
# ============================================================================

remove_from_recommended_order() {
    local task_num="$1"

    check_todo_exists || return 1

    local section_start
    section_start=$(get_section_start)

    if [[ "$section_start" -eq 0 ]]; then
        # Section doesn't exist, nothing to remove
        echo "INFO: Recommended Order section not found, nothing to remove"
        return 0
    fi

    local section_end
    section_end=$(get_section_end "$section_start")

    # Check if task exists in section
    # Pattern: digits followed by . **TASK_NUM**
    if ! grep -q "^[0-9]\+\. \*\*${task_num}\*\*" "$TODO_FILE" 2>/dev/null; then
        echo "INFO: Task $task_num not found in Recommended Order section"
        return 0
    fi

    # Remove the line containing the task
    sed -i "/^[0-9]\+\. \*\*${task_num}\*\*/d" "$TODO_FILE"

    # Renumber remaining entries
    renumber_entries

    echo "Removed task $task_num from Recommended Order"
    return 0
}

# Renumber entries in the Recommended Order section (1, 2, 3, ...)
renumber_entries() {
    local section_start
    section_start=$(get_section_start)

    if [[ "$section_start" -eq 0 ]]; then
        return 0
    fi

    local section_end
    section_end=$(get_section_end "$section_start")

    # Create temp file for processing
    local tmp_file
    tmp_file=$(mktemp)

    local counter=1
    local in_section=0
    local line_num=0

    while IFS= read -r line; do
        line_num=$((line_num + 1))

        # Check if we're entering the section
        if [[ "$line_num" -eq "$section_start" ]]; then
            in_section=1
            echo "$line" >> "$tmp_file"
            continue
        fi

        # Check if we're leaving the section
        if [[ "$section_end" -ne 0 && "$line_num" -ge "$section_end" ]]; then
            in_section=0
        fi

        if [[ "$in_section" -eq 1 && "$line" =~ ^[0-9]+\.\  ]]; then
            # Renumber this entry
            local rest
            rest=$(echo "$line" | sed 's/^[0-9]\+\. //')
            echo "${counter}. ${rest}" >> "$tmp_file"
            counter=$((counter + 1))
        else
            echo "$line" >> "$tmp_file"
        fi
    done < "$TODO_FILE"

    mv "$tmp_file" "$TODO_FILE"
}

# ============================================================================
# refresh_recommended_order (placeholder - implemented in Phase 2)
# ============================================================================

refresh_recommended_order() {
    echo "ERROR: refresh_recommended_order not yet implemented"
    return 1
}

# ============================================================================
# add_to_recommended_order (placeholder - implemented in Phase 3)
# ============================================================================

add_to_recommended_order() {
    echo "ERROR: add_to_recommended_order not yet implemented"
    return 1
}

# ============================================================================
# Main Entry Point
# ============================================================================

main() {
    if [[ $# -lt 1 ]]; then
        echo "Usage: $0 {add|remove|refresh} [TASK_NUM]" >&2
        return 1
    fi

    local command="$1"
    shift

    case "$command" in
        add)
            if [[ $# -lt 1 ]]; then
                echo "Usage: $0 add TASK_NUM" >&2
                return 1
            fi
            add_to_recommended_order "$1"
            ;;
        remove)
            if [[ $# -lt 1 ]]; then
                echo "Usage: $0 remove TASK_NUM" >&2
                return 1
            fi
            remove_from_recommended_order "$1"
            ;;
        refresh)
            refresh_recommended_order
            ;;
        *)
            echo "Unknown command: $command" >&2
            echo "Usage: $0 {add|remove|refresh} [TASK_NUM]" >&2
            return 1
            ;;
    esac
}

# Only run main if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
