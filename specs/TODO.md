---
next_project_number: 267
---

# TODO

## Tasks


### 262. Refactor project-agent to generate research report instead of timeline
- **Effort**: 2-3 hours
- **Status**: [RESEARCHED]
- **Language**: meta
- **Dependencies**: None
- **Research**: [01_meta-research.md](262_refactor_project_agent_research_report/reports/01_meta-research.md)

**Description**: Refactor project-agent to follow the standard research agent pattern. Currently it directly generates the timeline Typst file; refactor to gather project data through forcing questions and output a research report containing WBS data, PERT estimates, and resource allocation data in a format for planner-agent consumption.

---

### 263. Update skill-project for research-only workflow
- **Effort**: 1-2 hours
- **Status**: [RESEARCHED]
- **Language**: meta
- **Dependencies**: Task #262
- **Research**: [01_meta-research.md](263_skill_project_research_workflow/reports/01_meta-research.md)

**Description**: Modify skill-project to route to project-agent for research only, creating a research report at specs/{NNN}_{SLUG}/reports/ and stopping at [RESEARCHED] status. Remove timeline generation and PLANNED/TRACKED/REPORTED status handling.

---

### 264. Create project-specific planning context for planner-agent
- **Effort**: 1 hour
- **Status**: [RESEARCHED]
- **Language**: meta
- **Dependencies**: Task #262
- **Research**: [01_meta-research.md](264_project_planning_context/reports/01_meta-research.md)

**Description**: Create context file teaching planner-agent to create implementation plans for project timeline tasks. Define standard phases for: timeline structure generation, PERT calculations and critical path, resource allocation matrix, and Gantt chart visualization.

---

### 265. Extend founder-implement-agent for project timeline generation
- **Effort**: 2-3 hours
- **Status**: [RESEARCHED]
- **Language**: meta
- **Dependencies**: Task #263, Task #264
- **Research**: [01_meta-research.md](265_founder_implement_project_timeline/reports/01_meta-research.md)

**Description**: Add project timeline generation capability to founder-implement-agent. Read implementation plan, use research data, and generate final Typst timeline file at strategy/timelines/{project-slug}.typ. Handle PLAN/TRACK/REPORT modes during implementation.

---

### 266. Update /project command documentation and workflow
- **Effort**: 30 min
- **Status**: [RESEARCHED]
- **Language**: meta
- **Dependencies**: Task #262, Task #263, Task #264, Task #265
- **Research**: [01_meta-research.md](266_project_command_documentation/reports/01_meta-research.md)

**Description**: Update project.md command to reflect the new standard workflow: create task -> /research -> /plan -> /implement. Update Workflow Summary section, STAGE 2 delegation, CHECKPOINT 2 output, and examples.

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

## Recommended Order

### Founder Extension Refactoring (dependency chain)
1. **262** -> plan -> implement (foundational - refactor project-agent)
2. **263** -> plan -> implement (after #262 - update skill-project)
3. **264** -> plan -> implement (after #262, parallel with #263 - planning context)
4. **265** -> plan -> implement (after #263, #264 - implementation agent)
5. **266** -> plan -> implement (after all above - documentation)

### Other Tasks
6. **87** -> plan (independent)
7. **78** -> implement (independent)
