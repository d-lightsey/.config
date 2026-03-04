# Context Loading Best Practices Guide

**Version**: 1.0
**Last Updated**: 2026-03-04
**Applies to**: OpenCode skill developers and agent system architects

## Introduction

Context loading determines how information is made available to AI agents during task execution. The choice between loading strategies directly impacts agent performance, output quality, and system reliability. This guide documents the two primary context loading models used in the OpenCode system: the **Push** model for critical context and the **Pull** model for optional reference material.

When agents lack necessary context, they may produce inconsistent outputs, deviate from established formats, or require additional tool calls to fetch information. Conversely, loading too much context wastes tokens and increases latency. The Push vs Pull strategy addresses this by distinguishing between context that MUST be available (Push) and context that MAY be referenced (Pull).

## Push Model: Critical Context Injection

### Definition

The Push model injects critical context directly into agent prompts via XML `<context_injection>` blocks declared in SKILL.md files. This context is loaded automatically before any agent execution begins.

### When to Use

Use the Push model when:

- Context is **required** for correct operation
- Context defines **strict formats** or **standards** that must be followed
- Context controls **workflow state transitions**
- Context provides **safety-critical** delegation patterns
- Missing the context would cause **incorrect behavior**

### XML Structure

```xml
<context_injection>
  <file path=".opencode/context/core/formats/plan-format.md" variable="plan_format" />
  <file path=".opencode/context/core/standards/status-markers.md" variable="status_markers" />
</context_injection>

<execution>
  <stage id="1" name="LoadContext">
    <action>Read context files defined in <context_injection></action>
  </stage>
  <stage id="2" name="Delegate">
    <action>Inject context into agent prompt using {variable_name}</action>
  </stage>
</execution>
```

### Execution Flow

1. **Declaration**: SKILL.md defines `<context_injection>` block with file paths and variable names
2. **Loading**: Skill executor reads files and stores content in named variables
3. **Injection**: Variables are substituted into agent prompts via `{variable_name}` syntax
4. **Execution**: Agent receives complete context at start, no additional reads needed

### Benefits

- **Reliability**: Agents cannot "forget" to load critical context
- **Consistency**: All agents receive identical versions of standards
- **Performance**: Eliminates redundant tool calls during execution
- **Maintainability**: Context dependencies are explicitly declared
- **Debugging**: Clear visibility into what context each skill requires

## Pull Model: On-Demand Context Loading

### Definition

The Pull model loads context on-demand via @-references in agent prompts or skill files. Context is only fetched when explicitly requested by an agent or user.

### When to Use

Use the Pull model when:

- Context is **optional reference material**
- Context provides **background information** but is not strictly required
- Context contains **code examples** that illustrate but do not enforce patterns
- Context files are **large** (>500 lines) and would bloat the context window
- Context changes **frequently** and should not be cached

### @-Reference Syntax

Reference context files using the @ notation in prompts:

```markdown
## Context References

Reference (do not load eagerly):
- Path: `.opencode/context/core/formats/return-metadata-file.md` - Metadata file schema
- Path: `.opencode/context/core/patterns/postflight-control.md` - Marker file protocol
```

In agent prompts:

```markdown
Create implementation plan for task {N}.

Refer to @.opencode/context/core/formats/plan-format.md for formatting standards.
```

### Execution Flow

1. **Reference**: Agent or prompt includes @-reference to context file
2. **Request**: System resolves reference and reads file contents
3. **Injection**: Content is inserted into the conversation at the reference point
4. **Use**: Agent can access the context for that specific interaction

### Benefits

- **Context efficiency**: Only load what is explicitly needed
- **Flexibility**: Easy to reference different files for different scenarios
- **Lower latency**: Smaller initial context for faster startup
- **Fresh content**: Always gets latest version of frequently changing files

## Comparison: Push vs Pull

