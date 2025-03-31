(* parser.ml *)
open Records

(** [parse_order_row row] parses a list of strings representing a row from the "Order" CSV file
    into an [order] record.

    @param row A list of strings containing the order fields: id, client_id, order_date, status, and origin.
    @return An [order] record with the extracted and converted values.
    @raise Assertion_failure if the row does not have exactly 5 fields. *)
let parse_order_row (row : string list) : order =
  match row with
  | [id_str; client_id_str; order_date_str; status; origin] ->
      let id = int_of_string id_str in
      let client_id = int_of_string client_id_str in
      let date_part = String.sub order_date_str 0 10 in
      { id; client_id; order_date = date_part; status; origin }
  | _ -> assert false

(** [parse_order_item_row row] parses a list of strings representing a row from the "OrderItem" CSV file
    into an [order_item] record.

    @param row A list of strings containing the order item fields: order_id, product_id, quantity, price, and tax.
    @return An [order_item] record with the extracted and converted values.
    @raise Assertion_failure if the row does not have exactly 5 fields. *)
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

(** [csv_skip_header_map parser csv] applies a parsing function to all rows in a CSV, skipping the header row.

    @param parser A function that parses a row (list of strings) into a specific record.
    @param csv A list of CSV rows, where the first row is assumed to be the header.
    @return A list of parsed records, excluding the header row. *)
let csv_skip_header_map parser (csv : string list list) =
  match csv with
  | [] -> []
  | _header :: rows -> List.map parser rows

(** [orders_of_csv csv] converts a CSV table into a list of [order] records.

    @param csv A list of CSV rows from the "Order" table.
    @return A list of [order] records. *)
let orders_of_csv (csv : string list list) : order list =
  csv_skip_header_map parse_order_row csv

(** [order_items_of_csv csv] converts a CSV table into a list of [order_item] records.

    @param csv A list of CSV rows from the "OrderItem" table.
    @return A list of [order_item] records. *)
let order_items_of_csv (csv : string list list) : order_item list =
  csv_skip_header_map parse_order_item_row csv