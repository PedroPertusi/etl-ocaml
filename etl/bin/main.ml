(* bin/main.ml *)
open Etl.Etl_extract
open Etl.Csv_parser_order

let () =
  print_endline "Starting ETL pipeline...";
  let order_data : string = fetch_csv_sync "https://raw.githubusercontent.com/PedroPertusi/etl-ocaml/main/etl/data/order.csv" in
  (* let item_data : string = fetch_csv_sync "https://raw.githubusercontent.com/PedroPertusi/etl-ocaml/main/etl/data/order_items.csv" in *)

  (* Convert the CSV string into a list of order records *)
  let orders = parse_orders order_data in
  
  (* Print summary and details of parsed orders *)
  print_endline ("Parsed " ^ string_of_int (List.length orders) ^ " orders");
  List.iter (fun order ->
    Printf.printf "Order: id=%d, client_id=%d, order_date=%s, status=%s, origin=%s\n"
      order.id order.client_id order.order_date order.status order.origin
  ) orders
