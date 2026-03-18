// Founder Strategy Template
// Base template for professional strategy documents
// Used by: market-sizing.typ, competitive-analysis.typ, gtm-strategy.typ

// Document setup
#let strategy-doc(
  title: "",
  project: "",
  date: "",
  mode: "",
  doc,
) = {
  // Page setup
  set page(
    paper: "us-letter",
    margin: (top: 1in, bottom: 1in, left: 1in, right: 1in),
    header: context {
      if counter(page).get().first() > 1 [
        #set text(size: 9pt, fill: gray)
        #project #h(1fr) #title
      ]
    },
    footer: context {
      set text(size: 9pt, fill: gray)
      h(1fr)
      counter(page).display("1 / 1", both: true)
      h(1fr)
    },
  )

  // Typography
  set text(font: "New Computer Modern", size: 11pt)
  set par(justify: true, leading: 0.65em)

  // Heading styles
  set heading(numbering: "1.1")
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    v(0.5em)
    text(size: 18pt, weight: "bold")[#it]
    v(0.5em)
  }
  show heading.where(level: 2): it => {
    v(0.8em)
    text(size: 14pt, weight: "bold")[#it]
    v(0.3em)
  }
  show heading.where(level: 3): it => {
    v(0.5em)
    text(size: 12pt, weight: "bold")[#it]
    v(0.2em)
  }

  // Table styling
  set table(
    stroke: 0.5pt + gray,
    inset: 8pt,
  )
  show table.cell.where(y: 0): strong

  // Title page
  align(center)[
    #v(2in)
    #text(size: 28pt, weight: "bold")[#title]
    #v(0.5em)
    #text(size: 14pt, fill: gray)[#project]
    #v(2em)
    #line(length: 40%, stroke: 0.5pt + gray)
    #v(1em)
    #text(size: 12pt)[
      *Date:* #date \
      *Mode:* #mode \
      *Prepared by:* Claude
    ]
    #v(1fr)
    #text(size: 10pt, fill: gray)[Confidential - Internal Use Only]
  ]

  pagebreak()

  doc
}

// Executive summary block
#let executive-summary(content) = {
  rect(
    width: 100%,
    fill: rgb("#f5f5f5"),
    inset: 16pt,
    radius: 4pt,
  )[
    #text(weight: "bold", size: 12pt)[Executive Summary]
    #v(0.5em)
    #content
  ]
}

// Key metric callout
#let metric-callout(label, value, subtitle: none) = {
  rect(
    width: 100%,
    fill: rgb("#e8f4f8"),
    inset: 12pt,
    radius: 4pt,
  )[
    #align(center)[
      #text(size: 10pt, fill: gray)[#label]
      #v(0.2em)
      #text(size: 24pt, weight: "bold")[#value]
      #if subtitle != none [
        #v(0.1em)
        #text(size: 9pt, fill: gray)[#subtitle]
      ]
    ]
  ]
}

// Metric row (3 metrics side by side)
#let metric-row(..metrics) = {
  let items = metrics.pos()
  grid(
    columns: items.len(),
    column-gutter: 12pt,
    ..items.map(m => metric-callout(m.label, m.value, subtitle: m.at("subtitle", default: none)))
  )
}

// Highlight box for key insights
#let highlight-box(title: "Key Insight", content) = {
  rect(
    width: 100%,
    stroke: (left: 3pt + rgb("#2563eb")),
    fill: rgb("#f0f7ff"),
    inset: 12pt,
  )[
    #text(weight: "bold", fill: rgb("#2563eb"))[#title]
    #v(0.3em)
    #content
  ]
}

// Warning/red flag box
#let warning-box(title: "Red Flag", content) = {
  rect(
    width: 100%,
    stroke: (left: 3pt + rgb("#dc2626")),
    fill: rgb("#fef2f2"),
    inset: 12pt,
  )[
    #text(weight: "bold", fill: rgb("#dc2626"))[#title]
    #v(0.3em)
    #content
  ]
}

// Success/validation box
#let success-box(title: "Validation", content) = {
  rect(
    width: 100%,
    stroke: (left: 3pt + rgb("#16a34a")),
    fill: rgb("#f0fdf4"),
    inset: 12pt,
  )[
    #text(weight: "bold", fill: rgb("#16a34a"))[#title]
    #v(0.3em)
    #content
  ]
}

