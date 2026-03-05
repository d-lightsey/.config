# Implementation Plan: Enforce Workflow Command Delegation to Prevent Direct Implementation [REVISED]

- **Task**: OC_135 - enforce_workflow_command_delegation_to_prevent_direct_implementation
- **Status**: [NOT STARTED]
- **Effort**: 12 hours
- **Dependencies**: None
- **Research Inputs**: 
  - specs/OC_135_enforce_workflow_command_delegation_to_prevent_direct_implementation/reports/research-001.md
  - specs/OC_135_enforce_workflow_command_delegation_to_prevent_direct_implementation/reports/research-002.md [COMPARATIVE ANALYSIS]
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**:
  - .opencode/context/core/formats/plan-format.md
  - .opencode/context/core/standards/status-markers.md
  - .opencode/context/core/standards/documentation-standards.md
  - .opencode/context/core/standards/task-management.md
- **Type**: markdown

---

## Overview

This revised implementation plan addresses the root cause identified in research-002.md: **.opencode/ command specifications are written as implementation guides with step-by-step instructions, causing the main agent to execute them directly instead of delegating to skills.**

The `.claude/` system works correctly because its commands are pure routing specifications that explicitly invoke `Skill(tool)` with "Invoke NOW" directives. The `.opencode/` system fails because commands contain detailed Steps 1-9 that agents interpret as implementation instructions.

**Key Finding**: The solution requires redesigning ALL workflow commands (9 commands) from implementation guides to routing specifications, adopting `.claude/` skill patterns (postflight markers, internal status management), and creating a command interception layer.

---

## Research Integration

### Research-001: Missing Command Interception Layer
- System architecture correctly designed (Commands -> Skills -> Agents)
- Skills use `context: fork` for proper delegation
- Missing: Command interception mechanism

### Research-002: Comparative Analysis [CRITICAL]
**Key Differences Identified**:

| Aspect | .claude/ (Works) | .opencode/ (Broken) |
|--------|------------------|---------------------|
| **Command Structure** | 3 checkpoints + Skill invocation | 9 detailed implementation steps |
| **Skill Pattern** | 11-stage flow with postflight markers | 4-stage thin wrapper |
| **Delegation** | "Invoke Skill tool NOW" explicit | Implicit, unclear |
| **Postflight** | Skill-internal, atomic | External, ambiguous |
| **Result** | Proper routing | Direct execution |

**Industry Best Practices Confirmed**:
1. "Orchestrator must never execute" (Mikhail Rogov, 2026)
2. Router pattern: Commands as pure routing signals
3. Skill-first architecture: Commands thin, skills thick
4. Postflight markers prevent premature termination

---

## Goals & Non-Goals

### Goals
- [ ] Redesign all 9 workflow commands as routing specifications
- [ ] Add explicit "DO NOT implement" enforcement directives
- [ ] Adopt `.claude/` postflight marker pattern in all skills
- [ ] Implement skill-internal status management
- [ ] Create command router layer for interception
- [ ] Ensure proper `context: fork` isolation
- [ ] Test all workflow commands end-to-end

