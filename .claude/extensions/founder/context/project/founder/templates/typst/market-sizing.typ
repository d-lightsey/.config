// Market Sizing Template for Typst
// Generates professional TAM/SAM/SOM market analysis documents
// Import: #import "strategy-template.typ": *

#import "strategy-template.typ": *

// Market sizing document wrapper
#let market-sizing-doc(
  project: "",
  date: "",
  mode: "SIZE",
  // Executive summary content
  summary: "",
  // Market definition
  problem-statement: "",
  target-customer: "",
  customer-dimensions: (),  // Array of (dimension, definition) tuples
  // TAM section
  tam-value: "",
  tam-methodology: "Bottom-Up",
  tam-calculation: "",
  tam-sources: (),  // Array of (source, data-point, confidence) tuples
  // SAM section
  sam-value: "",
  sam-percent: "",
  narrowing-factors: (),  // Array of (factor, reduction, rationale) tuples
  sam-calculation: "",
  // SOM section
  som-values: (),  // Array of (timeframe, rate, value, rationale) tuples
  competitors: (),  // Array of (name, share, advantage) tuples
  // Assumptions
  assumptions: (),  // Array of (assumption, sensitivity, if-wrong) tuples
  // VC checks
  vc-checks: (),  // Array of (criterion, status, notes) tuples
  validation-steps: (),
  // Investor one-pager
  opportunity-summary: "",
  why-now: (),  // Array of strings
  // Appendix content
  appendix-calculations: none,
  appendix-sources: none,
  doc,
) = {
  show: strategy-doc.with(
    title: "Market Sizing Analysis",
    project: project,
    date: date,
    mode: mode,
  )

  // Executive Summary
  heading(level: 1)[Executive Summary]
  executive-summary[#summary]

  // Key metrics row
  v(1em)
  metric-row(
    (label: "TAM", value: tam-value),
    (label: "SAM", value: sam-value, subtitle: sam-percent + " of TAM"),
    (label: "SOM Y1", value: if som-values.len() > 0 { som-values.at(0).value } else { "TBD" }),
  )

  // Market Definition
  heading(level: 1)[Market Definition]

  heading(level: 2)[Problem Statement]
  problem-statement

  heading(level: 2)[Target Customer]
  target-customer

  if customer-dimensions.len() > 0 [
    #strategy-table(
      columns: (auto, 1fr),
      header: ("Dimension", "Definition"),
      ..customer-dimensions.map(d => (d.dimension, d.definition)),
    )
  ]

  // TAM Section
  heading(level: 1)[TAM: Total Addressable Market]

  metric-callout("Total Addressable Market", tam-value)

  heading(level: 2)[Methodology: #tam-methodology]
  tam-calculation

  if tam-sources.len() > 0 [
    #heading(level: 2)[Data Sources]
    #strategy-table(
      columns: (1fr, 1fr, auto),
      header: ("Source", "Data Point", "Confidence"),
      ..tam-sources.map(s => (s.source, s.data-point, s.confidence)),
    )
  ]

  // SAM Section
  heading(level: 1)[SAM: Serviceable Available Market]

  metric-callout("Serviceable Available Market", sam-value, subtitle: sam-percent + " of TAM")

  if narrowing-factors.len() > 0 [
    #heading(level: 2)[Narrowing Factors]
    #strategy-table(
      columns: (auto, auto, 1fr),
      header: ("Factor", "TAM Reduction", "Rationale"),
      ..narrowing-factors.map(f => (f.factor, f.reduction, f.rationale)),
    )
  ]

  heading(level: 2)[Calculation]
  sam-calculation

  // SOM Section
  heading(level: 1)[SOM: Serviceable Obtainable Market]

  if som-values.len() > 0 [
    #heading(level: 2)[Capture Rate Assumptions]
    #strategy-table(
      columns: (auto, auto, auto, 1fr),
      header: ("Timeframe", "Capture Rate", "SOM Value", "Rationale"),
      ..som-values.map(s => (s.timeframe, s.rate, s.value, s.rationale)),
    )
  ]

  if competitors.len() > 0 [
    #heading(level: 2)[Competitive Context]
    #strategy-table(
      columns: (auto, auto, 1fr),
      header: ("Competitor", "Est. Market Share", "Your Advantage"),
      ..competitors.map(c => (c.name, c.share, c.advantage)),
    )
  ]

  // Market Visualization
  heading(level: 1)[Market Visualization]
  market-circles(
    tam: tam-value,
    sam: sam-value,
    som: if som-values.len() > 0 { som-values.at(0).value } else { "TBD" },
  )

  // Key Assumptions
  if assumptions.len() > 0 [
    #heading(level: 1)[Key Assumptions]
    #strategy-table(
      columns: (auto, 1fr, auto, 1fr),
      header: ("#", "Assumption", "Sensitivity", "If Wrong"),
      ..assumptions.enumerate().map(((i, a)) => (str(i + 1), a.assumption, a.sensitivity, a.if-wrong)),
    )
  ]

  // Red Flags & Validation
  heading(level: 1)[Red Flags & Validation]

  if vc-checks.len() > 0 [
    #heading(level: 2)[VC Threshold Check]
    #strategy-table(
      columns: (1fr, auto, 1fr),
      header: ("Criterion", "Status", "Notes"),
      ..vc-checks.map(c => (c.criterion, c.status, c.notes)),
    )
  ]

  if validation-steps.len() > 0 [
    #heading(level: 2)[Validation Next Steps]
    #for (i, step) in validation-steps.enumerate() [
      + #step
    ]
  ]

  // Investor One-Pager
  heading(level: 1)[Investor One-Pager]

  highlight-box(title: "The Opportunity")[
    #opportunity-summary
  ]

  heading(level: 2)[Key Numbers]
  list(
    [*TAM:* #tam-value],
    [*SAM:* #sam-value (#sam-percent)],
    ..som-values.map(s => [*SOM #s.timeframe:* #s.value]),
  )

  if why-now.len() > 0 [
    #heading(level: 2)[Why This Market, Why Now]
    #for point in why-now [
      - #point
    ]
  ]

  // Appendices
  if appendix-calculations != none [
    #appendix(title: "Appendix: Detailed Calculations")[
      #appendix-calculations
    ]
  ]

  if appendix-sources != none [
    #appendix(title: "Appendix: Source Links")[
      #appendix-sources
    ]
  ]

  doc
}
