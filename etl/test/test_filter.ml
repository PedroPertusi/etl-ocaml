(* test/test_filter.ml *)
open OUnit2
open Etl.Records
open Etl.Filter

(* Sample test records *)
let record1 : order_join_items = {
  order_date = "2025-03-20";
  status = "Complete";
  origin = "O";
  order_id = 1;
  quantity = 2;
  price = 10.0;
  tax = 0.1;
}

let record2 : order_join_items = {
  order_date = "2025-03-20";
  status = "Pending";
  origin = "P";
  order_id = 2;
  quantity = 3;
  price = 15.0;
  tax = 0.05;
}

let record3 : order_join_items = {
  order_date = "2025-03-20";
  status = "Complete";
  origin = "P";
  order_id = 3;
  quantity = 1;
  price = 20.0;
  tax = 0.2;
}

let records = [record1; record2; record3]

let test_no_filter _ =
  let result = filter_joined_records records None None in
  assert_equal records result ~printer:(fun lst -> string_of_int (List.length lst))

let test_filter_status _ =
  let result = filter_joined_records records (Some "Complete") None in
  let expected = [record1; record3] in
  assert_equal expected result ~printer:(fun lst -> string_of_int (List.length lst))

let test_filter_origin _ =
  let result = filter_joined_records records None (Some "P") in
  let expected = [record2; record3] in
  assert_equal expected result ~printer:(fun lst -> string_of_int (List.length lst))

let test_filter_status_origin _ =
  let result = filter_joined_records records (Some "Complete") (Some "P") in
  let expected = [record3] in
  assert_equal expected result ~printer:(fun lst -> string_of_int (List.length lst))

let test_empty_list _ =
  let result = filter_joined_records [] (Some "Complete") (Some "P") in
  assert_equal [] result ~printer:(fun lst -> string_of_int (List.length lst))

let suite =
  "Filter Tests" >::: [
    "No Filter" >:: test_no_filter;
    "Filter by Status" >:: test_filter_status;
    "Filter by Origin" >:: test_filter_origin;
    "Filter by Status and Origin" >:: test_filter_status_origin;
    "Empty List" >:: test_empty_list;
  ]

let () =
  run_test_tt_main suite
