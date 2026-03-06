# Memory: Metadata Delegation Pattern with .return-meta.json

**Category**: [PATTERN]
**Source**: Task OC_143 - fix_skill_researcher_todo_linking
**Artifact**: specs/OC_143_fix_skill_researcher_todo_linking/summaries/implementation-summary-20260305.md
**Date**: 2026-03-05

## Pattern

Skills that delegate to agents should use **file-based metadata exchange** via `.return-meta.json`:

### Skill Side (Delegation)

```markdown
<delegate>
<target>general-research-agent</target>
<task>
Research the following topic: {topic}

**Return Requirements:**
- Write findings to: {report_path}
- Write metadata to: {metadata_file_path}

**Metadata Format:**
```json
{
  "artifacts": [
    {
      "type": "research",
      "path": "path/to/report.md",
      "summary": "Brief description"
    }
  ]
}
```
</task>
</delegate>
```

### Agent Side (Execution)

1. Accept `metadata_file_path` parameter
2. Create artifacts as specified
3. Write `.return-meta.json` to `metadata_file_path`
4. Return control to skill

### Skill Side (Postflight)

1. Read `.return-meta.json` from known location
2. Parse artifact list
3. Update state files with artifact references
4. Update TODO.md with links

## Critical Parameter

Always include `metadata_file_path` in delegation context:

```json
{
  "task_context": { "task_number": N, ... },
  "metadata": { "session_id": "...", ... },
  "metadata_file_path": "specs/OC_N_.../.return-meta.json"
}
```

## Common Failure

**Missing metadata_file_path**: Agent doesn't know where to write metadata, so postflight cannot parse artifacts. Results in missing TODO.md links.

## References

- OC_143 fix: Added missing `metadata_file_path` to skill-researcher Stage 3
- Pattern used by: skill-researcher, skill-implementer, skill-planner
