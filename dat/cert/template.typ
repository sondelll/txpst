// The project function defines how your document looks.
// It takes your content and some metadata and formats it.
// Go ahead and customize it to your liking!

#let CELL_H = 2.25em

#let xbox(
  it,
  label:"",
  size:8pt,
  ksize:5.8pt,
  width:100%,
  height:none
) = box(
  stroke: black,
  inset:5pt,
  width: width,
  height: if height == none {CELL_H} else {height}
)[
  #set par(
    justify: false,
    leading: 3pt
  )

  #set text(
    spacing: 2pt,
    //font: "DM Mono"
  )

  #place(
    dx: -2pt,
    dy: -2pt,
    text(
      font: "Arial",
      size: ksize,
      weight: 400,
      upper(label)
    )
  )

  #align(
    left+horizon,
    pad(top:5.5pt, left:1pt,
      text(
        size: size,
        font: "Arial",
        weight: 600,
        fill: if it == "PASS" { rgb("#0d9d0d") } else { black },
        it
      )
    )
  )
]

#let page_cell() = [
  #let dt = [
    #context counter(page).display() /
    #context counter(page).final().last()
  ]
  #xbox(dt, label:"page")
]

//
// DYNAMIC HEADER
//
#let mini_header(
  item_id:"",
  production_order_number:"",
  sales_order_number:""
) = {
  context {
    if here().page() == 1 {
      //grid(columns: (2fr, 2fr, 1fr), none, none, page_cell())
    } else {
      let dt = [
        #context counter(page).display() /
        #context counter(page).final().last()
      ]
      grid(columns:(2fr, 1fr, 1fr, 1fr),
        xbox(item_id, label:"Art No."),
        xbox(production_order_number, label:"Work Order No."),
        xbox(sales_order_number, label:"OSTP Sales Order No."),
        xbox(dt, label:"page")
      )
    }
  }
}

//
// FOOTER
//
#let footer(
  operators:"",
  operator_date:"",
  interpreters:"",
  interpreter_date:""
) = {
  grid(
    columns: (2.5fr,1.5fr,3.2fr,1.5fr,1fr),
    xbox(
      operators,
      label:"Operator/Cert No.",
      height:1.8*CELL_H,
      size:7pt
    ),
    xbox(
      operator_date,
      label:"Date",
      height:1.8*CELL_H,
      size:8pt
    ),
    xbox(
      interpreters,
      label:"Interpreter/Cert No.",
      height:1.8*CELL_H,
      size:7pt
    ),
    xbox(
      interpreter_date,
      label:"Date",
      height:1.8*CELL_H,
      size:8pt
    ),
    xbox(
      align(center,"II"),
      label:"Level",
      height:1.8*CELL_H,
      size:16pt
    )
  )
}


#let xdat_row(
  k:"",
  _k:"",
  pre_one:"",
  pre_two:"",
  pre_three:"",
  pre_four:"",
  mark_pre:false,
  items:((none), (none), (none), (none)),
) = [
  #let pre(n) = items.at(n).at(_k, default:"")
  #let conv(n) = {
    if type(pre(n)) == str {
      pre(n)
    } else {
      repr(pre(n))
    }
  }
  #let wallness(n) = (
    "Single",
    "Double"
  ).at(pre(n)-2)
  #let convert(n) = if _k == "wall_count"{
    wallness(n)
  }else{
    conv(n)
  }
  #let x(n) = {if pre(n) == "" {""}else{convert(n)}}

  #let pre_one = x(0)
  #let pre_two = x(1)
  #let pre_three = x(2)
  #let pre_four = x(3)
  #let sz = if _k == "wall_count"{7pt}else{8pt}
  #grid(
    columns: (1.25fr, 1fr, 1fr, 1fr, 1fr),
    xbox("", label:k),
    xbox(pre_one, label:if mark_pre {"I"}, size:sz),
    xbox(pre_two, label:if mark_pre {"II"}, size:sz),
    xbox(pre_three, label:if mark_pre {"III"}, size:sz),
    xbox(pre_four, label:if mark_pre {"IV"}, size:sz),
  )
]

