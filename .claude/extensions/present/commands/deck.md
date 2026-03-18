---
description: Generate YC-style investor pitch decks in Typst
allowed-tools: Skill, Bash(test:*), Bash(dirname:*), Bash(basename:*), Bash(pwd:*), Read, AskUserQuestion
argument-hint: PROMPT_OR_PATH [OUTPUT_PATH] [--theme simple|metropolis|stargazer] [--palette professional-blue|premium-dark|minimal-light|growth-green] [--slides N]
---

# /deck Command

Generate 10-slide investor pitch decks in Typst format using YC best practices and the touying slide package.

## Arguments

- `$1` - Prompt or source file path (required): Either a text description of your startup OR a path to a file containing startup information
- `$2` - Output file path (optional, defaults to pitch-deck.typ or derived from source)
- `--theme` - Touying theme: `simple` (default), `metropolis`, `dewdrop`, `university`, `stargazer`
- `--palette` - Color palette: `professional-blue` (default), `premium-dark`, `minimal-light`, `growth-green`
- `--slides` - Number of slides (optional, default 10)

## Usage Examples

```bash
# Generate from a prompt
/deck "We are Acme AI, an enterprise LLM platform founded by ex-Google engineers. We've grown 300% MoM."

# Generate from a file
/deck startup-info.md

# Generate with output path
/deck "Brief startup description" pitch.typ

# Generate with theme
/deck company-overview.md deck.typ --theme metropolis

# Generate from file with custom slide count
/deck detailed-info.md --slides 12
```

## Input Formats

### Prompt Input
Provide a text description of your startup:
- Company name and what you do
- Problem you solve
- Your solution
- Traction metrics
- Team background
- Funding ask

### File Input
Provide a path to a markdown, text, or JSON file containing:
- Startup overview document
- Investment memo
- Company description
- Pitch notes

The agent will extract relevant information and map it to the YC 10-slide structure.

## Output

Generates a `.typ` file with:
- Touying 0.6.3 imports and theme setup
- 10 slides following YC structure (Title, Problem, Solution, Traction, Why Us, Business Model, Market, Team, Ask, Closing)
- Speaker notes for each slide
- `[TODO: ...]` placeholders for missing information
- Ready for compilation with `typst compile`

## Execution

### CHECKPOINT 1: GATE IN

1. **Generate Session ID**
   ```bash
   session_id="sess_$(date +%s)_$(od -An -N3 -tx1 /dev/urandom | tr -d ' ')"
   ```

2. **Parse Arguments**
   ```bash
   input=""
   output_path=""
   theme=""
   palette=""
   slide_count="10"

   # First positional argument is input (prompt or path)
   input="$1"
   shift

   # Parse remaining arguments
   while [[ $# -gt 0 ]]; do
     case "$1" in
       --theme)
         theme="$2"
         shift 2
         ;;
       --palette)
         palette="$2"
         shift 2
         ;;
       --slides)
         slide_count="$2"
         shift 2
         ;;
       *)
         if [ -z "$output_path" ]; then
           output_path="$1"
         fi
         shift
         ;;
     esac
   done

   # Validate input provided
   if [ -z "$input" ]; then
     echo "Error: Input required (prompt or file path)"
     echo "Usage: /deck PROMPT_OR_PATH [OUTPUT_PATH] [--theme NAME] [--palette NAME] [--slides N]"
     exit 1
   fi
   ```

3. **Determine Input Type**
   ```bash
   prompt=""
   source_path=""

   # Check if input is an existing file
   if [ -f "$input" ]; then
     source_path="$input"
     # Convert to absolute path if relative
     if [[ "$source_path" != /* ]]; then
       source_path="$(pwd)/$source_path"
     fi
   else
     # Treat as prompt text
     prompt="$input"
   fi
   ```

4. **Determine Output Path** (if not provided)
   ```bash
   if [ -z "$output_path" ]; then
     if [ -n "$source_path" ]; then
       source_dir=$(dirname "$source_path")
       source_base=$(basename "$source_path" | sed 's/\.[^.]*$//')
       output_path="${source_dir}/${source_base}-deck.typ"
     else
       output_path="$(pwd)/pitch-deck.typ"
     fi
   fi

   # Convert output to absolute path if relative
   if [[ "$output_path" != /* ]]; then
     output_path="$(pwd)/$output_path"
   fi
   ```

