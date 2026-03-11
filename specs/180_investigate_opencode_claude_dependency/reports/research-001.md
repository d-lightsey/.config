# Investigation Report: .opencode/ Dependency on .claude/ MCP Server Settings

**Task**: 180 - Investigate .opencode/ dependency on .claude/ MCP server settings  
**Date**: 2026-03-11  
**Status**: Investigation Complete  
**Related**: Task 179 (data directory loading bug), Task 178 (MCP port configuration)

---

## Problem Summary

When loading the opencode system in the Website repository (`/home/benjamin/Projects/Logos/Website/`) using `<leader>ao` to activate the memory extension, the system fails with:

```
Configuration is invalid at /home/benjamin/Projects/Logos/Website/opencode.json: 
bad file reference: "{file:.opencode/agents/web-research.md}" 
/home/benjamin/Projects/Logos/Website/.opencode/agents/web-research.md does not exist
```

## Investigation Steps

### 1. Examined the Website Repository Structure

The Website repo has:
- `opencode.json` - Configuration with agent definitions
- Empty `.opencode/agents/` directory - No agent files present
- References to agents using `{file:...}` syntax

### 2. Examined the Memory Extension

Location: `/home/benjamin/.config/nvim/.opencode/extensions/memory/`

**What it provides** (from `manifest.json`):
```json
"provides": {
  "commands": ["learn.md"],
  "skills": ["skill-memory"],
  "context": ["project/memory"],
  "data": ["memory"],
  "hooks": []
}
```

**What it does NOT provide**:
- `agents/` directory - Does not exist
- No agent files like `web-research.md`, `neovim-research.md`, etc.

### 3. Analyzed the Extension Loader Mechanism

File: `lua/neotex/plugins/ai/shared/extensions/loader.lua`

The loader copies files based on the `provides` section in the manifest:
- `copy_simple_files()` - Copies agents, commands, rules
- `copy_skill_dirs()` - Copies skills recursively
- `copy_context_dirs()` - Copies context preserving structure
- `copy_data_dirs()` - Copies data with merge-copy semantics

**Key finding**: The memory extension manifest has NO `agents` in its `provides`, so no agents are copied.

### 4. What the Website Repo Expects

From `Website/opencode.json`:
- `web-research` agent → expects `.opencode/agents/web-research.md`
- `neovim-research` agent → expects `.opencode/agents/neovim-research.md`
- `general-research` agent → expects `.opencode/agents/general-research.md`
- `task-planner` agent → expects `.opencode/agents/task-planner.md`
- `web-implementation` agent → expects `.opencode/agents/web-implementation.md`
- `neovim-implementation` agent → expects `.opencode/agents/neovim-implementation.md`
- `general-implementation` agent → expects `.opencode/agents/general-implementation.md`
- `meta-builder` agent → expects `.opencode/agents/meta-builder.md`
- `document-converter` agent → expects `.opencode/agents/document-converter.md`
- `code-reviewer` agent - defined inline (no file reference)

None of these agent files exist in the Website repo's `.opencode/agents/` directory.

### 5. Examined the nvim Config Structure

The nvim config (`~/.config/nvim/.opencode/`) has:
- `agent/subagents/` - Contains agents like `general-research-agent.md`, `planner-agent.md`, etc.
- `commands/` - Various command definitions
- `skills/` - Various skill definitions

**Note**: The agents are in `agent/subagents/` (OpenCode convention), not `agents/`.

## Root Cause

The Website repository's `opencode.json` was created with agent references that assume the full opencode agent system is present. However:

1. **The memory extension only provides memory-specific functionality** (commands, skills, context, data)
2. **The memory extension does NOT provide general-purpose agents** (web-research, neovim-research, etc.)
3. **The extension loader only copies what the manifest declares in `provides`**
4. **No extension currently exists that provides the agents** the Website repo expects

## Attempted Solution (Incorrect)

Initially attempted to add `web-research.md` to the memory extension, but this was **incorrect** because:
- Web research has nothing to do with memory functionality
- The memory extension should remain focused on its core purpose
- Adding unrelated agents would bloat the extension

**This change was reverted.**

## Findings

### What Exists in the Memory Extension

