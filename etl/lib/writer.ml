open Records
open Sqlite3

let db_filename = "data/perts_etl_ocaml.db"

(** [create_table db create_sql] creates a table in the database using the given SQL command.

    @param db An open SQLite database connection.
    @param create_sql A SQL string used to define the table structure. *)
let create_table db create_sql =
  match exec db create_sql with
  | Rc.OK -> ()
  | rc -> Printf.printf "Error creating table: %s\n" (Rc.to_string rc)

(** [insert_record_generic stmt bind_fn record] inserts a single record using a prepared statement.

    @param stmt The prepared SQLite statement.
    @param bind_fn A function to bind the record values into the statement.
    @param record The record to insert. *)
let insert_record_generic stmt bind_fn record =
  bind_fn stmt record;
  match step stmt with
  | Rc.DONE -> reset stmt |> ignore
  | rc ->
      Printf.printf "Error inserting record: %s\n" (Rc.to_string rc);
      reset stmt |> ignore

(** [save_records_generic db insert_sql bind_fn records] inserts a list of records into a database.

    @param db An open SQLite database connection.
    @param insert_sql SQL command for inserting values into a table.
    @param bind_fn A function that binds record values to the statement.
    @param records A list of records to be inserted. *)
let save_records_generic db insert_sql bind_fn records =
  let stmt = prepare db insert_sql in
  List.iter (fun r -> insert_record_generic stmt bind_fn r) records;
  finalize stmt |> ignore

(** [write_records_generic create_sql insert_sql bind_fn records] creates the table (if needed)
    and writes the given records to it.

    @param create_sql SQL command for table creation.
    @param insert_sql SQL command for inserting rows.
    @param bind_fn Function to bind OCaml record values into SQL statements.
    @param records List of records to be saved. *)
let write_records_generic create_sql insert_sql bind_fn records =
  let db = db_open db_filename in
  create_table db create_sql;
  save_records_generic db insert_sql bind_fn records;
  db_close db |> ignore

(** [save_order_summaries records] saves a list of [order_summary] records into the SQLite table [orders_summary].

    @param records List of order summaries to save. *)
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

(** [save_monthly_summaries records] saves a list of [order_mean_summary] records into the SQLite table [monthly_summary].

    @param records List of monthly summaries to save. *)
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

(** [save_order_summaries_csv records filename] writes a list of [order_summary] records into a CSV file.

    @param records List of order summaries.
    @param filename Output CSV filename. *)
let save_order_summaries_csv (records : order_summary list) (filename : string) =
  let oc = open_out filename in
  Printf.fprintf oc "order_id,total_amount,total_taxes\n";
  List.iter (fun r ->
    Printf.fprintf oc "%d,%.2f,%.2f\n" r.order_id r.total_amount r.total_taxes
  ) records;
  close_out oc

(** [save_monthly_summaries_csv records filename] writes a list of [order_mean_summary] records into a CSV file.

    @param records List of monthly summaries.
    @param filename Output CSV filename. *)
let save_monthly_summaries_csv (records : order_mean_summary list) (filename : string) =
  let oc = open_out filename in
  Printf.fprintf oc "mean_amount,mean_taxes,month,year\n";
  List.iter (fun r ->
    Printf.fprintf oc "%.2f,%.2f,%s,%s\n" r.mean_amount r.mean_taxes r.month r.year
  ) records;
  close_out oc