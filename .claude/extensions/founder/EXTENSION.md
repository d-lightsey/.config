## Founder Extension (v3.0)

Strategic business analysis tools for founders and entrepreneurs. Integrates forcing question patterns and decision frameworks inspired by Y Combinator office hours methodology. Includes market sizing, competitive analysis, go-to-market strategy, contract review, and project timeline management -- all following the standard phased workflow.

### Pre-Task Forcing Questions

Commands ask essential forcing questions BEFORE creating tasks:

```
/market "fintech payments"
  -> Mode selection (VALIDATE, SIZE, SEGMENT, DEFEND)
  -> Problem definition question
  -> Target entity question
  -> Geographic scope question
  -> Price point question (optional)
  -> Task created with forcing_data stored
```

This workflow gathers essential data upfront, creating richer task entries and enabling more focused research.

```
/legal "SaaS vendor agreement"
  -> Mode selection (REVIEW, NEGOTIATE, TERMS, DILIGENCE)
  -> Contract type question
  -> Primary concern question
  -> Position question
  -> Financial exposure question
  -> Task created with forcing_data stored
  -> Escalation assessment (self-serve / attorney review)
```

### Unified Phased Workflow (v3.0)

All 5 commands follow the same standard lifecycle:

```
/{command} "description"   -> Asks forcing questions, creates task, stops at [NOT STARTED]
/research {N}              -> Domain-specific research agent, stops at [RESEARCHED]
/plan {N}                  -> Shared planner (content-aware), creates plan
/implement {N}             -> Shared implementer (type-aware), generates final artifact
```

The differentiation is at the **research** phase where each command has a specialized agent. Planning and implementation use shared agents that detect the task type from the research report content.

### Commands

| Command | Usage | Description |
|---------|-------|-------------|
| `/market` | `/market "fintech payments"` | Ask forcing questions, create task (stops at [NOT STARTED]) |
| `/market` | `/market 234` | Run research on existing task |
| `/market` | `/market --quick [args]` | Legacy standalone mode |
| `/analyze` | `/analyze "competitor landscape"` | Ask forcing questions, create task (stops at [NOT STARTED]) |
| `/strategy` | `/strategy "B2B launch"` | Ask forcing questions, create task (stops at [NOT STARTED]) |
| `/legal` | `/legal "SaaS vendor agreement"` | Ask forcing questions, create task (stops at [NOT STARTED]) |
| `/legal` | `/legal 256` | Run research on existing task |
| `/legal` | `/legal --quick [args]` | Legacy standalone mode |
| `/project` | `/project "Mobile App Redesign"` | Ask forcing questions, create task (stops at [NOT STARTED]) |
| `/project` | `/project 234` | Run research on existing task |
| `/project` | `/project --quick [mode]` | Legacy standalone mode |

### Input Types

| Input | Behavior |
|-------|----------|
| Description string | Ask forcing questions, create task, stop at [NOT STARTED] |
| Task number | Load existing task, run research, stop at [RESEARCHED] |
| File path | Read file for context, ask questions, create task |
| `--quick [args]` | Legacy standalone mode (no task creation) |

### Legal Command Modes

| Mode | Posture | Focus |
|------|---------|-------|
| **REVIEW** | Risk assessment | Identify problematic clauses, red flags, missing protections |
| **NEGOTIATE** | Position building | Counter-terms, leverage points, BATNA/ZOPA analysis |
| **TERMS** | Term sheet review | Key terms, market benchmarks, standard vs non-standard |
| **DILIGENCE** | Due diligence | Comprehensive review for transaction, IP, liability, R&W |

### task_type Field

Tasks created by founder commands include a `task_type` field for finer-grained routing:

| Command | task_type | Research Skill |
|---------|-----------|----------------|
| /market | market | skill-market |
| /analyze | analyze | skill-analyze |
| /strategy | strategy | skill-strategy |
| /legal | legal | skill-legal |
| /project | project | skill-project |

