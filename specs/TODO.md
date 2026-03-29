---
next_project_number: 322
---

# TODO

## Task Order

*Updated 2026-03-29. 10 active tasks remaining.*

### Pending

- **314** [RESEARCHED] -- Create spreadsheet-agent
- **315** [RESEARCHED] -- Create skill-spreadsheet
- **316** [RESEARCHED] -- Create /sheet command
- **317** [RESEARCHED] -- Update founder manifest.json routing
- **318** [RESEARCHED] -- Create Typst spreadsheet template
- **310** [NOT STARTED] -- Update state.json schema
- **311** [NOT STARTED] -- Update artifact-formats.md rule
- **312** [NOT STARTED] -- Update skills/agents unified numbering
- **87** [RESEARCHED] -- Investigate terminal directory change in wezterm
- **78** [PLANNED] -- Fix Himalaya SMTP authentication failure

## Tasks

### 314. Create spreadsheet-agent
- **Effort**: 3 hours
- **Status**: [RESEARCHED]
- **Language**: meta
- **Dependencies**: Task #313
- **Research**: [01_meta-research.md](314_spreadsheet_agent/reports/01_meta-research.md)

**Description**: Create spreadsheet-agent.md research agent that parses cost breakdown files, extracts structured financial data via forcing questions, and generates research reports with raw JSON data blocks.

---

### 315. Create skill-spreadsheet
- **Effort**: 1 hour
- **Status**: [RESEARCHED]
- **Language**: meta
- **Dependencies**: Task #314
- **Research**: [01_meta-research.md](315_skill_spreadsheet/reports/01_meta-research.md)

**Description**: Create skill-spreadsheet/SKILL.md thin wrapper that routes to spreadsheet-agent with proper preflight/postflight handling.

---

### 316. Create /sheet command
- **Effort**: 1 hour
- **Status**: [RESEARCHED]
- **Language**: meta
- **Dependencies**: Task #315
- **Research**: [01_meta-research.md](316_sheet_command/reports/01_meta-research.md)

**Description**: Create sheet.md command that accepts file path argument, creates task with founder:sheet language, and invokes skill-spreadsheet for research/plan/implement workflow.

---

### 317. Update founder manifest.json routing
- **Effort**: 30 min
- **Status**: [RESEARCHED]
- **Language**: meta
- **Dependencies**: Task #315
- **Research**: [01_meta-research.md](317_founder_manifest_routing/reports/01_meta-research.md)

**Description**: Add 'sheet' task type routing entries to manifest.json for research, plan, and implement operations. Update provides arrays and index-entries.json.

---

### 318. Create Typst spreadsheet template
- **Effort**: 2 hours
- **Status**: [RESEARCHED]
- **Language**: meta
- **Dependencies**: Task #313
- **Research**: [01_meta-research.md](318_typst_spreadsheet_template/reports/01_meta-research.md)

**Description**: Create spreadsheet-template.typ with cost category tables, calculated totals, monthly projections, and auto-updating formulas using Typst state.

---

### 310. Update state.json schema with next_artifact_number field
- **Effort**: 1 hour
- **Status**: [NOT STARTED]
- **Language**: meta
- **Dependencies**: Task #309

**Description**: Add next_artifact_number field to task entries in state.json schema. Update state-management-schema.md documentation. Handle backward compatibility for existing tasks without the field.

---

### 311. Update artifact-formats.md rule for unified numbering
- **Effort**: 1 hour
- **Status**: [NOT STARTED]
- **Language**: meta
- **Dependencies**: Task #309

**Description**: Change "Per-Type Sequential Numbering" to "Unified Sequential Numbering" with new semantics: research increments, plan/summary inherit current max. Document the research-driven pattern.

---

### 312. Update all skills and agents for unified numbering
- **Effort**: 3-4 hours
- **Status**: [NOT STARTED]
- **Language**: meta
- **Dependencies**: Task #310, Task #311

**Description**: Modify all artifact-producing components to use unified numbering. Research skill/agent increments next_artifact_number. Planning and implementation skills/agents inherit the current max number from existing artifacts. Also update extension agents that produce artifacts.

---

### 87. Investigate terminal directory change when opening neovim in wezterm
- **Effort**: TBD
- **Status**: [RESEARCHED]
- **Research Started**: 2026-02-13
- **Research Completed**: 2026-02-13
- **Language**: neovim
- **Dependencies**: None
- **Research**: [research-001.md](087_investigate_wezterm_terminal_directory_change/reports/research-001.md)

**Description**: Investigate why the terminal working directory changes to a project root when opening neovim sessions in wezterm from the home directory (~). Determine whether this behavior is caused by neovim or wezterm (configured in ~/.dotfiles/config/). Identify if any functionality depends on this behavior before modifying it. Goal is to avoid changing the terminal directory unless necessary.

---

### 78. Fix Himalaya SMTP authentication failure when sending emails
- **Effort**: 1-2 hours
- **Status**: [PLANNED]
- **Research Started**: 2026-02-13
- **Research Completed**: 2026-02-13
- **Planning Started**: 2026-02-13
- **Planning Completed**: 2026-02-13
- **Language**: neovim
- **Dependencies**: None
- **Research**: [research-001.md](078_fix_himalaya_smtp_authentication_failure/reports/research-001.md)
- **Plan**: [implementation-001.md](078_fix_himalaya_smtp_authentication_failure/plans/implementation-001.md)

**Description**: Fix Gmail SMTP authentication failure when sending emails via Himalaya (<leader>me). Error: "Authentication failed: Code: 535, Enhanced code: 5.7.8, Message: Username and Password not accepted". The error occurs with TLS connection attempts and persists through multiple retry attempts. Identify and fix the root cause of the SMTP credential configuration.

---
