---
paths: .claude/context/repo/project-overview.md
---

# Project Overview Detection Rule

## Conditional Check

When loading or referencing `.claude/context/repo/project-overview.md`, check whether the file begins with the generic template marker:

```
<!-- GENERIC TEMPLATE
```

## Action: Marker Found

If the first line contains `<!-- GENERIC TEMPLATE`:

1. **Notify the user** that `project-overview.md` contains the generic template placeholder and has not been customized for this repository.
2. **Suggest** running: `/task "Generate project-overview.md for this repository"`
3. **Reference** `.claude/context/repo/update-project.md` for the generation workflow and guidance.

Do NOT silently proceed with the generic content -- the user should be made aware that project-specific context is missing.

## Action: Marker Absent

If the file does NOT begin with `<!-- GENERIC TEMPLATE`: no action needed. The file has been customized and is ready for use.