When `/research {N}` is invoked on a founder task with `task_type` set, routing uses the composite key `founder:{task_type}` to select the appropriate skill.

### Language-Based Routing

Tasks with `language: founder` route to founder-specific skills:

| Workflow | Routing Key | Skill | Agent |
|----------|-------------|-------|-------|
| `/research` (task_type: market) | founder:market | skill-market | market-agent |
| `/research` (task_type: analyze) | founder:analyze | skill-analyze | analyze-agent |
| `/research` (task_type: strategy) | founder:strategy | skill-strategy | strategy-agent |
| `/research` (task_type: legal) | founder:legal | skill-legal | legal-council-agent |
| `/research` (task_type: project) | founder:project | skill-project | project-agent |
| `/research` (no task_type) | founder | skill-market | market-agent |
| `/plan` (task_type: market) | founder:market | skill-founder-plan | founder-plan-agent |
| `/plan` (task_type: analyze) | founder:analyze | skill-founder-plan | founder-plan-agent |
| `/plan` (task_type: strategy) | founder:strategy | skill-founder-plan | founder-plan-agent |
| `/plan` (task_type: legal) | founder:legal | skill-founder-plan | founder-plan-agent |
| `/plan` (task_type: project) | founder:project | skill-founder-plan | founder-plan-agent |
| `/plan` (no task_type) | founder | skill-founder-plan | founder-plan-agent |
| `/implement` (task_type: market) | founder:market | skill-founder-implement | founder-implement-agent |
| `/implement` (task_type: analyze) | founder:analyze | skill-founder-implement | founder-implement-agent |
| `/implement` (task_type: strategy) | founder:strategy | skill-founder-implement | founder-implement-agent |
| `/implement` (task_type: legal) | founder:legal | skill-founder-implement | founder-implement-agent |
| `/implement` (task_type: project) | founder:project | skill-founder-implement | founder-implement-agent |
| `/implement` (no task_type) | founder | skill-founder-implement | founder-implement-agent |

### Forcing Data Storage

Pre-gathered forcing data is stored in task metadata:

```json
{
  "task_type": "market",
  "forcing_data": {
    "mode": "SIZE",
    "problem": "Mid-market SaaS struggle with deploy coordination",
    "target_entity": "VP Engineering at 50-200 employee SaaS companies",
    "geography": "US initially, North America expansion",
    "price_point": "$500/month/team",
    "gathered_at": "2026-03-18T10:00:00Z"
  }
}
```

Research agents use this data and only ask follow-up questions for missing details.

### Skill-to-Agent Mapping

| Skill | Agent | Purpose |
|-------|-------|---------|
| skill-market | market-agent | Market sizing research (uses forcing_data) |
| skill-analyze | analyze-agent | Competitive analysis research (uses forcing_data) |
| skill-strategy | strategy-agent | GTM strategy research (uses forcing_data) |
| skill-legal | legal-council-agent | Contract review research (uses forcing_data) |
| skill-project | project-agent | Project timeline research: WBS, PERT, resources (uses forcing_data) |
| skill-founder-plan | founder-plan-agent | Shared task planning (content-aware) |
| skill-founder-implement | founder-implement-agent | Shared task implementation (type-aware) |

### Output Locations

| Mode | Report Location | Tracking Artifacts |
|------|-----------------|-------------------|
| Task workflow | `strategy/{report-type}-{slug}.md` | `specs/{NNN}_{SLUG}/` |
| Legacy (--quick) | `founder/{report-type}-{datetime}.md` | None |

### Context Files

