# Implementation Plan: Document Extension Dependency System

- **Task**: 459 - document_extension_dependency_system
- **Status**: [NOT STARTED]
- **Effort**: 1 hour
- **Dependencies**: Task 457 (implementation complete)
- **Research Inputs**: reports/01_extension-deps-docs.md
- **Artifacts**: plans/01_extension-deps-docs.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: true

## Overview

Update six documentation files to reflect the extension dependency system implemented in task 457. The extension development guide was already updated in task 457; this task covers the remaining docs that reference extensions as "self-contained" or omit dependency support. Done when all six files are updated and consistent.

### Research Integration

Research report (`reports/01_extension-deps-docs.md`) identified six files needing updates with specific line numbers and suggested changes. The extension development guide is confirmed already updated and needs no changes.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This task advances the "Agent System Quality" roadmap area by reducing documentation drift. It also indirectly supports "Extension slim standard enforcement" by ensuring dependency features are documented in the creating-extensions guide.

## Goals & Non-Goals

**Goals**:
- Add dependency support mention to CLAUDE.md extension section
- Update extension-system.md load/unload process with dependency steps
- Add resource-only extension pattern to creating-extensions.md
- Qualify "self-contained" language in adding-domains.md
- Add slidev to extensions/README.md table
- Mention slidev and dependencies in project-overview.md

**Non-Goals**:
- Modifying extension-development.md (already complete)
- Changing any implementation code
- Adding new features to the dependency system

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Over-documenting in CLAUDE.md wastes context budget | M | M | Keep to 2-3 lines, point to extension-development.md |
| Inconsistent "self-contained" phrasing across docs | L | M | Use consistent wording: "self-contained packages that can optionally declare dependencies" |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |

Phases within the same wave can execute in parallel.

### Phase 1: Update High-Visibility Docs [NOT STARTED]

**Goal**: Update the three most-read documentation files: CLAUDE.md, extensions/README.md, and project-overview.md.

**Tasks**:
- [ ] `.claude/CLAUDE.md` -- Add 2-3 lines after the extension task types paragraph (around line 77) noting dependency support with `dependencies` array in manifest.json, auto-loading behavior, and pointer to extension-development.md
- [ ] `.claude/extensions/README.md` -- Add slidev row to the Available Extensions table (task_type `-`, description "Shared Slidev animation patterns and CSS style presets"); add brief dependency mention in Loading Extensions section
- [ ] `.claude/context/repo/project-overview.md` -- Add note about slidev/ as a shared resource extension and mention that extensions can declare dependencies

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `.claude/CLAUDE.md` - Add dependency support note to extension section
- `.claude/extensions/README.md` - Add slidev row and dependency mention
- `.claude/context/repo/project-overview.md` - Add slidev and dependency note

**Verification**:
- All three files mention dependency support
- slidev appears in the extensions README table
- CLAUDE.md note is concise (2-3 lines max)

---

### Phase 2: Update Architecture and Guide Docs [NOT STARTED]

**Goal**: Update the three architecture/guide documents to reflect dependency resolution in load/unload processes and add resource-only extension pattern.

**Tasks**:
- [ ] `.claude/docs/architecture/extension-system.md` -- Qualify "self-contained" in overview; add dependency resolution step (step 1.5) to load process; add reverse dependency check step to unload process
- [ ] `.claude/docs/guides/creating-extensions.md` -- Qualify "self-contained" in overview; expand dependencies field note in table; add brief "Resource-Only Extensions" subsection (~10 lines) with slidev as example
- [ ] `.claude/docs/guides/adding-domains.md` -- Qualify "self-contained" and "independently" language at lines 15, 29, 32; add brief note about shared resource pattern

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `.claude/docs/architecture/extension-system.md` - Update overview, load/unload processes
- `.claude/docs/guides/creating-extensions.md` - Update overview, add resource-only section
- `.claude/docs/guides/adding-domains.md` - Qualify self-contained language

**Verification**:
- extension-system.md load process includes dependency resolution step
- extension-system.md unload process includes reverse dependency check
- creating-extensions.md has resource-only extension subsection
- No docs describe extensions as purely "self-contained" without qualification

## Testing & Validation

- [ ] All six files updated with consistent dependency language
- [ ] No file describes extensions as only "self-contained" without dependency qualification
- [ ] slidev appears in extensions README table
- [ ] CLAUDE.md extension section mentions dependency support concisely
- [ ] extension-system.md load/unload processes include dependency steps
- [ ] creating-extensions.md includes resource-only extension pattern

## Artifacts & Outputs

- plans/01_extension-deps-docs.md (this plan)
- summaries/01_extension-deps-docs-summary.md (post-implementation)
- Six updated documentation files (listed in phases above)

## Rollback/Contingency

All changes are documentation-only edits to existing files. Revert with `git checkout` on the six modified files if any changes introduce inaccuracies.
