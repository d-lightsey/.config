## Founder Extension

Strategic business analysis tools for founders and entrepreneurs. Integrates forcing question patterns and decision frameworks inspired by Y Combinator office hours methodology.

### Commands

| Command | Usage | Description |
|---------|-------|-------------|
| `/market` | `/market [industry] [segment]` | TAM/SAM/SOM market sizing analysis |
| `/analyze` | `/analyze [competitor1,competitor2,...]` | Competitive landscape and positioning analysis |
| `/strategy` | `/strategy [--mode LAUNCH|SCALE|PIVOT|EXPAND]` | Go-to-market strategy development |

### Skill-to-Agent Mapping

| Skill | Agent | Purpose |
|-------|-------|---------|
| skill-market | market-agent | Market sizing with TAM/SAM/SOM framework |
| skill-analyze | analyze-agent | Competitive analysis with positioning maps |
| skill-strategy | strategy-agent | GTM strategy with channel prioritization |

### Context Files

| Path | Purpose |
|------|---------|
| `context/project/founder/domain/business-frameworks.md` | TAM/SAM/SOM, business model canvas |
| `context/project/founder/domain/strategic-thinking.md` | CEO cognitive patterns, YC principles |
| `context/project/founder/patterns/forcing-questions.md` | Forcing question framework |
| `context/project/founder/patterns/decision-making.md` | Two-way doors, inversion, focus as subtraction |
| `context/project/founder/patterns/mode-selection.md` | Operational modes pattern |
| `context/project/founder/templates/market-sizing.md` | TAM/SAM/SOM template |
| `context/project/founder/templates/competitive-analysis.md` | Competitor analysis template |
| `context/project/founder/templates/gtm-strategy.md` | Go-to-market template |

### Key Patterns

**Forcing Questions**: One question per AskUserQuestion, explicit push-back on vague answers. Specificity is the only currency.

**Mode-Based Operation**: Commands offer 3-4 operational modes giving user explicit scope control (e.g., LAUNCH, SCALE, PIVOT, EXPAND).

**Completeness Principle**: Always model multiple scenarios/options. AI makes marginal cost of completeness near-zero.

**Decision Frameworks**:
- Two-way doors (reversible): Move fast
- One-way doors (irreversible): Be rigorous
- Inversion: Also ask "What makes us fail?"
- Focus as subtraction: Explicitly document what NOT to do
