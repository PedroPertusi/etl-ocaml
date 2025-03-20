let () =
  print_endline "Starting ETL pipeline...";
  let url = "https://raw.githubusercontent.com/PedroPertusi/etl-ocaml/main/etl/data/order.csv" in
  let csv_data = Lwt_main.run (Etl.Etl_extract.fetch_csv url) in
  print_endline csv_data
