open Etl.Filter
open Etl.Helper
open Etl.Parser
open Etl.Reader
(* open Etl.Records *)
open Etl.Transformer
open Etl.Writer

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

  let mean_summary = mean_order_items filtered in

  save_order_summaries_csv aggregated "data/orders_summary.csv";
  
  save_monthly_summaries_csv mean_summary "data/monthly_summary.csv";

  save_order_summaries aggregated;

  save_monthly_summaries mean_summary;