//
// Exposure data outer function
//
#let xdat(
  exposure_data_items:(),
  astm_class:"",
  iqi:"",
)={
  let tot = exposure_data_items.len()
  let items = range(4).map((n) => {
    if n < tot {
      exposure_data_items.at(n)
    } else {
    (
      exposure_id:"",shot_volt:"",ffd:"",
      exp_milli_amp_minutes:"",side:"",wall_count:""
    )
    }
  })

  let xdat_inner = {
    xdat_row(
      items:items, _k:"shot_volt",
      k:"kV\nShotvolt", mark_pre:true)
    xdat_row(items:items, k:"FFD mm", _k:"ffd")
    xdat_row(items:items, k:"mA x min", _k:"exp_milli_amp_minutes")
    xdat_row(items:items, k:"Wall", _k:"wall_count")
    xdat_row(items:items, k:"FS/SS", _k:"side")
  }
  let rightmost = stack(
      xbox("", height:3*CELL_H),
      xbox(astm_class, label:"ASTM class"),
      xbox(iqi, label:"IQI")
    )

  grid(
    columns: (1fr, 5fr, 1.5fr),

    rect(
      stroke:(left:3pt+gray),
      inset:(left:1pt, rest:0em),
      outset:(left:-1pt, rest:0em),
      xbox("Exp.\nData", height:5*CELL_H),
    ),
    xdat_inner,
    rightmost
  )
}

#let equip_region(
  equipment_label:"",
  focal_spot:"",
  film_type:"",
  rating_kv:"",
  screens:"",
  illuminator_id:"",
  densitometer_id:"",
  penetra_meter_id:"",
  density:"",
)=[
  #grid(
    columns: (1fr,1fr),
    xbox(equipment_label, label:"X-ray equip."),
    xbox(focal_spot, label:"Focal spot"),
    xbox(film_type, label:"Film type"),
    xbox(rating_kv, label:"Rating (kV)"),
    xbox(screens, label:"Screens"),
    xbox(illuminator_id, label:"Illuminator ID"),
    xbox(densitometer_id, label:"Densitometer ID"),
    xbox(penetra_meter_id, label:"Penetrameter ID"),
  )
    #grid(xbox(density, label:"Density", width:100%))
]

//
// RESULT ROW
//
#let boxed_row(
  short_name:"-",
  position:"-",
  inspection_revision:"-",
  result_code:"-",
  exposure_id:"-",
  welder:"-",
  image_quality:"0.0"
) = [
  #grid(
    columns: (
      1.5fr, 1.5fr,1.25fr, 1.5fr, 5fr, 1.8fr, 3fr,
    ),
    xbox(
      short_name,
      label:"Name",
      height:0.9*CELL_H,
    ),
    xbox(
      position,
      label:"Position",
      height:0.9*CELL_H,
    ),
    xbox(
      repr(inspection_revision),
      label:"Rev",
      height:0.9*CELL_H,
    ),
    xbox(
      exposure_id,
      label:"Exp. data",
      height:0.9*CELL_H,
    ),
    xbox(
      welder,
      label:"Welder",
      height:0.9*CELL_H,
    ),
    xbox(
      image_quality,
      label:"Image Q",
      height:0.9*CELL_H,
    ),
    xbox(
      result_code,
      label:"Remarks",
      height:0.9*CELL_H,
    )
  )
]

#let film_use(d:(())) = {
  if d == none {
    return ""
  }
  for s in d.map((item) => {
    repr(item.film_count)+"x ("+item.film_size+")"
  }) {str(s+"\n")}.trim("\n", )
}

//
//-----------------
// MAIN OBJECT
// -----------------
//