### Non-Goals
- Creating new workflow commands
- Changing subagent implementations
- Modifying core architecture (it's correct, just poorly specified)
- Breaking non-workflow commands
- Adding features beyond routing enforcement

---

## Revised Scope: 9 Commands to Fix

Based on research-002, these commands need redesign:

1. `/research` - 11 steps currently
2. `/plan` - 9 steps currently  
3. `/implement` - multiple steps
4. `/revise` - 21 detailed steps with validation
5. `/review` - 11 steps with roadmap integration
6. `/errors` - error analysis workflow
7. `/todo` - task management workflow
8. `/refresh` - cleanup workflow
9. `/learn` - tag scanning workflow

**Total**: ~90+ implementation steps across all commands that need to become routing specs.

---

## Implementation Phases [REVISED]

### Phase 1: Command Specification Redesign (Priority 1) [NOT STARTED]

**Goal**: Redesign all 9 workflow commands from implementation guides to routing specifications

**Understanding the Problem**:
Current commands contain detailed steps like:
- "Step 1: Lookup task in state.json"
- "Step 2: Validate status"
- "Step 3: Update status to PLANNING"

These look like instructions to execute, so the main agent executes them directly.

**Required New Structure**:
```markdown
---
description: Brief purpose
---

Route to skill-{name} for {operation}.

**Command Pattern**: /{command} <OC_N> [args]

**Routing**:
- Target: skill-{name}
- Subagent: {agent-name}
- Context: fork

**Validation**:
- Task exists in state.json
- Status allows {operation}

**Skill Arguments**:
- task_number: {N}
- [other args]

**DO NOT**: [list of prohibitions]
**DO**: [routing directive]
```

**Tasks**:
- [ ] Redesign `/research` command spec
- [ ] Redesign `/plan` command spec  
- [ ] Redesign `/implement` command spec
- [ ] Redesign `/revise` command spec
- [ ] Redesign `/review` command spec
- [ ] Redesign `/errors` command spec
- [ ] Redesign `/todo` command spec
- [ ] Redesign `/refresh` command spec
- [ ] Redesign `/learn` command spec

**Timing**: 4 hours

**Verification**:
- [ ] All 9 commands have routing-only structure
- [ ] No implementation steps remain
- [ ] All have explicit Skill tool invocation
- [ ] All have "DO NOT implement" warnings

---

### Phase 2: Skill Postflight Pattern Adoption (Priority 2) [NOT STARTED]

**Goal**: Update all skills to use `.claude/` 11-stage pattern with internal postflight

**Key Patterns from .claude/skill-planner**:
1. **Stage 1**: Input Validation
2. **Stage 2**: Preflight Status Update
3. **Stage 3**: Create Postflight Marker (`.postflight-pending`)
4. **Stage 4**: Prepare Delegation Context
5. **Stage 5**: Invoke Subagent (CRITICAL: Use Task tool)
6. **Stage 6**: Parse Subagent Return (read metadata file)
7. **Stage 7**: Update Task Status (postflight)
8. **Stage 8**: Link Artifacts
9. **Stage 9**: Git Commit
10. **Stage 10**: Cleanup markers
11. **Stage 11**: Return Brief Summary

**Critical: Postflight Marker Pattern**:
```bash
# Create marker BEFORE subagent
cat > "specs/{NNN}_{SLUG}/.postflight-pending" << EOF
{
  "session_id": "${session_id}",
  "skill": "skill-{name}",
  "task_number": ${task_number},
  "reason": "Postflight pending: status update, artifact linking, git commit"
}
EOF

# Cleanup AFTER all operations complete
rm -f "specs/{NNN}_{SLUG}/.postflight-pending"
rm -f "specs/{NNN}_{SLUG}/.return-meta.json"
```

**Skills to Update**:
- [ ] skill-researcher
- [ ] skill-planner
- [ ] skill-implementer
- [ ] skill-reviewer
- [ ] skill-todo
- [ ] skill-refresh
- [ ] skill-learn
- [ ] skill-errors
- [ ] skill-meta

**Timing**: 3 hours

**Verification**:
- [ ] All skills have postflight marker pattern
- [ ] All skills handle status internally
- [ ] All skills link artifacts before return
- [ ] All skills commit changes before return

---

### Phase 3: Command Router Implementation (Priority 3) [NOT STARTED]

**Goal**: Create command interception layer at prompt entry point

**Architecture**:
```
User Input
    |
    v
Command Parser (detects /^\/\w+ \d+/)
    |
    v
Command Router
    |-- /research --> skill-researcher
    |-- /plan --> skill-planner
    |-- /implement --> skill-implementer
    |-- /revise --> skill-revisor
    |-- /review --> skill-reviewer
    |-- /errors --> skill-errors
    |-- /todo --> skill-todo
    |-- /refresh --> skill-refresh
    |-- /learn --> skill-learn
    |-- /meta --> skill-meta
    v
Skill (context: fork)
    v
Subagent (isolated context)
```

**Tasks**:
- [ ] Create `.opencode/agent/command-router.md`
- [ ] Implement command detection: `/^\/(research|plan|implement|revise|review|errors|todo|refresh|learn|meta)\s+(\d+)/`
- [ ] Implement routing table
- [ ] Add validation layer (task exists, status allows)
- [ ] Add fallback to main agent for non-workflow commands
- [ ] Add error handling for invalid commands

**Timing**: 2 hours

**Verification**:
- [ ] Router intercepts all 9 workflow commands
- [ ] Router validates before delegating
- [ ] Non-workflow commands pass through
- [ ] Error messages are clear

---

### Phase 4: Integration and Testing (Priority 4) [NOT STARTED]

**Goal**: Connect router, test all workflows, ensure delegation chains work

**Integration Steps**:
1. Connect router to prompt processing entry point
2. Configure router priority over main agent
3. Test each command with valid inputs
4. Test error cases (invalid task, wrong status)
5. Test non-workflow commands unaffected

**Testing Matrix**:

| Command | Valid Input | Invalid Task | Wrong Status | Non-Workflow |
|---------|-------------|--------------|--------------|--------------|
| /research | Pass | Fail gracefully | Warn | Pass through |
| /plan | Pass | Fail gracefully | Warn | Pass through |
| /implement | Pass | Fail gracefully | Block | Pass through |
| /revise | Pass | Fail gracefully | Warn | Pass through |
| /review | Pass | N/A | N/A | Pass through |
| /errors | Pass | N/A | N/A | Pass through |
| /todo | Pass | N/A | N/A | Pass through |
| /refresh | Pass | N/A | N/A | Pass through |
| /learn | Pass | N/A | N/A | Pass through |

**Tasks**:
- [ ] Connect router to entry point
- [ ] Test `/research` end-to-end
- [ ] Test `/plan` end-to-end
- [ ] Test `/implement` end-to-end
- [ ] Test `/revise` end-to-end
- [ ] Test `/review` end-to-end
- [ ] Test other commands
- [ ] Verify non-workflow commands unaffected
- [ ] Document test results

**Timing**: 2 hours

**Verification**:
- [ ] All 9 commands route correctly
- [ ] Status transitions work properly
- [ ] Artifacts created by subagents
- [ ] Main agent never executes implementation

---

### Phase 5: Documentation and Rollout [NOT STARTED]

**Goal**: Document new patterns, update guides, ensure team can maintain

**Documentation Updates**:
- [ ] Update `.opencode/commands/README.md` with new command structure
- [ ] Update `.opencode/skills/README.md` with postflight pattern
- [ ] Add `.opencode/docs/guides/command-routing.md`
- [ ] Add examples of correct vs incorrect command specs
- [ ] Document troubleshooting for routing issues

**Migration Guide**:
- How to convert old command spec to new routing spec
- How to add postflight markers to new skills
- How to test routing in development

**Timing**: 1 hour

**Verification**:
- [ ] All documentation updated
- [ ] Examples show correct patterns
- [ ] Troubleshooting guide covers common issues

---

## Risks & Mitigations [REVISED]

| Risk | Impact | Mitigation |
|------|--------|------------|
| Breaking existing workflows | **CRITICAL** | Phase approach: 1) Redesign specs (safe), 2) Add postflight (backward compat), 3) Add router (feature flag), 4) Integration (thorough testing) |
| Commands bypass router | **HIGH** | Implement router at lowest entry point; add logging for all routing decisions |
| Skills don't adopt postflight | **HIGH** | Update all skills in Phase 2; provide template; verify with checklist |
| Main agent still executes | **HIGH** | Add explicit "DO NOT" warnings; add validation in router; log all direct executions |
| Task number ambiguity | **LOW** | Normalize both "135" and "OC_135" in router; document in spec |
| Context size issues | **LOW** | Router is small; forked context keeps main clean |
| Rollback complexity | **MEDIUM** | Each phase independently revertible; git tags at each phase |

