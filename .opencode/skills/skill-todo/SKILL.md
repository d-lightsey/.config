---
name: skill-todo
description: Archive completed and abandoned tasks with CHANGE_LOG.md updates and memory harvest suggestions
allowed-tools: Bash, Edit, Read, Write, Grep, AskUserQuestion
context: direct
---

# Todo Skill

Direct execution skill for archiving tasks, updating CHANGE_LOG.md, and suggesting memory harvesting.

<context>
  <system_context>OpenCode task archival with changelog tracking and memory suggestions.</system_context>
  <task_context>Archive completed/abandoned tasks and track changes.</task_context>
</context>

<role>Direct execution skill for task archival operations with automated CHANGE_LOG updates and memory harvest suggestions.</role>

<task>Parse arguments, scan for archivable tasks, update states, generate CHANGE_LOG entries, suggest memory harvesting from completed task artifacts.</task>

<execution>
  <stage id="1" name="ParseArguments">
    <action>Parse command arguments</action>
    <process>
      1. Check for --dry-run flag
      2. Set dry_run = true if present
      3. Validate no other arguments expected
    </process>
  </stage>
  
  <stage id="2" name="ScanTasks">
    <action>Scan for archivable tasks</action>
    <process>
      1. Read specs/state.json
      2. Identify tasks with status = "completed"
      3. Identify tasks with status = "abandoned"
      4. Read specs/TODO.md and cross-reference
      5. Track counts: completed_count, abandoned_count
    </process>
  </stage>
  
  <stage id="3" name="DetectOrphans">
    <action>Detect orphaned directories</action>
    <process>
      1. Scan specs/ for directories not tracked in state files:
         ```bash
         for dir in specs/OC_[0-9]*_*/ specs/[0-9]*_*/; do
           [ -d "$dir" ] || continue
           basename_dir=$(basename "$dir")
           project_num=$(echo "$basename_dir" | sed 's/^OC_//' | cut -d_ -f1)
           
           in_active=$(jq -r --arg n "$project_num" \
             '.active_projects[] | select(.project_number == ($n | tonumber)) | .project_number' \
             specs/state.json 2>/dev/null)
           
           in_archive=$(jq -r --arg n "$project_num" \
             '.completed_projects[] | select(.project_number == ($num | tonumber)) | .project_number' \
             specs/archive/state.json 2>/dev/null)
           
           if [ -z "$in_active" ] && [ -z "$in_archive" ]; then
             orphaned_in_specs+=("$dir")
           fi
         done
         ```
      
      2. Scan specs/archive/ for orphaned directories:
         ```bash
         for dir in specs/archive/OC_[0-9]*_*/ specs/archive/[0-9]*_*/; do
           [ -d "$dir" ] || continue
           basename_dir=$(basename "$dir")
           project_num=$(echo "$basename_dir" | sed 's/^OC_//' | cut -d_ -f1)
           
           in_archive=$(jq -r --arg n "$project_num" \
             '.completed_projects[] | select(.project_number == ($num | tonumber)) | .project_number' \
             specs/archive/state.json 2>/dev/null)
           
           if [ -z "$in_archive" ]; then
             orphaned_in_archive+=("$dir")
           fi
         done
         ```
    </process>
  </stage>
  
  <stage id="4" name="DetectMisplaced">
    <action>Detect misplaced directories</action>
    <process>
      1. Scan specs/ for directories tracked in archive state:
         ```bash
         for dir in specs/OC_[0-9]*_*/ specs/[0-9]*_*/; do
           [ -d "$dir" ] || continue
           basename_dir=$(basename "$dir")
           project_num=$(echo "$basename_dir" | sed 's/^OC_//' | cut -d_ -f1)
           
           in_active=$(jq -r --arg n "$project_num" \
             '.active_projects[] | select(.project_number == ($num | tonumber)) | .project_number' \
             specs/state.json 2>/dev/null)
           
           in_archive=$(jq -r --arg n "$project_num" \
             '.completed_projects[] | select(.project_number == ($num | tonumber)) | .project_number' \
             specs/archive/state.json 2>/dev/null)
           
           if [ -z "$in_active" ] && [ -n "$in_archive" ]; then
             misplaced_in_specs+=("$dir")
           fi
         done
         ```
    </process>
  </stage>
  
  <stage id="5" name="ScanRoadmap">
    <action>Scan for roadmap references</action>
    <process>
      1. Read specs/ROAD_MAP.md
      2. For each completed task, extract:
         - completion_summary from completion_data
         - roadmap_items if present
         - Task N references from summaries
      3. Match against ROAD_MAP.md items
      4. Track roadmap_matches array with confidence levels
    </process>
  </stage>
  
  <stage id="6" name="ScanMetaSuggestions">
    <action>Scan meta tasks for README.md suggestions</action>
    <process>
      1. For each archived meta task:
         - Check completion_data.readme_suggestions
         - Filter out "none" values
         - Track actionable suggestions by type:
           * Add: Insert new content
           * Update: Replace existing content
           * Remove: Delete content
    </process>
  </stage>
  
  <stage id="7" name="HarvestMemories">
    <action>Scan artifacts for memory harvest suggestions</action>
    <process>
      1. For each completed task:
         - Scan reports/ for insights and findings
         - Scan plans/ for reusable patterns
         - Check summaries/ for key learnings
      2. Extract potential memory candidates:
         - Research findings with general applicability
         - Implementation patterns documented
         - Configuration examples
         - Workflow descriptions
      3. Generate suggestions list with:
         - Source file path
         - Brief description of insight
         - Suggested memory category (TECHNIQUE, PATTERN, CONFIG, WORKFLOW, INSIGHT)
    </process>
  </stage>
  
  <stage id="8" name="DryRunOutput">
    <action>Display dry run preview if requested</action>
    <process>
      If dry_run = true:
      1. Display comprehensive preview:
         - Tasks to archive (completed/abandoned counts)
         - Orphaned directories count
         - Misplaced directories count
         - Roadmap updates needed
         - README.md suggestions count
         - Memory harvest suggestions count
      2. Exit after display
    </process>
  </stage>
  
  <stage id="9" name="InteractivePrompts">
    <action>Handle interactive prompts</action>
    <process>
      1. If orphaned directories found:
         - Present AskUserQuestion with track/skip options
         - Store user decisions
      
      2. If misplaced directories found:
         - Present AskUserQuestion with move/skip options
         - Store user decisions
         
      3. If memory harvest suggestions found:
         - Present suggestions with multiSelect:
           ```json
           {
             "question": "Select memories to create from completed tasks:",
             "options": [
               {"label": "[PATTERN] Configuration pattern from task 142", "value": "mem_142_pattern"},
               {"label": "[TECHNIQUE] Agent delegation from task 143", "value": "mem_143_tech"}
             ],
             "multiple": true
           }
           ```
         - Store selected memories for creation
    </process>
  </stage>
  
  <stage id="10" name="ArchiveTasks">
    <action>Archive tasks to completed_projects</action>
    <process>
      For each task to archive:
      1. Update specs/archive/state.json:
         - Add to completed_projects array
         - Include all task fields
         - Add archived timestamp
      
      2. Update specs/state.json:
         - Remove from active_projects array
      
      3. Update specs/TODO.md:
         - Remove archived entries
      
      4. Move project directories to specs/archive/
      
      5. Track orphaned directories (if approved)
      
      6. Move misplaced directories (if approved)
    </process>
  </stage>
  
  <stage id="11" name="UpdateRoadmap">
    <action>Update ROAD_MAP.md with completion annotations</action>
    <process>
      For each roadmap match:
      1. Skip if already annotated
      2. Apply appropriate annotation:
         - Completed: `- [x] item *(Completed: Task OC_N, DATE)*`
         - Abandoned: `- [ ] item *(Task OC_N abandoned: reason)*`
      3. Track changes: completed_annotated, abandoned_annotated, skipped
    </process>
  </stage>
  
  <stage id="12" name="UpdateREADME">
    <action>Apply README.md suggestions</action>
    <process>
      1. Filter suggestions where action != "none"
      2. Present AskUserQuestion with multiSelect for review
      3. Apply selected suggestions via Edit tool
      4. Display results (applied/failed/skipped)
      5. Acknowledge "none" action tasks
    </process>
  </stage>
  
  <stage id="13" name="UpdateChangelog">
    <action>Update CHANGE_LOG.md with archive entries</action>
    <process>
      1. Create specs/CHANGE_LOG.md if not exists:
         ```markdown
         # Change Log
         
         All notable changes to the OpenCode system.
         
         ## Format
         
         Each entry includes:
         - Date
         - Task number and name
         - Type of change
         - Brief description
         
         ---
         ```
      
      2. For each archived task, append entry:
         ```markdown
         ### YYYY-MM-DD
         
         **Task OC_{N}: {project_name}**
         - Status: {completed|abandoned}
         - Type: {meta|neovim|general|lean}
         - Summary: {completion_summary or description}
         
         Artifacts:
         {List of artifact paths}
         ```
      
      3. Append memory harvest note if memories were suggested
    </process>
  </stage>
  
  <stage id="14" name="CreateMemories">
    <action>Create selected memories</action>
    <process>
      For each selected memory suggestion:
      1. Generate memory ID: MEM-YYYY-MM-DD-NNN
      2. Create memory file in .opencode/memory/10-Memories/
      3. Format with classification tag:
         ```markdown
         # Memory: {title}
         
         **Category**: [TECHNIQUE|PATTERN|CONFIG|WORKFLOW|INSIGHT]
         **Source**: Task OC_{N} - {artifact_path}
         **Date**: YYYY-MM-DD
         
         {content}
         ```
      4. Update .opencode/memory/20-Indices/index.md
      5. Track created memory IDs
    </process>
  </stage>
  
  <stage id="15" name="GitCommit">
    <action>Commit all changes</action>
    <process>
      1. Stage all modified files:
         ```bash
         git add -A
         ```
      
      2. Create comprehensive commit message:
         ```
         todo: archive {N} tasks
         
         - {completed} completed tasks
         - {abandoned} abandoned tasks
         - {roadmap} roadmap items updated
         - {orphans} orphaned directories tracked
         - {misplaced} misplaced directories moved
         - {readme} README.md suggestions applied
         - {memories} memories harvested from artifacts
         
         Updated: specs/state.json, specs/TODO.md, specs/CHANGE_LOG.md
         ```
      
      3. Commit changes
    </process>
  </stage>
  
  <stage id="16" name="OutputResults">
    <action>Display final results</action>
    <process>
      Display complete summary:
      ```
      Task Archival Complete
      ======================
      
      Archived Tasks:
      - {completed} completed
      - {abandoned} abandoned
      
      Directory Operations:
      - {orphans} orphaned directories tracked
      - {misplaced} misplaced directories moved
      
      Updates Applied:
      - {roadmap} roadmap items annotated
      - {readme} README.md suggestions applied
      - {changelog} CHANGE_LOG.md entries added
      
      Memory Harvest:
      - {memories_created} new memories created
      - {memories_suggested} suggestions available
      
      Active tasks remaining: {remaining_count}
      ```
    </process>
  </stage>
