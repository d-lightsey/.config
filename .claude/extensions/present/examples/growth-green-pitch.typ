// Growth Green Theme - Investor Pitch Deck Example
// Mock Startup: GreenPath Energy - Clean Energy Optimization Platform
//
// Colors: Emerald (#047857), Dark Green (#065f46), Light Green (#34d399)
// Typography: Montserrat headings, Inter body
// Best for: Sustainability, health, environmental tech, cleantech

#import "@preview/touying:0.6.3": *
#import themes.simple: *

// Theme configuration - growth green
#show: simple-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [GreenPath Energy],
    subtitle: [AI-Powered Optimization for Renewable Energy Grids],
    author: [Dr. Maya Okonkwo & David Chen],
    date: datetime.today(),
  ),
  config-colors(
    primary: rgb("#047857"),
    secondary: rgb("#065f46"),
    neutral: rgb("#f0fdf4"),
  ),
)

// Light green-tinted background
#set page(fill: rgb("#f0fdf4"))

// Typography settings
#set text(font: "Inter", size: 32pt, fill: rgb("#1a202c"))
#show heading.where(level: 1): set text(font: "Montserrat", size: 48pt, weight: "bold", fill: rgb("#047857"))
#show heading.where(level: 2): set text(font: "Montserrat", size: 40pt, weight: "bold", fill: rgb("#047857"))

// Color palette
#let emerald = rgb("#047857")
#let dark-green = rgb("#065f46")
#let light-green = rgb("#34d399")
#let text-color = rgb("#1a202c")
#let bg = rgb("#f0fdf4")

// ============================================================================
// SLIDE 1: Title
// ============================================================================
= GreenPath Energy

#align(center)[
  #text(size: 36pt, fill: dark-green)[
    AI-Powered Optimization for Renewable Energy Grids
  ]

  #v(2em)

  #text(size: 28pt, fill: rgb("#6b7280"))[
    Series A | Q1 2026
  ]
]

#speaker-note[
  "Thank you for your time. I'm Maya Okonkwo, CEO of GreenPath Energy.
  We're using AI to solve the biggest challenge in renewable energy: grid optimization.
  My co-founder David Chen and I previously led grid modernization at Tesla Energy."
]

// ============================================================================
// SLIDE 2: Problem
// ============================================================================
== The Problem

#v(0.5em)

#text(size: 36pt, weight: "bold", fill: emerald)[
  30% of renewable energy is wasted due to grid inefficiency
]

#v(1em)

- #text(size: 40pt, weight: "bold", fill: emerald)[\$62B] lost annually to curtailment
- #text(size: 40pt, weight: "bold", fill: emerald)[340M] tons CO2 from backup generation
- #text(size: 40pt, weight: "bold", fill: emerald)[1970s] era grid management tech

#v(1em)

*The irony*: We're building clean energy faster than grids can use it efficiently.

#speaker-note[
  "Here's the challenge: 30 percent of renewable energy is wasted.
  62 billion dollars lost annually to curtailment - that's clean energy we generate but can't use.
  340 million tons of CO2 from backup fossil fuel generation.
  And we're managing modern renewable grids with 1970s technology."
]

// ============================================================================
// SLIDE 3: Solution
// ============================================================================
== Our Solution

#v(0.5em)

#text(size: 36pt, weight: "bold", fill: emerald)[
  AI that predicts and optimizes renewable energy flow in real-time
]

#v(1em)

+ #text(fill: emerald)[*Predict*] -- ML models forecast solar/wind generation 24 hours ahead with 97% accuracy
+ #text(fill: emerald)[*Optimize*] -- Dynamic routing algorithms maximize clean energy utilization
+ #text(fill: emerald)[*Store*] -- Smart battery orchestration for peak demand and backup

#speaker-note[
  "GreenPath has three components. First, we predict solar and wind generation
  24 hours ahead with 97 percent accuracy. Second, we optimize energy routing
  in real-time to maximize clean energy usage. Third, we orchestrate battery
  storage to smooth demand peaks and provide backup without fossil fuels."
]

// ============================================================================
// SLIDE 4: Traction
// ============================================================================
== Traction

#text(size: 40pt, weight: "bold", fill: emerald)[\$3.2M ARR] | #text(size: 40pt, weight: "bold", fill: emerald)[12 Utility Partners] | #text(size: 40pt, weight: "bold", fill: emerald)[8.4GW Managed] | #text(size: 40pt, weight: "bold", fill: emerald)[18% Efficiency Gain]

#v(1em)

*Impact Delivered*

- 2.1M tons CO2 avoided (equivalent to 450K cars off the road)
- \$48M in savings delivered to utility partners
- Zero unplanned outages across managed grids

#speaker-note[
  "We're at 3.2 million ARR with 12 utility partners.
  We manage 8.4 gigawatts of renewable capacity.
  Our customers see 18 percent average efficiency gains.
  We've avoided 2.1 million tons of CO2 - equivalent to taking 450,000 cars off the road."
]

// ============================================================================
// SLIDE 5: Why Us / Why Now
// ============================================================================
== Why Us / Why Now

#v(0.5em)

#grid(
  columns: (1fr, 1fr),
  gutter: 2em,
  [
    #text(fill: emerald, weight: "bold", size: 28pt)[Why Now]

    #v(0.5em)

    - IRA provides \$370B for clean energy
    - Renewable capacity doubling by 2030
    - Grid modernization mandates in 30 states
    - Battery costs down 90% in 10 years
  ],
  [
    #text(fill: emerald, weight: "bold", size: 28pt)[Why Us]

    #v(0.5em)

    - Team built Tesla's grid software
    - Proprietary weather + demand models
    - Only AI-native solution (not retrofitted)
    - Partnerships with 3 of top 10 utilities
  ],
)