5. **Validate Theme** (if provided)
   ```bash
   if [ -n "$theme" ]; then
     case "$theme" in
       simple|metropolis|dewdrop|university|stargazer)
         ;; # Valid
       *)
         echo "Error: Unknown theme: $theme"
         echo "Supported themes: simple, metropolis, dewdrop, university, stargazer"
         exit 1
         ;;
     esac
   fi
   ```

6. **Validate Palette** (if provided)
   ```bash
   if [ -n "$palette" ]; then
     case "$palette" in
       professional-blue|premium-dark|minimal-light|growth-green)
         ;; # Valid
       *)
         echo "Error: Unknown palette: $palette"
         echo "Supported palettes: professional-blue, premium-dark, minimal-light, growth-green"
         exit 1
         ;;
     esac
   fi
   ```

7. **Interactive Style Selection** (when theme or palette not provided)

   If `--theme` AND `--palette` are both provided, skip the picker. Otherwise, show the interactive picker.

   ```
   # Show interactive picker if theme or palette not specified
   if [ -z "$theme" ] || [ -z "$palette" ]; then
     # Use AskUserQuestion to prompt for style selection
   fi
   ```

   **Use AskUserQuestion** with the following picker:

   ```json
   {
     "question": "Select a visual style for your pitch deck:",
     "header": "Deck Style",
     "multiSelect": false,
     "options": [
       {"label": "Simple + Professional Blue", "description": "Minimal layout, navy tones | Fintech, enterprise B2B"},
       {"label": "Simple + Premium Dark", "description": "Minimal layout, dark + gold | Luxury, premium tech"},
       {"label": "Simple + Minimal Light", "description": "Minimal layout, charcoal/gray | Data, analytics"},
       {"label": "Simple + Growth Green", "description": "Minimal layout, emerald | Sustainability, health"},
       {"label": "Metropolis + Professional Blue", "description": "Modern professional, navy | Corporate presentations"},
       {"label": "Metropolis + Premium Dark", "description": "Modern professional, dark + gold | Evening events"},
       {"label": "Metropolis + Minimal Light", "description": "Modern professional, gray | Versatile corporate"},
       {"label": "Metropolis + Growth Green", "description": "Modern professional, emerald | Environmental tech"},
       {"label": "Dewdrop + Professional Blue", "description": "Light airy layout, navy | Creative tech"},
       {"label": "Dewdrop + Premium Dark", "description": "Light airy layout, dark + gold | Creative luxury"},
       {"label": "Dewdrop + Minimal Light", "description": "Light airy layout, gray | Startup pitches"},
       {"label": "Dewdrop + Growth Green", "description": "Light airy layout, emerald | Health startups"},
       {"label": "University + Professional Blue", "description": "Academic style, navy | Research presentations"},
       {"label": "University + Premium Dark", "description": "Academic style, dark + gold | Evening lectures"},
       {"label": "University + Minimal Light", "description": "Academic style, gray | Conference talks"},
       {"label": "University + Growth Green", "description": "Academic style, emerald | Environmental research"},
       {"label": "Stargazer + Professional Blue", "description": "Dark mode, navy accents | Tech demos"},
       {"label": "Stargazer + Premium Dark", "description": "Dark mode, gold accents | VIP presentations"},
       {"label": "Stargazer + Minimal Light", "description": "Dark mode, blue accents | Technical talks"},
       {"label": "Stargazer + Growth Green", "description": "Dark mode, green accents | Sustainability demos"}
     ]
   }
   ```

   **Parse the selection** to extract theme and palette:
   - Selection format: `"Theme + Palette"` (e.g., "Simple + Professional Blue")
   - Extract theme: lowercase first word (e.g., "simple")
   - Extract palette: lowercase remaining words with spaces replaced by hyphens (e.g., "professional-blue")

   ```bash
   # Parse selection: "Simple + Professional Blue" -> theme=simple, palette=professional-blue
   selected="$selection"
   theme_part=$(echo "$selected" | sed 's/ + .*//' | tr '[:upper:]' '[:lower:]')
   palette_part=$(echo "$selected" | sed 's/.* + //' | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

   # Override only if not already set via CLI flags
   if [ -z "$theme" ]; then
     theme="$theme_part"
   fi
   if [ -z "$palette" ]; then
     palette="$palette_part"
   fi
   ```

   **Note**: If only `--theme` was provided, the picker can be skipped and palette defaults to "professional-blue". If only `--palette` was provided, show a simplified theme-only picker or default theme to "simple".

   For simplicity, if EITHER is missing, show the full picker and let the user choose both, then use CLI-provided values to override where applicable.

