open Etl.Filter
open Etl.Helper
open Etl.Parser
open Etl.Reader
open Etl.Records
open Etl.Transformer

let () =
  print_endline "Starting ETL pipeline...";

  let order_data = read_csv_url "https://raw.githubusercontent.com/PedroPertusi/etl-ocaml/main/etl/data/order.csv" in
  let item_data  = read_csv_url "https://raw.githubusercontent.com/PedroPertusi/etl-ocaml/main/etl/data/order_item.csv" in

  let orders = orders_of_csv order_data in
  let order_items = order_items_of_csv item_data in

  let joined = inner_join_orders orders order_items in

  let filter_status = prompt "Enter status filter (leave blank for none): " in
  let filter_origin = prompt "Enter origin filter (leave blank for none): " in

  let filtered = filter_joined_records joined filter_status filter_origin in

  let aggregated = aggregate_order_items filtered in

  List.iter (fun summary ->
    Printf.printf "Order id: %d, Total Amount: %.2f, Total Taxes: %.2f\n"
      summary.order_id summary.total_amount summary.total_taxes
  ) aggregated