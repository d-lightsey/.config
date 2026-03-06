# Memory: Clean-Break Command Renaming Pattern

**Category**: [PATTERN]
**Source**: Task OC_142 - implement_knowledge_capture_system
**Artifact**: specs/OC_142_implement_knowledge_capture_system/summaries/implementation-summary-20260305.md
**Date**: 2026-03-05

## Pattern

When renaming commands or features, use a **clean-break approach** with NO backwards compatibility:

1. **NO aliases**: Old command name will not work
2. **NO fallbacks**: Command returns "not found" error
3. **NO backwards compatibility**: All scripts must be updated
4. **Complete migration**: Replace all references atomically

## Rationale

- Muscle memory is re-trainable; semantic correctness matters more
- Aliases create technical debt and confusion
- Clean breaks force complete updates, avoiding partial/inconsistent states
- The cost is one-time user retraining; the benefit is long-term clarity

## Example

```
/learn → /fix

Bad (with alias):
  /learn still works, /learn and /fix both exist
  
Good (clean-break):
  /learn returns "command not found"
  /fix is the ONLY way to access the feature
  All documentation updated in single commit
```

## Application

Use this pattern when:
- The old name is semantically incorrect or misleading
- The feature is used frequently enough to build muscle memory
- You want to force complete adoption of the new naming
- Technical debt from dual naming is unacceptable

## References

- OC_142 implementation: Renamed /learn to /fix across 10+ files
- Verification: `grep -r "/learn" .opencode/` returns zero results