**Commands**:
- `learn.md` - Command for memory creation and management

**Skills**:
- `skill-memory/` - Skill for memory operations

**Context**:
- `project/memory/memory-setup.md`
- `project/memory/memory-troubleshooting.md`
- `project/memory/learn-usage.md`
- `project/memory/knowledge-capture-usage.md`
- `project/memory/README.md`

**Data** (vault skeleton):
- `memory/00-Inbox/`
- `memory/10-Memories/`
- `memory/20-Indices/`
- `memory/30-Templates/`

### What the Website Repo Needs But Doesn't Have

All agent files referenced in `opencode.json`:
- `.opencode/agents/web-research.md`
- `.opencode/agents/neovim-research.md`
- `.opencode/agents/general-research.md`
- `.opencode/agents/task-planner.md`
- `.opencode/agents/web-implementation.md`
- `.opencode/agents/neovim-implementation.md`
- `.opencode/agents/general-implementation.md`
- `.opencode/agents/meta-builder.md`
- `.opencode/agents/document-converter.md`

## Options for Resolution

### Option 1: Create a Separate "Core" Extension

Create a new extension that provides the general-purpose agents:
- Extension name: `core-agents` or `base-system`
- Provides: all the agents the Website repo expects
- Loaded before or alongside the memory extension

**Pros**:
- Keeps concerns separated (memory vs. general agents)
- Allows repos to opt-in to general agents
- Clean architecture

**Cons**:
- Requires creating a new extension
- Website repo would need to load both extensions

### Option 2: Modify Website Repo opencode.json

Remove the agent file references from `Website/opencode.json` and define agents inline or not at all.

**Pros**:
- Immediate fix
- No changes needed to nvim config

**Cons**:
- Website repo loses agent functionality
- Other repos with similar configs will have same issue

### Option 3: Add Agents to Memory Extension (NOT RECOMMENDED)

Add all missing agent files to the memory extension manifest.

**Pros**:
- Single extension to load
- Works immediately

**Cons**:
- Violates separation of concerns
- Memory extension becomes bloated
- Agents unrelated to memory functionality

### Option 4: Change How Extensions Work

Modify the extension system to always copy base agents from nvim config, not just from extensions.

**Pros**:
- Transparent to users
- Works for all repos

**Cons**:
- Complex implementation
- May cause conflicts
- Breaks extension isolation model

## Recommendations

1. **Short-term**: Fix the Website repo by creating the missing agent files directly in `Website/.opencode/agents/`, or modify `opencode.json` to not reference them.

2. **Long-term**: Create a "core" or "base" extension that provides general-purpose agents, separate from the memory extension. This extension would provide:
   - web-research, neovim-research, general-research agents
   - web-implementation, neovim-implementation, general-implementation agents
   - task-planner, meta-builder agents
   - etc.

3. **Update documentation**: Document that the memory extension only provides memory-specific functionality, and additional extensions may be needed for full agent support.

## Related Issues

- **Task 179**: Memory extension data directory loading bug (data goes to wrong location)
- **Task 178**: MCP port configuration fix (port 3000 vs 27124)

## Files Examined

1. `/home/benjamin/Projects/Logos/Website/opencode.json` - Website repo configuration
2. `/home/benjamin/.config/nvim/.opencode/extensions/memory/manifest.json` - Memory extension manifest
3. `/home/benjamin/.config/nvim/lua/neotex/plugins/ai/shared/extensions/loader.lua` - Extension loader
4. `/home/benjamin/.config/nvim/lua/neotex/plugins/ai/shared/extensions/config.lua` - Extension configuration
5. `/home/benjamin/.config/nvim/.opencode/agent/subagents/` - Core agents in nvim config

## Conclusion

The issue is an architectural mismatch: the Website repo expects a full opencode agent system, but the memory extension only provides memory-specific functionality. The extension system works correctly - it copies exactly what the manifest declares. The solution requires either:

1. Creating the missing agents in the Website repo directly
2. Creating a separate extension for general-purpose agents
3. Updating the Website repo configuration to not reference non-existent agents

The memory extension itself is working as designed and should not be modified to include unrelated agents.

---

**Next Steps**: Decide which resolution option to pursue (recommend Option 1 or 2).
