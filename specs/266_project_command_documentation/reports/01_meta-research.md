# Research Report: Task #266

**Task**: 266 - Update /project command documentation and workflow
**Generated**: 2026-03-24
**Source**: /meta interview (auto-generated)
**Status**: Pre-populated from interview context

---

## Context Summary

**Purpose**: Update /project command to reflect new standard workflow
**Scope**: .claude/extensions/founder/commands/project.md
**Affected Components**: project.md command
**Domain**: founder extension
**Language**: meta

## Task Requirements

Update project.md command documentation to reflect the new standard workflow:

1. Update Workflow Summary section to match other founder commands
2. Update STAGE 2 (DELEGATE) to route to research, not combined research+planning
3. Update CHECKPOINT 2 (GATE OUT) for research-only output
4. Update examples to show full workflow
5. Update Next Steps guidance in all output messages

### Current Workflow (to change)
```
/project "description" -> Creates task, stops at [NOT STARTED]
/research {N}          -> Routes to skill-project, creates timeline, stops at [PLANNED]
/project {N} (TRACK)   -> Updates timeline
/project {N} (REPORT)  -> Generates report
```

### Target Workflow
```
/project "description" -> Creates task with forcing_data, stops at [NOT STARTED]
/research {N}          -> Creates research report, stops at [RESEARCHED]
/plan {N}              -> Creates implementation plan, stops at [PLANNED]
/implement {N}         -> Generates timeline, stops at [COMPLETED]
```

## Integration Points

- **Component Type**: command
- **Affected Area**: .claude/extensions/founder/commands/
- **Action Type**: modify
- **Related Files**:
  - `.claude/extensions/founder/commands/project.md`
  - `.claude/extensions/founder/commands/market.md` (reference pattern)
  - `.claude/extensions/founder/commands/strategy.md` (reference pattern)

## Dependencies

- Task #262: Refactor project-agent to generate research report instead of timeline
- Task #263: Update skill-project for research-only workflow
- Task #264: Create project-specific planning context for planner-agent
- Task #265: Extend founder-implement-agent for project timeline generation

All implementation tasks must be complete before documentation can accurately reflect the new workflow.

## Interview Context

### User-Provided Information
The documentation needs to guide users through the standard phased workflow. The current documentation describes the old autonomous workflow.

### Effort Assessment
- **Estimated Effort**: 30 minutes (Small)
- **Complexity Notes**: Primarily text changes. Most sections can be adapted from other founder command files. The Workflow Summary section is the most important update.

## Sections to Update

1. **Overview** - Update to mention standard phased workflow
2. **Workflow Summary** - Replace with /market-style workflow
3. **STAGE 2: DELEGATE** - Simplify to research-only routing
4. **CHECKPOINT 2: GATE OUT** - Update for research output, not timeline
5. **Output Artifacts** - Update artifact locations
6. **Examples** - Add examples showing full /research -> /plan -> /implement flow

---

*This research report was auto-generated during task creation via /meta command.*
*For deeper investigation, run `/research 266 [focus]` with a specific focus prompt.*
