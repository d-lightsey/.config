---
name: skill-strategy
description: Go-to-market strategy development with positioning and channels
allowed-tools: Task
---

# Strategy Skill

Thin wrapper that routes GTM strategy requests to the `strategy-agent`.

## Context Pointers

Reference (do not load eagerly):
- Path: `.claude/context/core/formats/subagent-return.md`
- Purpose: Return validation
- Load at: Subagent execution only

Note: This skill is a thin wrapper. Context is loaded by the delegated agent, not this skill.

## Trigger Conditions

This skill activates when:

### Direct Invocation
- User explicitly runs `/strategy` command
- User requests GTM strategy in conversation

### Implicit Invocation (during task implementation)

When an implementing agent encounters any of these patterns:

**Plan step language patterns**:
- "Develop GTM strategy"
- "Create go-to-market plan"
- "Define positioning"
- "Channel strategy"
- "Launch planning"

**Target mentions**:
- "go-to-market"
- "GTM strategy"
- "positioning statement"
- "launch plan"
- "channel prioritization"

### When NOT to trigger

Do not invoke for:
- Market sizing (use skill-market)
- Competitive analysis (use skill-analyze)
- General business research (use skill-researcher)
- Product roadmap (not GTM)

---

## Execution

### 1. Input Validation

Validate inputs:
- `topic` - Optional, string context hint
- `mode` - Optional, one of: LAUNCH, SCALE, PIVOT, EXPAND
- `session_id` - Required, string

```bash
# Validate session_id is present
if [ -z "$session_id" ]; then
  return error "session_id is required"
fi

# Validate mode if provided
if [ -n "$mode" ]; then
  case "$mode" in
    LAUNCH|SCALE|PIVOT|EXPAND) ;;
    *) return error "Invalid mode: $mode. Must be LAUNCH, SCALE, PIVOT, or EXPAND" ;;
  esac
fi
```

### 2. Context Preparation

Prepare delegation context:

```json
{
  "topic": "optional context hint",
  "mode": "LAUNCH|SCALE|PIVOT|EXPAND or null",
  "output_dir": "founder/",
  "metadata": {
    "session_id": "sess_{timestamp}_{random}",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "strategy", "skill-strategy"]
  }
}
```

### 3. Invoke Agent

**CRITICAL**: You MUST use the **Task** tool to spawn the agent.

**Required Tool Invocation**:
```
Tool: Task (NOT Skill)
Parameters:
  - subagent_type: "strategy-agent"
  - prompt: [Include topic, mode, output_dir, metadata]
  - description: "GTM strategy development with positioning and channels"
```

The agent will:
- Present mode selection if not pre-selected
- Use forcing questions for positioning
- Analyze and prioritize channels
- Create 90-day launch plan
- Define metrics and milestones
- Return standardized JSON result

### 4. Return Validation

Validate return matches `subagent-return.md` schema:
- Status is one of: generated, partial, failed
- Summary is non-empty and <100 tokens
- Artifacts array present with output file path
- Metadata contains mode and channel count

### 5. Return Propagation

Return validated result to caller without modification.

---

## Return Format

Expected successful return:
```json
{
  "status": "generated",
  "summary": "Generated GTM strategy for B2B SaaS launch. Primary channel: Content/SEO. 90-day plan with 12 milestones.",
  "artifacts": [
    {
      "type": "implementation",
      "path": "/absolute/path/to/founder/gtm-strategy-20260318.md",
      "summary": "GTM strategy with positioning, channel prioritization, and 90-day plan"
    }
  ],
  "metadata": {
    "session_id": "sess_...",
    "agent_type": "strategy-agent",
    "delegation_depth": 2,
    "mode": "LAUNCH",
    "channels_evaluated": 9,
    "channels_prioritized": 3,
    "milestones_defined": 12
  },
  "next_steps": "Review 90-day plan and assign owners. Consider /market for market sizing context."
}
```

---

## Error Handling

### Session ID Missing
Return immediately with failed status.

### Agent Errors
Pass through the agent's error return verbatim.

### User Abandonment
Return partial status with progress made.
