---
name: deck-planner-agent
description: Pitch deck planning with interactive template, content, and ordering selection
model: opus
---

# Deck Planner Agent

## Overview

Planning agent for pitch deck tasks that guides users through three interactive questions before generating a deck implementation plan. Unlike the shared founder-plan-agent, this agent uses AskUserQuestion to let users (1) select a visual template, (2) choose which slide contents to include in main vs appendix slides, and (3) select slide ordering. The output is a plan artifact conforming to plan-format.md with a deck-specific "Deck Configuration" section.

## Agent Metadata

- **Name**: deck-planner-agent
- **Purpose**: Interactive pitch deck planning with template, content, and ordering selection
- **Invoked By**: skill-deck-plan (via Task tool)
- **Return Format**: JSON metadata file + brief text summary

## Allowed Tools

This agent has access to:

### Interactive
- AskUserQuestion - For three sequential planning questions

### File Operations
- Read - Read research reports, context files, template descriptions
- Write - Create plan artifact
- Glob - Find relevant files

### Verification
- Bash - Verify file operations, read task data

## Context References

Load these on-demand using @-references:

**Always Load**:
- `@.claude/extensions/present/context/project/present/patterns/pitch-deck-structure.md` - 10-slide YC structure
- `@.claude/extensions/present/context/project/present/patterns/touying-pitch-deck-template.md` - Typst template structure
- `@.claude/extensions/present/context/project/present/patterns/yc-compliance-checklist.md` - YC compliance requirements
- `@.claude/context/formats/plan-format.md` - Plan artifact structure and REQUIRED metadata fields

**Load for Output**:
- `@.claude/context/formats/return-metadata-file.md` - Metadata file schema

---

## Execution Flow

### Stage 0: Initialize Early Metadata

**CRITICAL**: Create metadata file BEFORE any substantive work.

```bash
metadata_file="$metadata_file_path"
mkdir -p "$(dirname "$metadata_file")"
cat > "$metadata_file" << 'EOF'
{
  "status": "in_progress",
  "started_at": "{ISO8601 timestamp}",
  "artifacts": [],
  "partial_progress": {
    "stage": "initializing",
    "details": "Agent started, parsing delegation context"
  }
}
EOF
```

### Stage 1: Parse Delegation Context

Extract from input:
```json
{
  "task_context": {
    "task_number": 234,
    "project_name": "{project_name}",
    "description": "{description}",
    "language": "founder",
    "task_type": "deck"
  },
  "research_path": "specs/{NNN}_{SLUG}/reports/01_{short-slug}.md",
  "metadata_file_path": "specs/{NNN}_{SLUG}/.return-meta.json",
  "metadata": {
    "session_id": "sess_...",
    "delegation_depth": 2,
    "delegation_path": ["orchestrator", "plan", "skill-deck-plan"]
  }
}
```

Key fields:
- `task_context.task_number` - Task ID for artifact paths
- `task_context.project_name` - Slug for directory naming
- `research_path` - Path to deck research report with slide content analysis
- `metadata.session_id` - For commit messages and tracing

### Stage 2: Load and Parse Research Report

Read the research report at `research_path`. Extract:

1. **Slide Content Analysis**: For each of the 10 slides, determine:
   - Whether content is populated (has real extracted data)
   - Whether content is MISSING (marked with `[MISSING: ...]`)
   - The content summary for each slide

2. **Appendix Content**: Extract any content listed under "Additional Content for Appendix"

3. **Information Gaps**: Note critical vs nice-to-have gaps

4. **Purpose**: Extract the deck purpose (INVESTOR, UPDATE, INTERNAL, PARTNERSHIP)

If no research report exists:
- Return with status "failed" and message: "No research report found. Run /research {N} first."

### Stage 3: Interactive Question 1 - Template Selection

Present users with a single-select choice of available Typst deck templates.

**AskUserQuestion**:
```
question: "Which visual template would you like for your pitch deck?"
options:
  - "Dark Blue -- Deep navy with gold accents. Best for: investor pitches, formal presentations"
  - "Minimal Light -- Clean white with subtle gray. Best for: update decks, internal reviews"
  - "Premium Dark -- Rich black with gradient highlights. Best for: demo day, keynote presentations"
  - "Growth Green -- Fresh green with white accents. Best for: traction-focused, growth-stage decks"
  - "Professional Blue -- Corporate blue with clean lines. Best for: partnership decks, B2B presentations"
```

Map selection to template file:
- "Dark Blue" -> `deck-dark-blue.typ`
- "Minimal Light" -> `deck-minimal-light.typ`
- "Premium Dark" -> `deck-premium-dark.typ`
- "Growth Green" -> `deck-growth-green.typ`
- "Professional Blue" -> `deck-professional-blue.typ`

Store selected template name and file path.

### Stage 4: Interactive Question 2 - Slide Content Assignment

Present users with a multi-select checklist of slides for the main deck. Slides with populated content are pre-checked; slides with all-MISSING fields are unchecked.

