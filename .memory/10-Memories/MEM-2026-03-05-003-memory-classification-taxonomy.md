# Memory: 5-Category Memory Classification Taxonomy

**Category**: [CONFIG]
**Source**: Task OC_142 - implement_knowledge_capture_system
**Artifact**: specs/OC_142_implement_knowledge_capture_system/reports/research-002.md
**Date**: 2026-03-05

## Taxonomy

When classifying knowledge from task artifacts, use these 5 (+1) categories:

| Category | Description | Example |
|----------|-------------|---------|
| **TECHNIQUE** | Reusable method or approach | "Three-phase debugging process" |
| **PATTERN** | Design or implementation pattern | "Agent delegation wrapper pattern" |
| **CONFIG** | Configuration or setup knowledge | "Neovim LSP keymap configuration" |
| **WORKFLOW** | Process or procedure | "Code review checklist workflow" |
| **INSIGHT** | Key learning or understanding | "Root cause of race condition" |
| **SKIP** | Not valuable for memory | Transient or project-specific details |

## Usage

### Interactive Classification

Present as checkbox options in `AskUserQuestion` with `multiSelect: true`:

```json
{
  "question": "Classify the knowledge from this artifact:",
  "options": [
    {"label": "[TECHNIQUE] Reusable method", "value": "technique"},
    {"label": "[PATTERN] Design pattern", "value": "pattern"},
    {"label": "[CONFIG] Configuration knowledge", "value": "config"},
    {"label": "[WORKFLOW] Process or procedure", "value": "workflow"},
    {"label": "[INSIGHT] Key learning", "value": "insight"},
    {"label": "[SKIP] Not valuable", "value": "skip"}
  ],
  "multiple": true
}
```

### Memory File Naming

Include category in memory filename:
```
MEM-YYYY-MM-DD-NNN-{category}-{slugified-title}.md
```

### Memory File Header

```markdown
# Memory: {title}

**Category**: [CATEGORY]
**Source**: Task OC_{N} - {task_name}
**Artifact**: {artifact_path}
**Date**: YYYY-MM-DD
```

## Decision Guide

- **TECHNIQUE** → Use when you discovered a reusable method that can be applied elsewhere
- **PATTERN** → Use when you identified an architectural or design pattern
- **CONFIG** → Use when you figured out how to configure something complex
- **WORKFLOW** → Use when you established or improved a process
- **INSIGHT** → Use when you gained deep understanding of a problem/solution
- **SKIP** → Use for one-off fixes, temporary workarounds, or obvious solutions

## References

- OC_142 implementation: /remember --task mode with interactive classification
- Memory vault structure: .opencode/memory/10-Memories/