| Characteristic | Push Model | Pull Model |
|---------------|------------|------------|
| **Loading timing** | Automatic at skill start | On-demand when referenced |
| **Context availability** | Always present in agent prompt | Fetched per interaction |
| **Use case** | Critical standards and formats | Optional documentation |
| **Agent awareness** | Transparent (injected automatically) | Explicit (must reference) |
| **Performance** | Higher initial load, fewer tool calls | Lower initial load, more tool calls |
| **Consistency** | Guaranteed identical context | Context may vary by request |
| **Best for** | Strict formats, workflow control | Examples, background docs |
| **File size** | Keep small (< 200 lines each) | Can reference larger files |
| **Example files** | plan-format.md, status-markers.md | code-examples.md, guides/*.md |

## Decision Framework

### Checklist for Choosing Push vs Pull

Answer these questions when deciding how to load context:

1. **Is this context required for correct operation?**
   - Yes -> Use **Push** model
   - No -> Consider Pull

2. **Is this context a strict format or standard?**
   - Yes -> Use **Push** model
   - No -> Consider Pull

3. **Is this context optional reference material?**
   - Yes -> Use **Pull** model
   - No -> Consider Push

4. **Is this context file >500 lines?**
   - Yes -> Consider **Pull** model to avoid bloat
   - No -> Can use either model

5. **Does missing this context cause incorrect behavior?**
   - Yes -> Use **Push** model
   - No -> Can use Pull

### Decision Tree

```
Context to load?
|
├─ Required for correct operation? ──YES──> Push
│   └─ Strict format/standard? ─────YES──> Push
│       └─ Controls workflow? ──────YES──> Push
│           └─ Safety-critical? ────YES──> Push
│
└─ Optional reference material? ────YES──> Pull
    └─ Large file (>500 lines)? ──YES──> Pull
        └─ Changes frequently? ───YES──> Pull
            └─ Code examples? ──────YES──> Pull
```

## Implementation Guide for Skill Developers

### Step 1: Identify Critical Context

Review your skill's requirements and identify which context files are essential:

- Format standards that MUST be followed
- Status markers that control workflow
- Safety-critical patterns or rules

### Step 2: Define context_injection Block

Add a `<context_injection>` block near the top of your SKILL.md file:

```xml
<context_injection>
  <file path=".opencode/context/core/formats/plan-format.md" variable="plan_format" />
  <file path=".opencode/context/core/standards/status-markers.md" variable="status_markers" />
  <file path=".opencode/context/core/workflows/task-breakdown.md" variable="task_breakdown" />
</context_injection>
```

Guidelines:
- Use descriptive variable names (e.g., `plan_format`, not `format1`)
- Keep total injected context under 1000 lines
- Only include files that are truly critical

### Step 3: Update Execution Stages

Add a LoadContext stage as the first execution stage:

```xml
<execution>
  <stage id="1" name="LoadContext">
    <action>Read context files defined in <context_injection></action>
  </stage>
  <stage id="2" name="Delegate">
    <action>Call Task tool with injected context</action>
  </stage>
</execution>
```

### Step 4: Inject Context into Agent Prompts

Use the `{variable_name}` syntax to inject context into agent prompts:

```markdown
Call `Task` tool with prompt:
"""
Create implementation plan for task {N}.

<system_context>
Using the following format standards:
{plan_format}

Following these status guidelines:
{status_markers}

With this task breakdown approach:
{task_breakdown}
</system_context>
"""
```

### Step 5: Document Pull References

For optional context, document references in your skill's documentation:

```markdown
## Optional Context

Reference these files as needed:
- @.opencode/context/core/examples/lean4-proof-patterns.md
- @.opencode/docs/guides/error-handling.md
```

## Examples from Core Skills

### skill-planner

**Injected files**: 3

```xml
<context_injection>
  <file path=".opencode/context/core/formats/plan-format.md" variable="plan_format" />
  <file path=".opencode/context/core/standards/status-markers.md" variable="status_markers" />
  <file path=".opencode/context/core/workflows/task-breakdown.md" variable="task_breakdown" />
</context_injection>
```

**Why Push**: Plan format and status markers are strict standards. Missing them would result in incorrectly formatted plans.

### skill-researcher

**Injected files**: 2

```xml
<context_injection>
  <file path=".opencode/context/core/formats/report-format.md" variable="report_format" />
  <file path=".opencode/context/core/standards/status-markers.md" variable="status_markers" />
</context_injection>
```

**Why Push**: Report format ensures consistent research output. Status markers coordinate with the orchestrator.

### skill-implementer

**Injected files**: 4

```xml
<context_injection>
  <file path=".opencode/context/core/patterns/return-metadata-file.md" variable="return_metadata" />
  <file path=".opencode/context/core/patterns/postflight-control.md" variable="postflight_control" />
  <file path=".opencode/context/core/patterns/file-metadata-exchange.md" variable="file_metadata" />
  <file path=".opencode/context/core/patterns/jq-escaping-workarounds.md" variable="jq_workarounds" />
</context_injection>
```

**Why Push**: Implementation requires strict adherence to return metadata and postflight protocols. Missing these would break state synchronization.

### skill-orchestrator

**Injected files**: 2

```xml
<context_injection>
  <file path=".opencode/context/core/patterns/orchestration-core.md" variable="orchestration" />
  <file path=".opencode/context/core/patterns/state-management.md" variable="state_management" />
</context_injection>
```

**Why Push**: Orchestration patterns define how to coordinate skills safely. State management ensures proper status tracking.

## Migration Guide: From Pull to Push

### When to Migrate

Migrate skills from Pull to Push model when:

- Agents inconsistently follow formats or standards
- Context is frequently "forgotten" in agent execution
- You need stricter workflow control
- Output quality varies due to missing context

### Migration Steps

1. **Identify critical context**: Review which files are essential but often missed
2. **Add context_injection block**: Define files and variable names in SKILL.md
3. **Add LoadContext stage**: Make it the first execution stage
4. **Update delegation prompts**: Inject context using `{variable_name}` syntax
5. **Remove redundant @-references**: Clean up old Pull references that are now Push
6. **Test thoroughly**: Verify agents receive and use the context correctly
7. **Update documentation**: Note the change in skill changelog

### Example Migration

**Before (Pull model)**:
```xml
<execution>
  <stage id="1" name="Delegate">
    <action>Create implementation plan. Refer to @.opencode/context/core/formats/plan-format.md</action>
  </stage>
</execution>
```

**After (Push model)**:
```xml
<context_injection>
  <file path=".opencode/context/core/formats/plan-format.md" variable="plan_format" />
</context_injection>

<execution>
  <stage id="1" name="LoadContext">
    <action>Read context files defined in <context_injection></action>
  </stage>
  <stage id="2" name="Delegate">
    <action>Call Task tool with injected {plan_format}</action>
  </stage>
</execution>
```

## Related Documentation

### Standards and Specifications

- [skill-structure.md](../../skills/skill-structure.md) v2.0 - Defines the Push Context standard for SKILL.md files
- [context/index.md](../../context/index.md) - Catalog of Pull Context files available for @-references

### Historical Reference

- [context-loading-best-practices.md](../../../../.claude/docs/guides/context-loading-best-practices.md) - Historical guide focusing on Pull model (deprecated)

### Skill Examples

- [skill-planner/SKILL.md](../../../skills/skill-planner/SKILL.md) - 3 injected files example
- [skill-researcher/SKILL.md](../../../skills/skill-researcher/SKILL.md) - 2 injected files example
- [skill-implementer/SKILL.md](../../../skills/skill-implementer/SKILL.md) - 4 injected files example
- [skill-orchestrator/SKILL.md](../../../skills/skill-orchestrator/SKILL.md) - 2 injected files example

## Summary

### Key Takeaways

1. **Push Model** injects critical context automatically via `<context_injection>` blocks in SKILL.md files. Use it for strict formats, standards, and workflow-critical information.

2. **Pull Model** loads context on-demand via @-references. Use it for optional documentation, examples, and large reference files.

3. **Hybrid approach** is recommended: Push for must-follow rules, Pull for reference material. Core skills use Push for 2-5 context files to ensure consistent behavior.

4. **Decision checklist**: Is it required? Use Push. Is it optional? Use Pull. Is it large? Consider Pull. Is it strict? Use Push.

5. **Implementation**: Add `<context_injection>` block, include LoadContext stage, inject with `{variable}` syntax in prompts.

### For Skill Developers

When creating new skills:

1. Start by identifying which context is critical vs optional
2. Implement Push model for critical context first
3. Document Pull references for optional context
4. Follow examples from skill-planner, skill-researcher, and skill-implementer
5. Keep total pushed context under 1000 lines for performance

By following these best practices, you ensure agents have the context they need to produce consistent, high-quality output while maintaining system efficiency and clarity.