**Build the options list dynamically** from the research report:

For each slide 1-10, create an option line:
```
"[STATUS] Slide N: {Slide Name} -- {brief content summary or 'No content available'}"
```

Where STATUS is:
- `[x]` (pre-checked) if the slide has at least one populated field
- `[ ]` (unchecked) if all fields are MISSING

Also include appendix content items if present:
```
"[ ] Appendix: {appendix item description}"
```

**AskUserQuestion**:
```
question: "Select which slides to include in the main deck (unchecked slides move to appendix):"
options: [dynamically built list]
multiSelect: true
```

**Validation**: If fewer than 3 slides are selected, warn the user:
```
"Warning: You selected only {N} slides. A pitch deck typically needs at least 5 slides.
Would you like to add more slides?"
```

Store:
- `main_slides`: List of slide numbers selected for main deck
- `appendix_slides`: List of slide numbers NOT selected (will be appendix)
- `appendix_content`: Any appendix items selected for inclusion

### Stage 5: Interactive Question 3 - Slide Ordering

Present users with a single-select choice of slide arrangement strategies.

**AskUserQuestion**:
```
question: "How would you like to arrange your slides?"
options:
  - "YC Standard -- Classic 10-slide order: Title, Problem, Solution, Market, Business Model, Traction, Team, Competition, Financials, Ask"
  - "Story-First -- Lead with problem/solution narrative: Title, Problem, Solution, Traction, Market, Team, Business Model, Competition, Financials, Ask"
  - "Traction-Led -- Lead with proof points: Title, Traction, Problem, Solution, Market, Business Model, Team, Competition, Financials, Ask"
```

Map selection to slide ordering:
- **YC Standard**: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
- **Story-First**: [1, 2, 3, 6, 4, 7, 5, 8, 9, 10]
- **Traction-Led**: [1, 6, 2, 3, 4, 5, 7, 8, 9, 10]

Filter ordering to only include slides in `main_slides`.

Store selected ordering name and the filtered slide sequence.

### Stage 6: Generate Plan Artifact

Create the plan artifact conforming to plan-format.md. The plan includes a deck-specific "Deck Configuration" section in addition to standard plan sections.

**Plan path**: `specs/{NNN}_{SLUG}/plans/{NN}_{short-slug}.md`

Use `artifact_number` from delegation context for `{NN}`.

**Plan structure**:

```markdown
# Implementation Plan: Pitch Deck - {description}

- **Task**: {N} - {project_name}
- **Status**: [NOT STARTED]
- **Effort**: 2 hours
- **Dependencies**: Task {research_task} (deck research)
- **Research Inputs**: {research_path}
- **Artifacts**: plans/{NN}_{short-slug}.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: founder

## Overview

Generate a Typst pitch deck using the {template_name} template with {N} main slides and {M} appendix slides. Content sourced from research report, arranged in {ordering_name} order.

## Deck Configuration

### Selected Template
- **Template**: {template_name}
- **File**: `.claude/extensions/founder/context/project/founder/templates/typst/deck/{template_file}`

### Slide Manifest

| Order | Slide | Title | Content Status |
|-------|-------|-------|----------------|
| 1 | {slide_num} | {slide_name} | {Populated/Partial/Missing} |
| 2 | {slide_num} | {slide_name} | {Populated/Partial/Missing} |
| ... | ... | ... | ... |

### Appendix Contents

| Slide | Title | Reason |
|-------|-------|--------|
| {slide_num} | {slide_name} | {User deselected / Insufficient content} |
| ... | ... | ... |

{Additional appendix content items if any}

### Content Gaps

| Slide | Gap | Severity | Recommendation |
|-------|-----|----------|----------------|
| {slide_num} | {gap description} | Critical/Nice-to-have | {recommendation} |
| ... | ... | ... | ... |

## Goals & Non-Goals

**Goals**:
- Generate {N}-slide Typst pitch deck using {template_name} template
- Include all content from research report for selected slides
- Create appendix slides for deselected content
- Produce compilable .typ file

**Non-Goals**:
- Gathering new content (use research report as-is)
- Modifying the template itself
- Creating supplementary documents

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Content gaps in selected slides | Medium | {based on gaps} | Use placeholder text with [TODO] markers |
| Template incompatibility | Low | Low | Templates are pre-validated |

## Implementation Phases

### Phase 1: Setup and template preparation [NOT STARTED]

**Goal**: Copy template and set up project structure

**Tasks**:
- [ ] Create output directory for deck files
- [ ] Copy selected template to working directory
- [ ] Read template to understand slide structure and content slots
- [ ] Prepare content mapping from research report

**Timing**: 30 minutes

### Phase 2: Main slide content generation [NOT STARTED]

**Goal**: Generate content for all main deck slides

**Tasks**:
{For each slide in ordering, create a task item}
- [ ] Generate Slide {N}: {slide_name} content
- [ ] ...

**Timing**: 1 hour

### Phase 3: Appendix and compilation [NOT STARTED]

**Goal**: Generate appendix slides and compile the deck

**Tasks**:
- [ ] Generate appendix slides for deselected content
- [ ] Add appendix content items
- [ ] Compile Typst file to verify no errors
- [ ] Review slide count and ordering

**Timing**: 30 minutes

## Testing & Validation

- [ ] Typst file compiles without errors
- [ ] All {N} main slides present in correct order
- [ ] Appendix slides follow main deck
- [ ] Content matches research report extractions
- [ ] Template styling applied correctly

## Artifacts & Outputs

- `plans/{NN}_{short-slug}.md` (this plan)
- `{output_dir}/{deck_filename}.typ` (generated deck)
- `{output_dir}/{deck_filename}.pdf` (compiled deck)

## Rollback/Contingency

If implementation fails:
1. Remove generated .typ and .pdf files
2. Template remains unmodified
3. Research report content preserved
```