#let report(
  title: "",
  production_id:"",
  item_id:"",
  sales_order:"",
  object_name:"",
  heat_treated:false,
  groove_descriptor:"",
  pw:"",
  density:"",
  welder:"",
  wprocedure:"",
  
  acc_limit_spec:"",
  testing_std:"",
  operators:"",
  operator_date:"",
  interpreters:"",
  interpreter_date:"",
  export_revision:"",
  
  films_tot:"",
  astm_class:"",
  iqi:"",
  xray_equipment:"",
  focal_spot:"",
  film_type:"",
  rating_kv:"",
  screens:"",
  illuminator_id:"",
  densitometer_id:"",
  penetra_meter_id:"",
  procedure:"",
  film_usage:(()),
  exposure_data_items:(),
  exp_weld_spots:"",
  date: none,
  body
) = {
  // Set the document's basic properties.
  set document(author: interpreters, title: title)
  set page(
    paper: "a4",
    //numbering: "1/1",
    number-align: center,
    margin: (x:20mm, top:28mm, bottom:28mm),
    header: [#mini_header(
      production_order_number:production_id,
      item_id:item_id,
      sales_order_number:sales_order
    )],
    footer: [#footer(
      operators:operators,
      operator_date:operator_date,
      interpreters:interpreters,
      interpreter_date:interpreter_date
    )],
    footer-descent: 0em,
    header-ascent: 8pt
  )
  set text(font: "Arial", weight: 400, lang: "en")

  place(right+top)[
    #pad(right:1em,top:-0.25em,
      image("/ostp_black.svg", width: 7em)
    )
  ]
  // Title row.
  pad(y:0.5em)[
    #text(
      weight: 700,
      size:1.1em,
      title,
    )
    #move(dy:-0.5em, dx:1em,
      text(
        weight: 200,
        size:1em,
        "Procedure: "+procedure,
      ) 
    )
  ]
  v(1.25em)
  // Main body.
  set par(justify: false)

  show grid: (it) => block(above: 0em, it)

  grid(
    columns: (3fr,1fr, 1fr, 2fr, 1fr),
    xbox(testing_std, label:"Testing acc. to"),
    xbox(pw, label:"pw"),
    xbox(repr(films_tot), label:"films tot"),
    xbox(sales_order, label:"OSTP sales order no."),
    page_cell(),
  )
  //context here().position().page

  grid(columns: (2.4fr, 2.4fr, 1.6fr, 1.5fr, 1.95fr, 1.3fr),
    xbox(acc_limit_spec, label:"Acc. Limit"),
    xbox(wprocedure, label:"Weld Procedure"),
    xbox(groove_descriptor, label:"Groove Desc"),
    xbox(item_id, label:"Art. No."),
    xbox(production_id, label:"OSTP Work order no."),
    xbox(if heat_treated {"Yes"} else {"No"}, label:"Heat Treated")
  )
  
  let unbroken_obj_name = object_name.replace("\n", " ")
  
  grid(columns: (4fr, 3fr, 2fr), stroke:(bottom:1.5pt),
    xbox(
      object_name,
      label:"Object Name",
      height:2*CELL_H
    ),
    xbox(
      exp_weld_spots,
      label:"Exposure Weld Spots",
      height:2*CELL_H
    ),
    xbox(
      film_use(d:film_usage),
      label:"Film Usage (size)",
      height:2*CELL_H
    )
  )
  v(1pt)
  
  grid(columns: (3fr, 3.5fr),
    equip_region(
      equipment_label:xray_equipment,
      focal_spot:focal_spot,
      film_type:film_type,
      rating_kv:rating_kv,
      screens:screens,
      illuminator_id:illuminator_id,
      densitometer_id:densitometer_id,
      penetra_meter_id:penetra_meter_id,
      density:density
    ),
    xdat(
      exposure_data_items:exposure_data_items,
      astm_class:astm_class,
      iqi:iqi
    )
  )

  v(1em, weak: true)

  body
}