// Styled table with header row
#let strategy-table(columns: auto, header: (), ..rows) = {
  let all-rows = rows.pos()
  table(
    columns: columns,
    fill: (_, y) => if y == 0 { rgb("#f1f5f9") } else { none },
    align: (col, _) => if col == 0 { left } else { center },
    table.header(..header.map(h => [*#h*])),
    ..all-rows.flatten(),
  )
}

// Comparison table (for feature comparisons)
#let comparison-table(columns: auto, header: (), ..rows) = {
  let all-rows = rows.pos()
  table(
    columns: columns,
    fill: (x, y) => {
      if y == 0 { rgb("#f1f5f9") }
      else if x == 1 { rgb("#e8f4f8") }  // Highlight "Us" column
      else { none }
    },
    align: (col, _) => if col == 0 { left } else { center },
    table.header(..header.map(h => [*#h*])),
    ..all-rows.flatten(),
  )
}

// Section divider
#let section-divider() = {
  v(1em)
  line(length: 100%, stroke: 0.5pt + gray)
  v(1em)
}

// Positioning map (2x2 grid)
#let positioning-map(
  x-axis: "X Axis",
  y-axis: "Y Axis",
  quadrants: (
    top-left: [],
    top-right: [],
    bottom-left: [],
    bottom-right: [],
  ),
) = {
  rect(
    width: 100%,
    inset: 16pt,
    stroke: 0.5pt + gray,
  )[
    #align(center)[
      #text(weight: "bold", size: 11pt)[#y-axis]
      #v(0.3em)
      #grid(
        columns: (1fr, 1fr),
        rows: (auto, auto),
        gutter: 1pt,
        rect(fill: rgb("#f8fafc"), inset: 12pt)[
          #text(size: 9pt, fill: gray)[High #y-axis / Low #x-axis]
          #v(0.5em)
          #quadrants.top-left
        ],
        rect(fill: rgb("#f0fdf4"), inset: 12pt)[
          #text(size: 9pt, fill: gray)[High #y-axis / High #x-axis]
          #v(0.5em)
          #quadrants.top-right
        ],
        rect(fill: rgb("#fef2f2"), inset: 12pt)[
          #text(size: 9pt, fill: gray)[Low #y-axis / Low #x-axis]
          #v(0.5em)
          #quadrants.bottom-left
        ],
        rect(fill: rgb("#f8fafc"), inset: 12pt)[
          #text(size: 9pt, fill: gray)[Low #y-axis / High #x-axis]
          #v(0.5em)
          #quadrants.bottom-right
        ],
      )
      #v(0.3em)
      #text(weight: "bold", size: 11pt)[#x-axis]
    ]
  ]
}

// Concentric circles diagram (for TAM/SAM/SOM)
#let market-circles(tam: "", sam: "", som: "") = {
  align(center)[
    #rect(
      width: 80%,
      inset: 20pt,
      stroke: none,
    )[
      // Outer circle (TAM)
      #rect(
        width: 100%,
        height: 200pt,
        fill: rgb("#dbeafe"),
        radius: 100pt,
        stroke: 1pt + rgb("#3b82f6"),
      )[
        #align(center + top)[
          #v(10pt)
          #text(weight: "bold", fill: rgb("#1e40af"))[TAM: #tam]
          #v(2pt)
          #text(size: 9pt, fill: rgb("#3b82f6"))[Total Addressable Market]
        ]
        // Middle circle (SAM)
        #v(-140pt)
        #align(center)[
          #rect(
            width: 70%,
            height: 140pt,
            fill: rgb("#bbf7d0"),
            radius: 70pt,
            stroke: 1pt + rgb("#22c55e"),
          )[
            #align(center + top)[
              #v(8pt)
              #text(weight: "bold", fill: rgb("#166534"))[SAM: #sam]
              #v(2pt)
              #text(size: 9pt, fill: rgb("#22c55e"))[Serviceable Market]
            ]
            // Inner circle (SOM)
            #v(-90pt)
            #align(center)[
              #rect(
                width: 60%,
                height: 80pt,
                fill: rgb("#fef08a"),
                radius: 40pt,
                stroke: 1pt + rgb("#eab308"),
              )[
                #align(center + horizon)[
                  #text(weight: "bold", fill: rgb("#854d0e"))[SOM: #som]
                  #v(2pt)
                  #text(size: 9pt, fill: rgb("#a16207"))[Obtainable]
                ]
              ]
            ]
          ]
        ]
      ]
    ]
  ]
}