#speaker-note[
  "The Inflation Reduction Act provides 370 billion for clean energy infrastructure.
  Renewable capacity will double by 2030. Grids must modernize.
  Our team built Tesla's grid management software.
  We're the only AI-native solution - built from the ground up for renewables."
]

// ============================================================================
// SLIDE 6: Business Model
// ============================================================================
== Business Model

#v(0.5em)

#grid(
  columns: (1fr, 1fr),
  gutter: 2em,
  [
    #text(fill: emerald, weight: "bold", size: 28pt)[Revenue Streams]

    #v(0.5em)

    - *Platform SaaS*: \$150K-\$500K/year per utility
    - *Performance fee*: 10% of efficiency savings
    - *Data licensing*: Grid intelligence to developers

    #v(1em)

    *Average Contract*: \$320K ACV
    *(Platform + performance)*
  ],
  [
    #text(fill: emerald, weight: "bold", size: 28pt)[Unit Economics]

    #v(0.5em)

    #grid(
      columns: (1fr, 1fr),
      gutter: 8pt,
      [*Gross Margin*], [76%],
      [*CAC*], [\$120K],
      [*LTV*], [\$1.6M],
      [*Payback*], [11 months],
    )

    #v(1em)

    *LTV:CAC Ratio*: 13:1
  ],
)

#speaker-note[
  "We have a hybrid model: SaaS platform fees plus performance-based revenue.
  Utilities pay 150 to 500K annually for the platform.
  We also take 10 percent of efficiency savings we deliver.
  Average contract is 320K with 76 percent gross margins."
]

// ============================================================================
// SLIDE 7: Market Opportunity
// ============================================================================
== Market Opportunity

*Total Addressable Market (TAM)*: \$124B -- Global Grid Modernization

*Serviceable Addressable Market (SAM)*: \$28B -- Renewable Grid Software

*Serviceable Obtainable Market (SOM)*: \$4.2B -- 5-Year Target

#v(1em)

Bottom-up calculation: 3,000 utilities globally x 15% adopting AI x \$940K avg spend = \$4.2B

#speaker-note[
  "Grid modernization is a 124 billion dollar market.
  Renewable grid software is 28 billion and growing 30 percent annually.
  Our 5-year target is 4.2 billion - 15 percent of global utilities at 940K average spend."
]

// ============================================================================
// SLIDE 8: Team
// ============================================================================
== Team

#v(0.5em)

#grid(
  columns: (1fr, 1fr),
  gutter: 2em,
  [
    #text(fill: emerald, weight: "bold", size: 28pt)[Dr. Maya Okonkwo]

    CEO & Co-founder

    - Director of Grid Software, Tesla Energy (5 years)
    - PhD Electrical Engineering, Stanford
    - Led Powerwall fleet optimization
    - Board member, Clean Energy Council
  ],
  [
    #text(fill: emerald, weight: "bold", size: 28pt)[David Chen]

    CTO & Co-founder

    - Principal ML Engineer, Tesla Autopilot
    - MS Computer Science, MIT
    - Built real-time prediction systems at scale
    - 15 patents in energy optimization
  ],
)

#v(0.5em)

*Key Advisors*: Former CEO of PG&E, Chief Scientist at NREL, Partner at Breakthrough Energy

#speaker-note[
  "Maya led Tesla Energy's grid software for 5 years.
  David built real-time prediction systems for Tesla Autopilot.
  We have 15 patents in energy optimization.
  Our advisors include the former CEO of PG&E and leadership from Breakthrough Energy."
]

// ============================================================================
// SLIDE 9: The Ask
// ============================================================================
== The Ask

#v(0.5em)

#align(center)[
  #text(size: 48pt, weight: "bold", fill: emerald)[
    Raising \$18M Series A
  ]
]

#v(1em)

#grid(
  columns: (1fr, 1fr),
  gutter: 2em,
  [
    #text(fill: emerald, weight: "bold", size: 28pt)[Use of Funds]

    #v(0.5em)

    - 45% Engineering (ML + Platform)
    - 30% Sales (utility partnerships)
    - 15% Deployments & success
    - 10% Operations
  ],
  [
    #text(fill: emerald, weight: "bold", size: 28pt)[18-Month Milestones]

    #v(0.5em)

    - \$12M ARR (4x growth)
    - 35 utility partners
    - 25GW managed capacity
    - European market entry
  ],
)

#v(1em)

*Lead investor*: Breakthrough Energy Ventures | *Existing*: Lowercarbon Capital

#speaker-note[
  "We're raising 18 million at Series A to scale deployment.
  45 percent goes to engineering - ML models and platform expansion.
  In 18 months, we'll quadruple revenue to 12 million and manage 25 gigawatts.
  Breakthrough Energy is leading with participation from Lowercarbon Capital."
]

// ============================================================================
// SLIDE 10: Thank You
// ============================================================================
== Thank You

#v(1em)

#align(center)[
  #text(size: 48pt, weight: "bold", fill: emerald)[
    GreenPath Energy
  ]

  #v(0.5em)

  #text(size: 32pt, fill: dark-green)[
    Optimizing the Clean Energy Transition
  ]

  #v(2em)

  #text(size: 28pt, fill: text-color)[
    maya\@greenpath.energy

    greenpath.energy
  ]

  #v(1em)

  #text(size: 28pt, fill: rgb("#6b7280"))[
    Impact metrics and technical architecture in appendix
  ]
]

#speaker-note[
  "Thank you. The clean energy transition is happening.
  The question is whether we can use that energy efficiently.
  GreenPath makes sure not a single watt of clean energy goes to waste.
  I'm happy to answer questions."
]
