# Research Report: Task #265

**Task**: 265 - Extend founder-implement-agent for project timeline generation
**Generated**: 2026-03-24
**Source**: /meta interview (auto-generated)
**Status**: Pre-populated from interview context

---

## Context Summary

**Purpose**: Add project timeline generation capability to implementation phase
**Scope**: .claude/extensions/founder/agents/
**Affected Components**: founder-implement-agent or new project-implement-agent
**Domain**: founder extension
**Language**: meta

## Task Requirements

Add project timeline generation capability to the implementation phase:

1. Extend founder-implement-agent to handle `task_type: "project"` OR create dedicated project-implement-agent
2. Read implementation plan phases
3. Generate Typst timeline file at `strategy/timelines/{project-slug}.typ`
4. Handle PLAN/TRACK/REPORT modes during implementation
5. Attempt PDF compilation if typst is available
6. Return status "implemented" with completion_summary

### Key Logic to Move from project-agent
- Typst file generation (Stage 6 in current project-agent)
- PDF compilation (Stage 7 in current project-agent)
- Mode-specific output handling (PLAN creates timeline, TRACK updates it, REPORT generates summary)

### Design Decision
Option A: Extend founder-implement-agent with project-specific handling
Option B: Create dedicated project-implement-agent (cleaner separation)

Recommendation: Option A unless founder-implement-agent becomes too complex. Project timeline generation shares patterns with other founder strategy outputs.

## Integration Points

- **Component Type**: agent
- **Affected Area**: .claude/extensions/founder/agents/
- **Action Type**: extend or create
- **Related Files**:
  - `.claude/extensions/founder/agents/founder-implement-agent.md`
  - `.claude/extensions/founder/agents/project-agent.md` (source of timeline logic)
  - `.claude/extensions/founder/skills/skill-founder-implement/SKILL.md`

## Dependencies

- Task #263: Update skill-project for research-only workflow
- Task #264: Create project-specific planning context for planner-agent

The implementation agent needs:
1. The skill routing to be updated (task #263)
2. The planning context to generate proper implementation plans (task #264)

## Interview Context

### User-Provided Information
The timeline generation logic currently in project-agent needs to move to the implementation phase. This ensures the user can review and revise the plan before final timeline generation.

### Effort Assessment
- **Estimated Effort**: 2-3 hours (Medium)
- **Complexity Notes**: Significant logic movement from project-agent. Need to ensure all three modes (PLAN/TRACK/REPORT) work correctly. PDF compilation is non-blocking.

## Implementation Outline

```markdown
## Stage X: Project Timeline Implementation

### Detect Project Task
if task_type == "project":
  route to project timeline generation

### Read Research Data
- Parse research report for WBS structure
- Extract PERT estimates
- Extract resource allocation data

### Generate Timeline (PLAN mode)
- Create self-contained Typst file
- Inline all required functions
- Generate WBS, PERT table, resource matrix, Gantt

### Update Timeline (TRACK mode)
- Read existing timeline
- Update with progress data
- Recalculate critical path

### Generate Report (REPORT mode)
- Create status summary
- Extract key metrics
- Generate executive report
```

---

*This research report was auto-generated during task creation via /meta command.*
*For deeper investigation, run `/research 265 [focus]` with a specific focus prompt.*
