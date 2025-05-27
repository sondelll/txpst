
#let ctx_data = json("context.json")

#let example_doc(
  title: "EXAMPLE PDF",
  body
) = {
  // Set the document's basic properties.
  set document(author: "TXP_SYSTEM", title: title)
  set page(
    paper: "a4",
    //numbering: "1/1",
    number-align: center,
    margin: (x:20mm, top:28mm, bottom:28mm),
    header: [/example | as requested by #ctx_data.fromIP],
    footer: [TXP Preview, #ctx_data.timestamp],
    footer-descent: 0em,
    header-ascent: 8pt
  )
  set text(weight: 400, lang: "en")

  // place(right+top)[
  //   #pad(right:1em,top:-0.25em,
  //     image("/ostp_black.svg", width: 7em)
  //   )
  // ]
  
  // Title row.
  pad(y:0.5em)[
    #text(
      weight: 700,
      size:2em,
      title,
    )
  ]
  v(1.25em)
  // Main body.
  set par(justify: false)

  v(1em, weak: true)

  body
}

#show: example_doc.with()

= Introduction
This is just example text to demonstrate the templating. Please recieve this lorem ipsum, free of charge :)

#lorem(64)

