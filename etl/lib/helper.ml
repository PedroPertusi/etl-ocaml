(* helper.ml *)

(** [prompt message] prints a message and reads user input from the command line.
    If the input is empty, returns [None]; otherwise, returns [Some input].

    @param message The message to display before waiting for input.
    @return An option type containing the input string or [None] if empty. *)
let prompt message =
  print_string message;
  flush stdout;
  let input = read_line () in
  if input = "" then None else Some input

(** [extract_month_year date] extracts the "YYYY-MM" part from a date string assumed to be in "YYYY-MM-DD" format.

    @param date A string representing a date in the format "YYYY-MM-DDTHH:MM:SS" or "YYYY-MM-DD".
    @return A substring containing only the "YYYY-MM" portion. *)
let extract_month_year date =
  String.sub date 0 7  (* returns "YYYY-MM" *)

(** [split_date date] splits a date string in "YYYY-MM" format into a pair (year, month).

    @param date A string in the format "YYYY-MM".
    @return A tuple (year, month) as strings. Raises an assertion failure if the format is invalid. *)
let split_date date =
  match String.split_on_char '-' date with
  | [year; month] -> (year, month)
  | _ -> assert false

(** [list_group_by f lst] groups elements of [lst] by a key generated from each element using function [f].

    @param f A function that takes an element and returns a key to group by.
    @param lst The list of elements to group.
    @return A list of pairs where each pair is (key, group), with [group] being a list of elements with the same key. *)
let list_group_by f lst =
  let rec aux acc = function
    | [] -> acc
    | h :: t ->
        let key = f h in
        let group = List.filter (fun x -> f x = key) lst in
        aux ((key, group) :: acc) (List.filter (fun x -> f x <> key) t)
  in
  aux [] lst
