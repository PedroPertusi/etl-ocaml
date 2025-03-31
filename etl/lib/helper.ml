(* helper.ml *)

let prompt message =
  print_string message;
  flush stdout;
  let input = read_line () in
  if input = "" then None else Some input

let extract_month_year date =
  String.sub date 0 7  (* returns "YYYY-MM" *)

let split_date date =
  match String.split_on_char '-' date with
  | [year; month] -> (year, month)
  | _ -> assert false

let list_group_by f lst =
  let rec aux acc = function
    | [] -> acc
    | h :: t ->
        let key = f h in
        let group = List.filter (fun x -> f x = key) lst in
        aux ((key, group) :: acc) (List.filter (fun x -> f x <> key) t)
  in
  aux [] lst