// Competitor profile card
#let competitor-card(
  name: "",
  category: "",
  positioning: "",
  strengths: (),
  weaknesses: (),
  pricing: "",
) = {
  rect(
    width: 100%,
    stroke: 0.5pt + gray,
    inset: 12pt,
    radius: 4pt,
  )[
    #grid(
      columns: (1fr, auto),
      [
        #text(weight: "bold", size: 14pt)[#name]
        #h(8pt)
        #text(size: 10pt, fill: gray)[#category]
      ],
      text(size: 10pt)[#pricing],
    )
    #v(0.3em)
    #text(style: "italic", size: 10pt)[#positioning]
    #v(0.5em)
    #grid(
      columns: (1fr, 1fr),
      column-gutter: 16pt,
      [
        #text(weight: "bold", fill: rgb("#16a34a"), size: 10pt)[Strengths]
        #for s in strengths [
          - #s
        ]
      ],
      [
        #text(weight: "bold", fill: rgb("#dc2626"), size: 10pt)[Weaknesses]
        #for w in weaknesses [
          - #w
        ]
      ],
    )
  ]
}

// Battle card
#let battle-card(
  competitor: "",
  their-pitch: "",
  our-response: "",
  objections: (),
  win-signals: (),
  lose-signals: (),
) = {
  rect(
    width: 100%,
    stroke: 1pt + rgb("#3b82f6"),
    fill: rgb("#f8fafc"),
    inset: 16pt,
    radius: 4pt,
  )[
    #text(weight: "bold", size: 14pt, fill: rgb("#1e40af"))[vs #competitor]
    #v(0.5em)

    #grid(
      columns: (1fr, 1fr),
      column-gutter: 16pt,
      [
        #text(weight: "bold", size: 10pt)[Their Pitch]
        #rect(fill: white, inset: 8pt, radius: 2pt)[
          #text(style: "italic")[#their-pitch]
        ]
      ],
      [
        #text(weight: "bold", size: 10pt)[Our Response]
        #rect(fill: white, inset: 8pt, radius: 2pt)[
          #our-response
        ]
      ],
    )
    #v(0.5em)

    #if objections.len() > 0 [
      #text(weight: "bold", size: 10pt)[Objections & Responses]
      #for obj in objections [
        - *"#obj.objection"* - #obj.response
      ]
      #v(0.3em)
    ]

    #grid(
      columns: (1fr, 1fr),
      column-gutter: 16pt,
      [
        #text(weight: "bold", fill: rgb("#16a34a"), size: 10pt)[Win Signals]
        #for s in win-signals [
          - #s
        ]
      ],
      [
        #text(weight: "bold", fill: rgb("#dc2626"), size: 10pt)[Lose Signals]
        #for s in lose-signals [
          - #s
        ]
      ],
    )
  ]
}

// Timeline visualization
#let timeline(phases: ()) = {
  let phase-count = phases.len()
  rect(
    width: 100%,
    inset: 16pt,
    stroke: 0.5pt + gray,
    radius: 4pt,
  )[
    #for (i, phase) in phases.enumerate() [
      #grid(
        columns: (auto, 1fr),
        column-gutter: 12pt,
        [
          #circle(
            radius: 12pt,
            fill: if phase.at("complete", default: false) { rgb("#22c55e") } else { rgb("#e5e7eb") },
            stroke: 1pt + if phase.at("complete", default: false) { rgb("#16a34a") } else { gray },
          )[
            #align(center + horizon)[
              #text(
                weight: "bold",
                size: 10pt,
                fill: if phase.at("complete", default: false) { white } else { gray },
              )[#str(i + 1)]
            ]
          ]
        ],
        [
          #text(weight: "bold")[#phase.name]
          #if phase.at("duration", default: none) != none [
            #h(8pt)
            #text(size: 9pt, fill: gray)[#phase.duration]
          ]
          #v(0.2em)
          #text(size: 10pt)[#phase.description]
        ],
      )
      #if i < phase-count - 1 [
        #h(12pt)
        #line(start: (0pt, 0pt), end: (0pt, 16pt), stroke: 1pt + gray)
        #v(4pt)
      ]
    ]
  ]
}

// Appendix section
#let appendix(title: "Appendix", content) = {
  pagebreak()
  heading(level: 1, numbering: none)[#title]
  content
}
