(* reader.ml *)

(** [fetch url] retrieves the contents of the given URL via an HTTP GET request.

    @param url The URL to fetch data from.
    @return The body of the response as a string. *)
let fetch url =
  let uri = (Uri.of_string url) in
  let (_, body) = Lwt_main.run (Cohttp_lwt_unix.Client.get uri) in
  let body_str = Lwt_main.run (Cohttp_lwt.Body.to_string body) in
  body_str ;;

(** [read_csv_url url] fetches a CSV file from a URL and parses it into a list of rows.

    @param url The URL pointing to the CSV file.
    @return A list of rows, where each row is a list of strings. *)
let read_csv_url url =
  let raw_data = fetch url in
  let data = Csv.of_string raw_data |> Csv.input_all in
  data;;