8. **Validate Slide Count**
   ```bash
   if ! [[ "$slide_count" =~ ^[0-9]+$ ]] || [ "$slide_count" -lt 5 ] || [ "$slide_count" -gt 20 ]; then
     echo "Error: Slide count must be between 5 and 20"
     exit 1
   fi
   ```

**ABORT** if no input provided or theme is invalid.

**On GATE IN success**: Arguments validated. **IMMEDIATELY CONTINUE** to STAGE 2 below.

### STAGE 2: DELEGATE

**EXECUTE NOW**: After CHECKPOINT 1 passes, immediately invoke the Skill tool.

**Invoke the Skill tool NOW** with:
```
skill: "skill-deck"
args: "prompt={prompt} source_path={source_path} output_path={output_path} theme={theme} palette={palette} slide_count={slide_count} session_id={session_id}"
```

The skill will spawn the deck-agent to generate the pitch deck.

**On DELEGATE success**: Generation attempted. **IMMEDIATELY CONTINUE** to CHECKPOINT 2 below.

### CHECKPOINT 2: GATE OUT

1. **Validate Return**
   Required fields: status, summary, artifacts, metadata (with slide_count)

2. **Verify Output File Exists**
   ```bash
   if [ ! -f "$output_path" ]; then
     echo "Warning: Output file not created"
   fi
   ```

3. **Verify Output Non-Empty**
   ```bash
   if [ ! -s "$output_path" ]; then
     echo "Warning: Output file is empty"
   fi
   ```

4. **Verify Touying Import Present**
   ```bash
   if ! grep -q '@preview/touying' "$output_path"; then
     echo "Warning: Output missing touying import"
   fi
   ```

**On GATE OUT success**: Output verified.

### CHECKPOINT 3: COMMIT

Git commit is **optional** for standalone generation.

Only commit if:
- User explicitly requests it
- Generation is part of a task workflow

```bash
# Only if commit requested
git add "$output_path"
git commit -m "$(cat <<'EOF'
deck: generate pitch deck

Session: {session_id}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
```

Commit failure is non-blocking (log and continue).

## Output

**Success**:
```
Pitch deck generated!

Output:  {output_path}
Theme:   {theme}
Palette: {palette}
Slides:  {slide_count}
TODOs:   {slides_with_todos} slides need content

Input:   {input_type: prompt_only|file_only|prompt_and_file}

Compile with: typst compile {output_path}

Status: generated
```

**Failed**:
```
Pitch deck generation failed.

Error: {error_message}

Recommendation: {recommendation from error}
```

## Error Handling

### GATE IN Failure

**No input provided**:
```
Error: Input required (prompt or file path)

Usage: /deck PROMPT_OR_PATH [OUTPUT_PATH] [--theme NAME] [--slides N]

Examples:
  /deck "We are Acme, building X for Y..."
  /deck startup-info.md
  /deck company.md deck.typ --theme metropolis
```

**Invalid theme**:
```
Error: Unknown theme: {theme}

Supported themes: simple, metropolis, dewdrop, university, stargazer
```

**Invalid slide count**:
```
Error: Slide count must be between 5 and 20
```

### DELEGATE Failure

**Source file not found**:
```
Error: Source file not found: {path}

Please verify the file path and try again.
```

**Empty input**:
```
Error: No content found in input.

Provide either:
- A text prompt describing your startup
- A file path to a document with startup information
```

### GATE OUT Failure

**Output file missing**:
```
Error: Failed to create output file.

Check write permissions for: {output_path}
```
