# Agent Frontmatter Standard

**Created**: 2026-02-24
**Purpose**: Define YAML frontmatter requirements for agent files

## Overview

Agent files in `.claude/agents/` use YAML frontmatter to declare metadata that the Claude Code system and invoking skills use for agent selection, model enforcement, and capability discovery.

## Required Fields

```yaml
---
name: {agent-name}
description: {brief description of agent purpose}
---
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Agent identifier (e.g., `general-research-agent`) |
| `description` | string | Yes | Brief description of agent purpose and capabilities |

## Optional Fields

```yaml
---
name: general-research-agent
description: Research general tasks using web search and codebase exploration
model: sonnet
---
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `model` | string | No | Preferred model for this agent (`opus`, `sonnet`) |

## Model Field

The `model` field allows explicit model selection for agents that benefit from specific model capabilities.

### Default Policy

**Non-Lean agents default to Sonnet** for cost efficiency. All 7 core agents and all non-Lean extension agents declare `model: sonnet`.

**Lean4 agents retain Opus** (`lean-research-agent`, `lean-implementation-agent`) because Lean4 proof work requires deep mathematical reasoning that benefits from Opus's superior capabilities.

### Values

| Value | Use Case | Rationale |
|-------|----------|-----------|
| `opus` | Lean4 proof tasks requiring deep mathematical reasoning | Superior analytical and reasoning capabilities; reserved for Lean4 |
| `sonnet` | General research, planning, implementation, coordination | Cost-effective, fast, good quality for most tasks |
| (omitted) | Default behavior | System chooses based on context |

### Usage Guidelines

**Use `model: opus` for**:
- Lean4 research and implementation agents (mathematical reasoning)
- Any future agent requiring provably superior reasoning quality

**Use `model: sonnet` for**:
- General research agents (default)
- Planning and implementation agents (default)
- Team orchestration skills (lightweight coordination)
- All non-Lean extension agents

**Omit model field when**:
- Model flexibility is desired
- Default model selection is appropriate

### Runtime Override Flags

Users can override the agent's default model at invocation time using flags on `/research` and `/implement` commands:

| Flag | Maps to | Behavior |
|------|---------|----------|
| `--fast` | `sonnet` | Explicit low-cost mode (Sonnet) |
| `--hard` | `opus` | Explicit high-effort mode (Opus) |
| `--opus` | `opus` | Explicit Opus (alias for `--hard`) |

If multiple flags are provided, the last one wins. These flags are passed as `model_flag` in the delegation context to the skill and subagent.

**Examples**:
```
/research 42 --opus        # Force Opus for this research task
/implement 42 --hard       # Force Opus for this implementation
/research 42 --fast        # Explicit Sonnet (same as default)
```

### Examples

```yaml
---
name: general-research-agent
description: Research general tasks using web search and codebase exploration
model: sonnet
---
```

**Rationale**: General research agents use Sonnet for cost efficiency. Use `--hard` or `--opus` at invocation time when a specific research task requires deeper reasoning.

```yaml
---
name: lean-research-agent
description: Research and prove Lean4 theorems
model: opus
---
```

**Rationale**: Lean4 proof work requires deep mathematical reasoning; Opus is retained for all Lean4 agents.

## Validation

Agent frontmatter is validated during:
1. Agent file creation (via `/meta` command)
2. Agent invocation (by skill preflight)

### Validation Rules

1. `name` must be present and non-empty
2. `description` must be present and non-empty
3. `model`, if present, must be one of: `opus`, `sonnet`

## Examples

### Research Agent

```yaml
---
name: general-research-agent
description: Research general tasks using web search and codebase exploration
model: sonnet
---
```

### Implementation Agent

```yaml
---
name: general-implementation-agent
description: Implement general, meta, and markdown tasks from plans
model: sonnet
---
```

### Planning Agent

```yaml
---
name: planner-agent
description: Create phased implementation plans from research findings
model: sonnet
---
```

### Lean4 Research Agent (retains Opus)

```yaml
---
name: lean-research-agent
description: Research and prove Lean4 theorems using Mathlib
model: opus
---
```

## Migration

To add model enforcement to existing agents:

1. Open agent file (e.g., `.claude/agents/general-research-agent.md`)
2. Add `model: sonnet` (default for non-Lean agents) or `model: opus` (Lean4 only) to frontmatter
3. Document rationale in agent comments

No other changes are required - the Task tool will respect the model field when spawning agents.

**Note**: As of task 442, all non-Lean agents have been migrated to `model: sonnet`. Lean4 agents retain `model: opus`.

## Related Documentation

- [Creating Agents Guide](.claude/docs/guides/creating-agents.md)
- [Agent Template](.claude/docs/templates/agent-template.md)
- [Context Discovery Patterns](.claude/context/patterns/context-discovery.md)
