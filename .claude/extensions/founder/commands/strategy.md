---
description: Go-to-market strategy development with positioning and channel analysis
allowed-tools: Skill, Bash(jq:*), Bash(git:*), Bash(date:*), Read
argument-hint: "[topic]" | --mode LAUNCH|SCALE|PIVOT|EXPAND
---

# /strategy Command

Go-to-market strategy command that develops positioning, channel strategy, and 90-day execution plans.

## Overview

This command produces GTM strategy artifacts through structured questioning. It uses forcing questions to define positioning, prioritize channels, and create actionable launch plans.

## Syntax

- `/strategy` - Start GTM strategy with interactive mode selection
- `/strategy B2B SaaS launch` - Start with context hints
- `/strategy --mode LAUNCH` - Skip mode selection, use LAUNCH mode

## Modes

| Mode | Posture | Focus |
|------|---------|-------|
| **LAUNCH** | Maximize splash | Awareness, differentiation, initial traction |
| **SCALE** | Optimize engine | CAC optimization, channel scaling, automation |
| **PIVOT** | Find new wedge | Customer segments, value prop testing |
| **EXPAND** | Adjacent markets | New segments, expansion playbook |

---

## CHECKPOINT 1: GATE IN

**Display header**:
```
[Strategy] Go-to-Market Strategy Development
```

### Step 1: Generate Session ID

```bash
session_id="sess_$(date +%s)_$(od -An -N3 -tx1 /dev/urandom | tr -d ' ')"
```

### Step 2: Parse Arguments

Parse $ARGUMENTS to extract:
- `topic`: Optional context hint (e.g., "B2B SaaS launch")
- `--mode`: Optional mode selection (LAUNCH, SCALE, PIVOT, EXPAND)

If no `--mode` flag, mode selection happens during execution.

### Step 3: Prepare Delegation Context

```json
{
  "topic": "optional context hint",
  "mode": "LAUNCH|SCALE|PIVOT|EXPAND or null for interactive",
  "output_dir": "founder/",
  "metadata": {
    "session_id": "sess_{timestamp}_{random}",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "strategy", "skill-strategy"]
  }
}
```

---

## STAGE 2: DELEGATE

**Invoke Skill tool**:

```
skill: "skill-strategy"
args: "topic={topic} mode={mode} session_id={session_id}"
```

The skill will:
1. Present mode selection (if not pre-selected)
2. Use forcing questions to develop positioning
3. Analyze and prioritize channels
4. Create 90-day launch plan
5. Define metrics and milestones
6. Return structured JSON result

---

## CHECKPOINT 2: GATE OUT

### Step 1: Validate Return

Check return from skill:
- Status is one of: generated, partial, failed
- Summary is non-empty and <100 tokens
- Artifacts array present with output file path

### Step 2: Display Result

**On success**:
```
GTM strategy generated.

Mode: {MODE}
Artifact: founder/gtm-strategy-{datetime}.md

Summary:
{summary}

Positioning:
For {target} who {problem}, {product} is a {category} that {benefit}.
Unlike {competitor}, we {differentiator}.

Top Channels:
1. {channel1} - CAC: ${CAC1}
2. {channel2} - CAC: ${CAC2}

Next: Review 90-day plan and assign owners
```

**On partial**:
```
GTM strategy partially completed.

{partial_progress}

Resume: /strategy --mode {mode}
```

**On failure**:
```
GTM strategy failed.

Error: {error_message}
Recovery: {recovery_guidance}
```

---

## Error Handling

### No Topic Provided

Not an error - agent will ask interactively.

### User Abandons Strategy

Return partial status with progress made:
```json
{
  "status": "partial",
  "partial_progress": {
    "sections_completed": ["positioning", "channels"],
    "sections_remaining": ["launch_plan", "metrics"]
  }
}
```

### Invalid Mode

```
Invalid mode: {provided}
Valid modes: LAUNCH, SCALE, PIVOT, EXPAND
```

---

## Output Artifacts

| Artifact | Location |
|----------|----------|
| GTM strategy | `founder/gtm-strategy-{datetime}.md` |

Artifact follows template at `@context/project/founder/templates/gtm-strategy.md`.
