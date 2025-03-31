open Records
open Sqlite3

let db_filename = "data/perts_etl_ocaml.db"

(* (Mesma lógica de antes...) *)
let create_table db create_sql =
  match exec db create_sql with
  | Rc.OK -> ()
  | rc -> Printf.printf "Error creating table: %s\n" (Rc.to_string rc)

let insert_record_generic stmt bind_fn record =
  bind_fn stmt record;
  match step stmt with
  | Rc.DONE -> reset stmt |> ignore
  | rc ->
      Printf.printf "Error inserting record: %s\n" (Rc.to_string rc);
      reset stmt |> ignore

let save_records_generic db insert_sql bind_fn records =
  let stmt = prepare db insert_sql in
  List.iter (fun r -> insert_record_generic stmt bind_fn r) records;
  finalize stmt |> ignore

let write_records_generic create_sql insert_sql bind_fn records =
  let db = db_open db_filename in
  create_table db create_sql;
  save_records_generic db insert_sql bind_fn records;
  db_close db |> ignore

(* Função pública 1: salva order_summaries *)
let save_order_summaries (records : order_summary list) =
  let create_sql =
    "CREATE TABLE IF NOT EXISTS orders_summary (\
      order_id INTEGER PRIMARY KEY,\
      total_amount REAL,\
      total_taxes REAL);" in
  let insert_sql =
    "INSERT INTO orders_summary (order_id, total_amount, total_taxes) VALUES (?, ?, ?);" in
  let bind_fn stmt r =
    Sqlite3.bind stmt 1 (Sqlite3.Data.INT (Int64.of_int r.order_id)) |> ignore;
    Sqlite3.bind stmt 2 (Sqlite3.Data.FLOAT r.total_amount) |> ignore;
    Sqlite3.bind stmt 3 (Sqlite3.Data.FLOAT r.total_taxes) |> ignore
  in
  write_records_generic create_sql insert_sql bind_fn records

(* Função pública 2: salva order_mean_summaries *)
let save_monthly_summaries (records : order_mean_summary list) =
  let create_sql =
    "CREATE TABLE IF NOT EXISTS monthly_summary (\
      mean_amount REAL,\
      mean_taxes REAL,\
      month TEXT,\
      year TEXT);" in
  let insert_sql =
    "INSERT INTO monthly_summary (mean_amount, mean_taxes, month, year) VALUES (?, ?, ?, ?);" in
  let bind_fn stmt r =
    Sqlite3.bind stmt 1 (Sqlite3.Data.FLOAT r.mean_amount) |> ignore;
    Sqlite3.bind stmt 2 (Sqlite3.Data.FLOAT r.mean_taxes) |> ignore;
    Sqlite3.bind stmt 3 (Sqlite3.Data.TEXT r.month) |> ignore;
    Sqlite3.bind stmt 4 (Sqlite3.Data.TEXT r.year) |> ignore
  in
  write_records_generic create_sql insert_sql bind_fn records


let save_order_summaries_csv (records : order_summary list) (filename : string) =
  let oc = open_out filename in
  Printf.fprintf oc "order_id,total_amount,total_taxes\n";
  List.iter (fun r ->
    Printf.fprintf oc "%d,%.2f,%.2f\n" r.order_id r.total_amount r.total_taxes
  ) records;
  close_out oc

let save_monthly_summaries_csv (records : order_mean_summary list) (filename : string) =
  let oc = open_out filename in
  Printf.fprintf oc "mean_amount,mean_taxes,month,year\n";
  List.iter (fun r ->
    Printf.fprintf oc "%.2f,%.2f,%s,%s\n" r.mean_amount r.mean_taxes r.month r.year
  ) records;
  close_out oc
  