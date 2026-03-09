## Filetypes Extension

This project includes comprehensive file format conversion and manipulation via the filetypes extension.

### Skill-Agent Mapping

| Skill | Agent | Purpose |
|-------|-------|---------|
| skill-filetypes | filetypes-router-agent | Format detection and routing to specialized agents |
| skill-filetypes | document-agent | Document format conversion (PDF/DOCX/Markdown) |
| skill-spreadsheet | spreadsheet-agent | Spreadsheet to LaTeX/Typst table conversion |
| skill-presentation | presentation-agent | Presentation extraction and slide generation |
| skill-deck | deck-agent | YC-style investor pitch deck generation |

### Supported Conversions

#### Document Conversions (via /convert)

| Source | Target | Primary Tool | Fallback |
|--------|--------|--------------|----------|
| PDF | Markdown | markitdown | pandoc |
| DOCX | Markdown | markitdown | pandoc |
| HTML | Markdown | markitdown | pandoc |
| Images | Markdown | markitdown | - |
| Markdown | PDF | pandoc | typst |

#### Spreadsheet Conversions (via /table)

| Source | Target | Primary Tool | Fallback |
|--------|--------|--------------|----------|
| XLSX | LaTeX table | pandas + openpyxl | xlsx2csv |
| XLSX | Typst table | pandas -> CSV -> Typst csv() | xlsx2csv |
| CSV | LaTeX table | pandas | manual |
| CSV | Typst table | Typst csv() | manual |
| ODS | LaTeX/Typst table | pandas | - |

#### Presentation Conversions (via /slides)

| Source | Target | Primary Tool | Fallback |
|--------|--------|--------------|----------|
| PPTX | Beamer | python-pptx + pandoc | markitdown |
| PPTX | Polylux (Typst) | python-pptx | markitdown |
| PPTX | Touying (Typst) | python-pptx | markitdown |
| Markdown | PPTX | pandoc | - |

### Command Usage

```bash
# Document conversion (format inferred)
/convert document.pdf                    # -> document.md
/convert report.docx notes.md            # -> notes.md
/convert README.md README.pdf            # -> README.pdf

# Spreadsheet to table
/table data.xlsx                         # -> data.tex (LaTeX)
/table data.xlsx output.typ --format typst
/table budget.csv budget.tex --format latex

# Presentation conversion
/slides presentation.pptx                # -> presentation.tex (Beamer)
/slides deck.pptx slides.typ --format polylux
/slides talk.pptx talk.typ --format touying

# Pitch deck generation
/deck "We are Acme AI, building enterprise LLM platform..."   # -> pitch-deck.typ
/deck startup-info.md                                         # -> startup-info-deck.typ
/deck company.md deck.typ --theme metropolis                  # -> deck.typ (metropolis theme)
```

### Prerequisites

Install conversion tools based on your needs:

**Document Conversion**:
- `markitdown`: `pip install markitdown`
- `pandoc`: Install from package manager
- `typst`: Install for Typst output

**Spreadsheet Conversion**:
- `pandas`: `pip install pandas`
- `openpyxl`: `pip install openpyxl` (for XLSX support)
- `xlsx2csv`: `pip install xlsx2csv` (fallback)

**Presentation Conversion**:
- `python-pptx`: `pip install python-pptx`
- `pandoc`: For Beamer output

See `context/project/filetypes/tools/dependency-guide.md` for platform-specific installation instructions.

### NixOS Quick Install

```nix
# home.nix
home.packages = with pkgs; [
  pandoc typst
  (python3.withPackages (ps: with ps; [
    markitdown openpyxl pandas python-pptx xlsx2csv
  ]))
];
```

### Dependency Summary

| Tool | Purpose | Required For |
|------|---------|--------------|
| markitdown | Office to Markdown | /convert |
| pandoc | Universal converter | /convert, /slides |
| typst | Typst compiler | /convert (typst output) |
| pandas | DataFrame handling | /table |
| openpyxl | XLSX support | /table (xlsx) |
| python-pptx | PPTX extraction | /slides |
| xlsx2csv | XLSX fallback | /table (fallback) |
| pdflatex | LaTeX compilation | Beamer PDF output |

### Pitch Deck Generation (via /deck)

Generate YC-style 10-slide investor pitch decks in Typst using the touying package.

**Usage**:
```bash
/deck PROMPT_OR_PATH [OUTPUT_PATH] [--theme NAME] [--slides N]
```

**Input Options**:
- Text prompt: `"We are Acme, building X for Y. Raised $1M seed..."`
- File path: Path to .md, .txt, or .json containing startup information

**Themes**:
- `simple` (default) - Minimal, high-contrast, best for investor decks
- `metropolis` - Modern, professional
- `dewdrop` - Light, creative
- `university` - Academic style
- `stargazer` - Dark mode

**Output**:
- Typst .typ file with touying 0.6.3 imports
- 10 slides following YC structure (Title, Problem, Solution, Traction, Why Us, Business Model, Market, Team, Ask, Closing)
- Speaker notes for each slide
- `[TODO: ...]` placeholders for missing content

**Prerequisites**:
- `typst`: For compilation (`typst compile deck.typ`)

**Examples**:
```bash
# From a prompt
/deck "We are Acme AI, an enterprise LLM platform founded by ex-Google ML engineers."

# From a file
/deck company-overview.md

# With output path and theme
/deck startup.md investor-deck.typ --theme metropolis
```

**Slide Structure** (YC Best Practices):
1. **Title** - Company name and one-line description
2. **Problem** - The pain point you solve
3. **Solution** - How your product addresses it
4. **Traction** - Key metrics and growth chart
5. **Why Us/Why Now** - Unique advantage and timing
6. **Business Model** - Revenue streams and pricing
7. **Market** - TAM/SAM/SOM opportunity
8. **Team** - Founders and key hires
9. **The Ask** - Funding amount and use of funds
10. **Closing** - Contact info and Q&A

### Context Documentation

| File | Description |
|------|-------------|
| `tools/tool-detection.md` | Shared tool availability patterns |
| `tools/dependency-guide.md` | Platform-specific installation |
| `tools/mcp-integration.md` | MCP server configuration |
| `patterns/spreadsheet-tables.md` | Table conversion patterns |
| `patterns/presentation-slides.md` | Slide generation patterns |
| `patterns/pitch-deck-structure.md` | YC pitch deck structure and design principles |
| `patterns/touying-pitch-deck-template.md` | Touying template for pitch decks |
