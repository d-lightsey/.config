# Research Report: Task #263

**Task**: 263 - Update skill-project for research-only workflow
**Generated**: 2026-03-24
**Source**: /meta interview (auto-generated)
**Status**: Pre-populated from interview context

---

## Context Summary

**Purpose**: Refactor /project command workflow to match standard phased pattern
**Scope**: .claude/extensions/founder/skills/skill-project/SKILL.md
**Affected Components**: skill-project
**Domain**: founder extension
**Language**: meta

## Task Requirements

Modify skill-project to handle research-only workflow:

1. Route to project-agent for research phase only
2. Update task status to "researching" in preflight
3. Update task status to "researched" in postflight
4. Link research report artifact (not timeline)
5. Remove timeline generation, PLANNED/TRACKED/REPORTED status handling

### Current Behavior (to change)
- skill-project updates status to "planning"
- skill-project links timeline artifact
- skill-project sets final status to "planned/tracked/reported"

### Target Behavior
- skill-project updates status to "researching"
- skill-project links research report artifact
- skill-project sets final status to "researched"
- Timeline generation moved to founder-implement-agent

## Integration Points

- **Component Type**: skill
- **Affected Area**: .claude/extensions/founder/skills/skill-project/
- **Action Type**: refactor
- **Related Files**:
  - `.claude/extensions/founder/skills/skill-project/SKILL.md`
  - `.claude/extensions/founder/skills/skill-market/SKILL.md` (reference pattern)

## Dependencies

- Task #262: Refactor project-agent to generate research report instead of timeline

The skill depends on the agent producing a research report. Must be updated after project-agent refactoring.

## Interview Context

### User-Provided Information
The skill currently handles the full workflow including timeline generation. It needs to be simplified to match the research-only pattern used by skill-market, skill-analyze, skill-strategy, and skill-legal.

### Effort Assessment
- **Estimated Effort**: 1-2 hours (Medium)
- **Complexity Notes**: Mostly removal of code. The timeline generation logic moves to the implementation phase. Status handling simplifies significantly.

## Reference Pattern

See skill-market SKILL.md for the standard research skill pattern:
- Stage 2: Preflight Status Update to "researching"
- Stage 7: Update Task Status (Postflight) to "researched"
- Stage 8: Link Research Artifacts
- Stage 11: Return Brief Summary with "Next: Run /plan {N}"

---

*This research report was auto-generated during task creation via /meta command.*
*For deeper investigation, run `/research 263 [focus]` with a specific focus prompt.*