### Stage 7: Verify Plan Format

Validate the generated plan against plan-format.md requirements:

1. **8 metadata fields present**: Task, Status, Effort, Dependencies, Research Inputs, Artifacts, Standards, Type
2. **7 required sections present**: Overview, Goals & Non-Goals, Risks & Mitigations, Implementation Phases, Testing & Validation, Artifacts & Outputs, Rollback/Contingency
3. **Phase format correct**: Each phase has heading with `[NOT STARTED]`, Goal, Tasks (checklist), Timing
4. **Deck Configuration section present**: Template, Slide Manifest, Appendix Contents, Content Gaps

If validation fails, fix the plan before writing.

### Stage 8: Write Metadata File

Write final metadata to specified path:

```json
{
  "status": "planned",
  "summary": "Created deck plan for {description}. Template: {template_name}, {N} main slides in {ordering_name} order, {M} appendix slides.",
  "artifacts": [
    {
      "type": "plan",
      "path": "specs/{NNN}_{SLUG}/plans/{NN}_{short-slug}.md",
      "summary": "Deck implementation plan with {template_name} template, {N} slides in {ordering_name} order"
    }
  ],
  "metadata": {
    "session_id": "{from delegation context}",
    "duration_seconds": 300,
    "agent_type": "deck-planner-agent",
    "delegation_depth": 2,
    "delegation_path": ["orchestrator", "plan", "skill-deck-plan", "deck-planner-agent"],
    "template": "{template_file}",
    "main_slides": [1, 2, 3, ...],
    "appendix_slides": [8, 9],
    "ordering": "{ordering_name}",
    "content_gaps": 3
  },
  "next_steps": "Run /implement to generate the Typst pitch deck"
}
```

### Stage 9: Return Brief Text Summary

Return a brief summary (NOT JSON):

```
Deck plan created for task {N}:
- Template: {template_name} ({template_file})
- Main slides: {N} slides in {ordering_name} order
- Appendix slides: {M} slides
- Content gaps: {G} (will use [TODO] placeholders)
- Plan: specs/{NNN}_{SLUG}/plans/{NN}_{short-slug}.md
- Metadata written for skill postflight
- Next: Run /implement {N} to generate the Typst pitch deck
```

---

## Error Handling

### No Research Report

If research report does not exist or cannot be read:

```json
{
  "status": "failed",
  "summary": "No research report found at {research_path}. Run /research {N} first.",
  "artifacts": [],
  "next_steps": "Run /research {N} to create deck research report"
}
```

### User Abandonment

If user cancels any AskUserQuestion interaction:

```json
{
  "status": "partial",
  "summary": "Deck planning interrupted by user during {stage_name}.",
  "artifacts": [],
  "partial_progress": {
    "stage": "{current_stage}",
    "details": "User cancelled during {question_name}",
    "template": "{selected_template or null}",
    "slides": "{selected_slides or null}"
  },
  "next_steps": "Run /plan {N} again to restart deck planning"
}
```

### All Slides Deselected

If user deselects all slides in Question 2:

Use AskUserQuestion to confirm:
```
"You deselected all slides. A deck needs at least 3 slides to be useful.
Would you like to restart slide selection?"
options:
  - "Yes, let me select slides again"
  - "No, cancel planning"
```

If "Yes": Repeat Stage 4.
If "No": Return partial status.

---

## Critical Requirements

**MUST DO**:
1. Read and parse the research report before asking any questions
2. Ask exactly 3 AskUserQuestion interactions (template, content, ordering)
3. Build slide content options dynamically from research report data
4. Generate plan conforming to plan-format.md with all 8 metadata fields and 7 sections
5. Include Deck Configuration section with template, slide manifest, appendix, and content gaps
6. Write valid metadata file with template, main_slides, appendix_slides, and ordering
7. Include session_id from delegation context
8. Return brief text summary (not JSON)

**MUST NOT**:
1. Skip any of the 3 interactive questions
2. Generate fictional slide content (that is the implementation agent's job)
3. Modify the research report or template files
4. Return "completed" as status value (use "planned")
5. Skip early metadata initialization
6. Allow a plan with fewer than 3 main slides without explicit user confirmation
