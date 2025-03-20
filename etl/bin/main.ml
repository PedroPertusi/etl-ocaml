(* bin/main.ml *)
open Etl.Etl_extract

let () =
  print_endline "Starting ETL pipeline...";
  let order_data : string = fetch_csv_sync "https://raw.githubusercontent.com/JoaoLucasMBC/etl-ocaml/refs/heads/main/etl/data/order.csv" in
  let item_data : string = fetch_csv_sync "https://raw.githubusercontent.com/JoaoLucasMBC/etl-ocaml/refs/heads/main/etl/data/order_item.csv" in

  print_endline order_data;
  print_endline item_data
