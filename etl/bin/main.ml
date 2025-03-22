open Etl.Reader
open Etl.Helper
open Etl.Records

let () =
  print_endline "Starting ETL pipeline...";
  let order_data = read_csv_url "https://raw.githubusercontent.com/PedroPertusi/etl-ocaml/main/etl/data/order.csv" in
  let item_data = read_csv_url "https://raw.githubusercontent.com/PedroPertusi/etl-ocaml/main/etl/data/order_item.csv" in

  let orders = orders_of_csv order_data in
  let order_items = order_items_of_csv item_data in

  List.iter (fun order ->
    Printf.printf "%d, %d, %s, %s, %s\n"
      order.id
      order.client_id
      order.order_date
      order.status
      order.origin
  ) orders;

  print_endline "------";

  List.iter (fun item ->
    Printf.printf "%d, %d, %d, %f, %f\n"
      item.order_id
      item.product_id
      item.quantity
      item.price
      item.tax
  ) order_items;
