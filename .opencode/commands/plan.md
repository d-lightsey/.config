---
description: Create a phased implementation plan for a task
---

Create an implementation plan for the given task. Do NOT implement anything.

**Input**: $ARGUMENTS

---

## Parse Input

- First token: task number — accepts `OC_N` or `N` (strip `OC_` prefix to get integer N)
- Remaining tokens: optional notes/constraints
- If invalid: "Usage: /plan <OC_N> [notes]"

---

## Steps

### 1. Look up task

Strip `OC_` prefix, find task in `specs/state.json`:
```bash
jq --arg n "N" '.active_projects[] | select(.project_number == ($n | tonumber))' specs/state.json
```
If not found: "Task OC_N not found in state.json"

Extract: `language`, `status`, `project_name`, `description`

Zero-pad N to 3 digits: `NNN` (e.g. `printf "%03d" N`)

Directory: `specs/OC_NNN_<project_name>/`

### 2. Validate status

- `researched`, `not_started`, `partial`: proceed
- `planning`: warn "already planning, proceeding"
- `abandoned`: error "task is abandoned, use /task --recover first"
- `completed`: warn "already completed, re-planning"

### 3. Display task header

The skill displays a visual header during its Preflight stage to show the active task:

```
╔══════════════════════════════════════════════════════════╗
║  Task OC_N: <project_name>                               ║
║  Action: PLANNING                                         ║
╚══════════════════════════════════════════════════════════╝
```

This header appears at the start of the plan command (after validation, before delegation) to clearly indicate which task is being planned. The header is displayed by the skill-planner before invoking the planner-agent subagent.

### 4. Update status to PLANNING

Edit `specs/state.json`: set `status` to `"planning"`, update `last_updated`.

Edit `specs/TODO.md`: change current status marker to `[PLANNING]` on the `### OC_N.` entry.

### 5. Read existing research

Check for `specs/OC_NNN_<project_name>/reports/research-001.md`. If it exists, read it for context. If not, plan from the task description alone.

### 6. Create implementation plan

Decompose the task into phases. Each phase should be independently completable (2-4 hours of work). Use the task description, research findings, and any notes from $ARGUMENTS.

**CRITICAL**: Do NOT use embedded templates in this command specification. 
All plan format specifications must come from context-injected files only.

Create directory: `mkdir -p specs/OC_NNN_<project_name>/plans/`

Write the plan file by delegating to planner-agent with injected context:

**Delegate to planner-agent** with prompt:
```
Create implementation plan for task {N}.

<system_context>
Using the following format standards and guidelines:
{plan_format}
{status_markers}
{task_breakdown}
</system_context>

IMPORTANT: Use ONLY the injected plan-format.md context. 
Do NOT reference any embedded templates from command specifications.
If plan_format is not available, load @.opencode/context/core/formats/plan-format.md directly.
```

**Where**: {plan_format}, {status_markers}, {task_breakdown} are injected via skill-planner context.

**Output file**: `specs/OC_NNN_<project_name>/plans/implementation-001.md`

**Format Reference**: All plan files must follow `.opencode/context/core/formats/plan-format.md` exactly.
Key requirements:
- Metadata block with Task, Status, Effort, Dependencies, Research Inputs, Artifacts, Standards, Type
- Section named "## Implementation Phases" (not "## Phases")
- Phase format: "### Phase N: Name [STATUS]" (status IN heading, not separate line)
- Phase fields: **Goal**, **Tasks**, **Timing** (not Objectives, Estimated effort)
- No `---` separators between phases
- Required sections: Goals & Non-Goals, Risks & Mitigations, Testing & Validation, Artifacts & Outputs, Rollback/Contingency

### 7. Update status to PLANNED

Edit `specs/state.json`:
- Set `status` to `"planned"`
- Update `last_updated`
- Add to `artifacts` array:
```json
{
  "type": "plan",
  "path": "specs/OC_NNN_<project_name>/plans/implementation-001.md",
  "summary": "<one sentence>"
}
```

Edit `specs/TODO.md` on the `### OC_N.` entry:
- Change `[PLANNING]` to `[PLANNED]`
- Add line: `- **Plan**: [implementation-001.md](OC_NNN_<project_name>/plans/implementation-001.md)`

### 8. Commit changes

Create a targeted commit with only the changed files:

```bash
# Generate session ID
session_id="sess_$(date +%s)_$(od -An -N3 -tx1 /dev/urandom | tr -d ' ')"

# Get list of changed files
git status --porcelain | awk '{print $NF}' > /tmp/changed_files_$$.txt
changed_files=$(cat /tmp/changed_files_$$.txt | tr '\n' ' ')

# Commit if there are changes
if [ -n "$changed_files" ]; then
    git add $changed_files
    git commit -m "task OC_${N}: create implementation plan

Session: ${session_id}

Co-Authored-By: OpenCode <noreply@opencode.ai>" || echo "Warning: Commit failed but plan created"
fi

# Cleanup
rm -f /tmp/changed_files_$$.txt
```

**Files committed**:
- `specs/OC_NNN_<project_name>/plans/implementation-001.md` - Plan file
- `specs/state.json` - Status and artifact updates
- `specs/TODO.md` - Status marker and plan link

**Error handling**: Commit failures are non-blocking. Log a warning and continue.

### 9. Report to user

Show:
- Plan path
- Number of phases and estimated total effort
- Next step: `/implement OC_N`

---

## Rules

- Write the plan file BEFORE updating status to PLANNED
- Phases should be granular enough to be resumable if interrupted
- Directories use 3-digit padded number: `OC_174_slug` not `OC_17_slug`
- If plan already exists, create `implementation-002.md` (increment version)
- Commit changes after creating plan (non-blocking — log warning if commit fails)
- **NEVER use embedded plan templates** - always delegate to planner-agent with injected plan-format.md context
- **NO EMBEDDED TEMPLATES**: Do not include example plan structures in this file - they violate plan-format.md
