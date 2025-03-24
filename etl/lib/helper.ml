(* helper.ml *)

let prompt message =
  print_string message;
  flush stdout;
  let input = read_line () in
  if input = "" then None else Some input