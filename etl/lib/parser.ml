(* parser.ml *)
open Records

let parse_order_row (row : string list) : order =
  match row with
  | [id_str; client_id_str; order_date_str; status; origin] ->
      let id = int_of_string id_str in
      let client_id = int_of_string client_id_str in
      let date_part = String.sub order_date_str 0 10 in
      { id; client_id; order_date = date_part; status; origin }
  | _ -> assert false

let parse_order_item_row (row : string list) : order_item =
  match row with
  | [order_id_str; product_id_str; quantity_str; price_str; tax_str] ->
      let order_id = int_of_string order_id_str in
      let product_id = int_of_string product_id_str in
      let quantity = int_of_string quantity_str in
      let price = float_of_string price_str in
      let tax = float_of_string tax_str in
      { order_id; product_id; quantity; price; tax }
  | _ -> assert false

let csv_skip_header_map parser (csv : string list list) =
  match csv with
  | [] -> []
  | _header :: rows -> List.map parser rows

let orders_of_csv (csv : string list list) : order list =
  csv_skip_header_map parse_order_row csv

let order_items_of_csv (csv : string list list) : order_item list =
  csv_skip_header_map parse_order_item_row csv