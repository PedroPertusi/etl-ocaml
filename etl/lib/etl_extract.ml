(* etl_extract.ml *)

open Lwt
open Cohttp
open Cohttp_lwt_unix

let fetch_csv (url : string) : string Lwt.t =
  Client.get (Uri.of_string url) >>= fun (resp, body) ->
  let status = resp |> Response.status |> Code.code_of_status in
  if status = 200 then
    Cohttp_lwt.Body.to_string body
  else
    Lwt.fail_with (Printf.sprintf "HTTP request failed with code: %d" status)

(* Synchronous wrapper: *)
let fetch_csv_sync (url : string) : string =
  Lwt_main.run (fetch_csv url)