| Path | Purpose |
|------|---------|
| `context/project/founder/domain/business-frameworks.md` | TAM/SAM/SOM, business model canvas |
| `context/project/founder/domain/strategic-thinking.md` | CEO cognitive patterns, YC principles |
| `context/project/founder/domain/legal-frameworks.md` | IP assignment, data rights, liability, R&W for AI startups |
| `context/project/founder/patterns/forcing-questions.md` | Forcing question framework |
| `context/project/founder/patterns/decision-making.md` | Two-way doors, inversion, focus as subtraction |
| `context/project/founder/patterns/mode-selection.md` | Operational modes pattern |
| `context/project/founder/patterns/contract-review.md` | Contract review methodology, red flags, escalation |
| `context/project/founder/templates/market-sizing.md` | TAM/SAM/SOM template |
| `context/project/founder/templates/competitive-analysis.md` | Competitor analysis template |
| `context/project/founder/templates/gtm-strategy.md` | Go-to-market template |
| `context/project/founder/templates/contract-analysis.md` | Contract review and negotiation template |

### MCP Tool Integration

Founder extension integrates external MCP tools for enhanced data gathering:

| MCP Server | Agent | Purpose | Setup |
|------------|-------|---------|-------|
| sec-edgar | market-agent | Public company SEC filings (10-K, 10-Q, 8-K) | None required |
| firecrawl | analyze-agent | Full page web scraping, competitor analysis | Requires FIRECRAWL_API_KEY |

**Lazy Loading**: MCP servers only start when their assigned agent is invoked. Other agents (strategy-agent, legal-council-agent, project-agent, founder-plan-agent, founder-implement-agent) do not load any MCP servers.

**Setup**: See README.md for Firecrawl API key configuration.

### Key Patterns

**Pre-Task Forcing Questions**: Essential questions asked BEFORE task creation, storing data in task metadata for use during research.

**Forcing Questions**: One question per AskUserQuestion, explicit push-back on vague answers. Specificity is the only currency.

**Mode-Based Operation**: Commands offer 3-4 operational modes giving user explicit scope control (e.g., LAUNCH, SCALE, PIVOT, EXPAND).

**Completeness Principle**: Always model multiple scenarios/options. AI makes marginal cost of completeness near-zero.

**Decision Frameworks**:
- Two-way doors (reversible): Move fast
- One-way doors (irreversible): Be rigorous
- Inversion: Also ask "What makes us fail?"
- Focus as subtraction: Explicitly document what NOT to do

### Breaking Changes from v2.x

1. **`/project` no longer generates timelines directly** - Use `/research N -> /plan N -> /implement N` for the full lifecycle. The `/project` command now creates a task and optionally runs research only.
2. **TRACK and REPORT modes move to `/implement` phase** - These modes are now handled during implementation, not directly by the `/project` command.
3. **project-agent output is now a research report** - Previously generated a Typst timeline file directly. Now creates a research report at `specs/{NNN}_{SLUG}/reports/01_{short-slug}.md`.
4. **skill-project sets `researched` status** - Previously set `planned`. Now follows the standard research -> plan -> implement lifecycle.

### Migration from v2.1

| v2.1 Pattern | v3.0 Equivalent |
|--------------|-----------------|
| `/project 234` -> generates timeline directly | `/project 234` -> research only, then `/plan 234` -> `/implement 234` |
| project-agent creates Typst file | project-agent creates research report |
| TRACK/REPORT via `/project {N}` | TRACK/REPORT via `/implement {N}` |
| skill-project -> status: planned | skill-project -> status: researched |

### Migration from v2.0

| v2.0 Pattern | v3.0 Equivalent |
|--------------|-----------------|
| `/market "fintech"` -> task created -> /research asks questions | `/market "fintech"` -> questions asked -> task created with data |
| No task_type field | task_type: "market", "analyze", "strategy", "legal", or "project" |
| `/research` uses language routing | `/research` uses task_type routing when available |
| forcing_data gathered during research | forcing_data gathered at command invocation (STAGE 0) |

### Migration from v1.0

| v1.0 Pattern | v3.0 Equivalent |
|--------------|-----------------|
| `/market fintech` | `/market --quick fintech` (standalone) |
| | `/market "fintech analysis"` (task workflow with pre-task questions) |
| Artifact in `founder/` | Artifact in `strategy/` (task) or `founder/` (--quick) |
| No task tracking | Full task lifecycle with forcing_data storage |