</execution>

<validation>Validate state updates, CHANGE_LOG.md entries, and memory creation.</validation>

<return_format>Brief text summary with archival counts and operation results.</return_format>

## Error Handling

- **jq failures**: Log error with technical details, skip affected operation
- **File permission errors**: Return error with guidance
- **Git commit failures**: Log warning, continue with other operations
- **User cancels prompts**: Exit gracefully
- **AskUserQuestion failures**: Default to conservative option (skip)

## Memory Harvest Categories

When suggesting memories from task artifacts, use these categories:

| Category | Description | Example |
|----------|-------------|---------|
| TECHNIQUE | Reusable method or approach | "Three-phase debugging process" |
| PATTERN | Design or implementation pattern | "Agent delegation wrapper pattern" |
| CONFIG | Configuration or setup knowledge | "Neovim LSP keymap configuration" |
| WORKFLOW | Process or procedure | "Code review checklist workflow" |
| INSIGHT | Key learning or understanding | "Root cause of race condition" |

## CHANGE_LOG.md Format

```markdown
# Change Log

All notable changes to the OpenCode system.

## Format

Each entry includes:
- Date
- Task number and name  
- Type of change
- Brief description

---

### YYYY-MM-DD

**Task OC_{N}: {project_name}**
- Status: {completed|abandoned}
- Type: {meta|neovim|general|lean}
- Summary: {description}

Artifacts:
- path/to/artifact.ext - description

---
```

## Example Usage

```
/todo              # Archive with full workflow
/todo --dry-run    # Preview what would be archived
```