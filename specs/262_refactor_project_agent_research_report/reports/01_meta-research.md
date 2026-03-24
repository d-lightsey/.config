# Research Report: Task #262

**Task**: 262 - Refactor project-agent to generate research report instead of timeline
**Generated**: 2026-03-24
**Source**: /meta interview (auto-generated)
**Status**: Pre-populated from interview context

---

## Context Summary

**Purpose**: Refactor /project command workflow to match standard phased pattern
**Scope**: .claude/extensions/founder/agents/project-agent.md
**Affected Components**: project-agent
**Domain**: founder extension
**Language**: meta

## Task Requirements

Refactor project-agent to follow the standard research agent pattern. Currently, project-agent directly generates the timeline Typst file during the research phase. This task refactors it to:

1. Gather project data through forcing questions (WBS structure, PERT estimates, resource allocation)
2. Output a research report at `specs/{NNN}_{SLUG}/reports/01_{short-slug}.md`
3. Return status "researched" instead of "planned/tracked/reported"
4. Store gathered data in a format that planner-agent can consume for implementation planning

### Current Behavior (to change)
- project-agent asks forcing questions
- project-agent calculates PERT estimates
- project-agent generates Typst timeline file directly
- skill-project sets status to "planned"

### Target Behavior
- project-agent asks forcing questions
- project-agent calculates PERT estimates and critical path
- project-agent writes research report with all gathered data
- skill-project sets status to "researched"
- Timeline generation deferred to /implement phase

## Integration Points

- **Component Type**: agent
- **Affected Area**: .claude/extensions/founder/agents/
- **Action Type**: refactor
- **Related Files**:
  - `.claude/extensions/founder/agents/project-agent.md`
  - `.claude/extensions/founder/agents/market-agent.md` (reference pattern)
  - `.claude/context/core/formats/return-metadata-file.md`

## Dependencies

None - this task is foundational for the refactoring effort.

## Interview Context

### User-Provided Information
The /project command tested successfully but ran through research, planning, and implementation phases autonomously. The user wants /project to follow the standard pattern: create task -> /research -> /plan -> /implement, allowing review between phases.

### Effort Assessment
- **Estimated Effort**: 2-3 hours (Medium)
- **Complexity Notes**: Requires restructuring agent output from Typst file to markdown research report. Most of the forcing question logic can be preserved; main changes are in output generation and status handling.

## Reference Pattern

See market-agent.md for the standard research agent pattern:
- Stage 6: Generate Research Report (markdown format)
- Stage 7: Write Research Report to specs directory
- Stage 8: Write Metadata File with status "researched"
- Stage 9: Return Brief Text Summary

---

*This research report was auto-generated during task creation via /meta command.*
*For deeper investigation, run `/research 262 [focus]` with a specific focus prompt.*
