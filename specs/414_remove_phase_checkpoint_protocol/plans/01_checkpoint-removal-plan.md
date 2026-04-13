# Implementation Plan: Task #414

**Task**: Remove Phase Checkpoint Protocol from 10 extension agents
**Status**: [NOT STARTED]
**Created**: 2026-04-13
**Estimated effort**: 1 hour
**Research**: [01_checkpoint-protocol-audit.md](../reports/01_checkpoint-protocol-audit.md)

## Overview

Remove the `## Phase Checkpoint Protocol` sections and all inline references from 10 extension implementation agents. Three complexity tiers: simple (5), standard (2), complex (3). Total: ~286 lines removed across 10 files.

## Dependencies

- None (independent task)

## Phases

### Phase 1: Simple Agents (5 files) [NOT STARTED]

Remove the `## Phase Checkpoint Protocol` section and single inline reference from 5 agents with straightforward structure.

**Files to modify**:

| File | Section to Remove | Inline Ref to Remove |
|------|-------------------|---------------------|
| `extensions/latex/agents/latex-implementation-agent.md` | Lines 131-148 | L164: `5. Update plan file phase markers with Edit tool` |
| `extensions/typst/agents/typst-implementation-agent.md` | Lines 110-127 | L145: `5. Update plan file phase markers with Edit tool` |
| `extensions/python/agents/python-implementation-agent.md` | Lines 129-156 | L164: `5. Update plan file phase markers with Edit tool` |
| `extensions/z3/agents/z3-implementation-agent.md` | Lines 124-151 | L159: `5. Update plan file phase markers with Edit tool` |
| `extensions/nix/agents/nix-implementation-agent.md` | Lines 698-720 | None |

**Steps per file**:
1. Delete the `## Phase Checkpoint Protocol` section (heading through end of section including trailing `---` and blank lines)
2. Delete the inline reference line in Critical Requirements MUST DO list (if present)
3. Renumber the MUST DO list after removal

**Verification**: Grep for `Phase Checkpoint Protocol` in each file — should return 0 matches.

### Phase 2: Standard Agents (2 files) [NOT STARTED]

Same pattern as Phase 1 but with slightly different inline reference locations.

**Files to modify**:

| File | Section to Remove | Inline Ref to Remove |
|------|-------------------|---------------------|
| `extensions/nvim/agents/neovim-implementation-agent.md` | Lines 370-394 | L406: `9. Always update plan file with phase status changes` |
| `extensions/web/agents/web-implementation-agent.md` | Lines 353-377 | L826: `6. Always update plan file with phase status changes` |

**Steps per file**:
1. Delete the `## Phase Checkpoint Protocol` section
2. Delete the inline reference line in Critical Requirements MUST DO list
3. Renumber the MUST DO list after removal

**Verification**: Grep for `Phase Checkpoint Protocol` and `phase status changes` in each file.

### Phase 3: Complex Agents (3 files) [NOT STARTED]

Three agents with additional inline references or structural issues.

#### 3a. founder-implement-agent.md

**Removals**:
1. Delete `## Phase Checkpoint Protocol` section (lines 1486-1515)
2. Delete `- Edit - Update plan phase markers` from Allowed Tools (line 27)
3. Delete `3. Always update phase markers in plan file` from MUST DO list (line 1620)
4. Delete `8. Leave phase markers in [IN PROGRESS] state` from MUST NOT list (line 1639)
5. Renumber both MUST DO and MUST NOT lists

**Keep** (operational context, not checkpoint protocol):
- L111: `- Phase list with status markers` (plan parsing)
- L179, L349, L389: implicit_typst_phase marker logic (Phase 5 operational)

#### 3b. deck-builder-agent.md

**Removals**:
1. Delete `## Phase Checkpoint Protocol` section (lines 489-518, including preceding `---`)
2. Delete `- Edit - Update plan phase markers` from Allowed Tools (line 26)
3. Delete the 18-line inline duplicate in Stage 3 (lines 178-195): "Before each phase" / "After each phase" block with Edit tool examples and git commit instructions

**Keep**:
- Lines 170-177: Phase scan logic (resume point detection) — this is operational, not the protocol

#### 3c. grant-agent.md

**Restructure** (most complex):
1. Stage 6 and Stage 7 content (lines 431-517) is currently nested under `## Phase Checkpoint Protocol`. These must be preserved.
2. Delete the protocol content only (lines 397-429)
3. Promote `### Stage 6: Write Metadata File` and `### Stage 7: Return Brief Text Summary` — they become direct children of the execution flow, positioned where the Phase Checkpoint Protocol heading was

**Verification**: Ensure Stage 6 and Stage 7 are still present and accessible after restructuring.

### Phase 4: Verify and Clean Up [NOT STARTED]

1. Run `grep -r "Phase Checkpoint Protocol" .claude/extensions/` — expect 0 matches
2. Run `grep -r "Update plan.*phase markers" .claude/extensions/` — expect 0 matches in agents (may still appear in context docs)
3. Verify no orphaned `---` separators or blank lines at section boundaries
4. Verify grant-agent Stage 6/7 content is intact

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Accidentally delete Stage 6/7 in grant-agent | High | Read content before and after edit, verify stages present |
| Break numbering in Critical Requirements | Low | Renumber after each deletion |
| Miss an inline reference | Low | Research report provides complete inventory; grep verification in Phase 4 |

## Success Criteria

- [ ] 0 matches for `Phase Checkpoint Protocol` in `.claude/extensions/`
- [ ] 0 matches for `Update plan.*phase markers` in agent files
- [ ] grant-agent Stage 6 and Stage 7 preserved and correctly placed
- [ ] All MUST DO / MUST NOT lists correctly numbered
- [ ] No orphaned separators or blank line artifacts
