#import "template.typ": *

#let d = json("data.json")

#let foc_spot = (
  x:repr(d.at("equipment",default:(focal_spot_x:0)).at("focal_spot_x")),
  y:repr(d.at("equipment",default:(focal_spot_y:0)).at("focal_spot_y"))
)

#show: report.with(
  title: "TEST CERTIFICATE - RADIOGRAPHY OF WELDS",
  production_id:d.at("production_order_number",default:""),
  item_id:d.at("item_id",default:""),
  object_name:d.at("object_name", default:""),
  heat_treated:d.at("heat_treated", default:false),
  
  interpreters: d.at("interpreter",default:""),
  interpreter_date:d.at("interpreter_date",default:""),
  operators:d.at("operators",default:""),
  operator_date:d.at("operator_date",default:""),
  testing_std:d.at("testing_standard",default:""),
  sales_order:d.at("sales_order",default:""),
  films_tot:d.at("films_total",default:0),
  pw:d.at("pw",default:""),
  acc_limit_spec:d.at("acceptance_limit_spec",default:""),
  film_usage:d.at("film_usage", default:none),
  astm_class:d.at("astm_class",default:""),
  iqi:d.at("iqi_descriptor",default:""),
  xray_equipment:d.at("equipment", default:(label:"")).at("label",default:""),
  focal_spot:foc_spot.x+" x "+foc_spot.y,
  film_type:d.at("film_type",default:""),
  rating_kv:repr(d.at("equipment",default:(rating_kv:0)).at("rating_kv")),
  screens:d.at("equipment",default:(screens:"")).at("screens"),
  illuminator_id:d.at("equipment",default:(illuminator_id:"")).at("illuminator_id"),
  densitometer_id:d.at("equipment",default:(densitometer_id:"")).at("densitometer_id"),
  penetra_meter_id:d.at("equipment",default:(penetra_meter_id:"")).at("penetra_meter_id"),
  density:d.at("density",default:""),
  groove_descriptor:d.at("groove_descriptor", default:""),
  procedure:d.at("procedure", default:""),
  welder:d.at("welder", default:""),
  wprocedure:d.at("weld_process", default:""),
  exposure_data_items:d.at("exposure_data_items",default:()),
  exp_weld_spots:d.at("exposureWeldSpots", default:""),
  date: "",
)

#let rows = d.at("rows",default:())

#for item in rows {
  boxed_row(
    exposure_id:item.exposure_id,
    position:item.position,
    short_name:item.short_name,
    result_code:item.result_code,
    image_quality:repr(item.image_quality),
    inspection_revision:item.inspection_revision,
    welder:item.welder
  )
}