---

## Dependencies

- None (self-contained within .opencode/)
- Requires understanding of .claude/ patterns (researched in research-002.md)

---

## Success Criteria

### Phase 1 Success
- [ ] All 9 command specs are routing-only (no implementation steps)
- [ ] Each spec has explicit Skill tool invocation directive
- [ ] Each spec has "DO NOT implement" warning section

### Phase 2 Success
- [ ] All skills create postflight markers
- [ ] All skills handle status/artifacts/commits internally
- [ ] No skill returns before postflight complete

### Phase 3 Success
- [ ] Router intercepts all 9 workflow commands
- [ ] Router validates tasks before routing
- [ ] Router never executes implementation

### Phase 4 Success
- [ ] All 9 commands tested and working
- [ ] Non-workflow commands unaffected
- [ ] No direct execution by main agent observed

### Phase 5 Success
- [ ] Documentation complete
- [ ] Team can create new commands following patterns
- [ ] Troubleshooting guide resolves common issues

---

## Total Estimate

**Time**: 12 hours (revised from 8 hours)
**Complexity**: High
**Phases**: 5 phases
**Commands Affected**: 9 workflow commands
**Risk Level**: High (changes core command infrastructure)

**Phase Breakdown**:
- Phase 1: 4 hours (9 commands x ~25 min each)
- Phase 2: 3 hours (9 skills x ~20 min each)
- Phase 3: 2 hours (router + validation)
- Phase 4: 2 hours (integration + testing)
- Phase 5: 1 hour (documentation)

---

## Comparison: Old vs New Plan

| Aspect | Original Plan (001) | Revised Plan (002) |
|--------|---------------------|-------------------|
| **Root Cause** | Missing router only | Commands written as implementation guides |
| **Scope** | 4 commands + router | 9 commands + skill patterns + router |
| **Primary Fix** | Add router | Redesign commands first, then router |
| **Skill Changes** | Minimal | Major: postflight patterns |
| **Effort** | 8 hours | 12 hours |
| **Priority** | Router first | Command redesign first |

---

## Next Steps After Completion

1. **Monitor**: Watch for any commands that still execute directly
2. **Audit**: Review new commands created after this fix
3. **Template**: Create command template for future commands
4. **Training**: Document patterns for team members

---

**Revised**: 2026-03-05 (incorporating research-002 findings)
**Plan Version**: 002
**Previous Plan**: [implementation-001.md](./implementation-001.md)
