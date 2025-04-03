(* test/test_parser.ml *)
open OUnit2
open Etl.Records
open Etl.Parser

(* Test for parse_order_row *)
let test_parse_order_row_valid _ =
  let input = ["1"; "100"; "2025-03-20T12:00:00"; "Complete"; "O"] in
  let expected : Etl.Records.order = {
    id = 1;
    client_id = 100;
    order_date = "2025-03-20";  (* Only the first 10 characters are taken *)
    status = "Complete";
    origin = "O";
  } in
  let result : Etl.Records.order = parse_order_row input in
  assert_equal expected result
    ~printer:(fun o ->
      Printf.sprintf "{ id = %d; client_id = %d; order_date = %s; status = %s; origin = %s }"
        o.id o.client_id o.order_date o.status o.origin)

(* Test for parse_order_item_row *)
let test_parse_order_item_row_valid _ =
  let input = ["1"; "200"; "2"; "15.5"; "0.1"] in
  let expected : Etl.Records.order_item = {
    order_id = 1;
    product_id = 200;
    quantity = 2;
    price = 15.5;
    tax = 0.1;
  } in
  let result : Etl.Records.order_item = parse_order_item_row input in
  assert_equal expected result
    ~printer:(fun (oi : Etl.Records.order_item) ->
      Printf.sprintf "{ order_id = %d; product_id = %d; quantity = %d; price = %.2f; tax = %.2f }"
        oi.order_id oi.product_id oi.quantity oi.price oi.tax)

(* Test for csv_skip_header_map using parse_order_row *)
let test_csv_skip_header_map _ =
  let csv = [
    ["id"; "client_id"; "order_date"; "status"; "origin"];  (* header row *)
    ["1"; "100"; "2025-03-20T12:00:00"; "Complete"; "O"];
    ["2"; "101"; "2025-03-21T14:00:00"; "Pending"; "P"]
  ] in
  let expected : Etl.Records.order list = [
    { id = 1; client_id = 100; order_date = "2025-03-20"; status = "Complete"; origin = "O" };
    { id = 2; client_id = 101; order_date = "2025-03-21"; status = "Pending"; origin = "P" }
  ] in
  let result = csv_skip_header_map parse_order_row csv in
  assert_equal expected result
    ~printer:(fun orders -> string_of_int (List.length orders))

(* Test for orders_of_csv *)
let test_orders_of_csv _ =
  let csv = [
    ["id"; "client_id"; "order_date"; "status"; "origin"];
    ["1"; "100"; "2025-03-20T12:00:00"; "Complete"; "O"];
    ["2"; "101"; "2025-03-21T14:00:00"; "Pending"; "P"]
  ] in
  let expected : Etl.Records.order list = [
    { id = 1; client_id = 100; order_date = "2025-03-20"; status = "Complete"; origin = "O" };
    { id = 2; client_id = 101; order_date = "2025-03-21"; status = "Pending"; origin = "P" }
  ] in
  let result = orders_of_csv csv in
  assert_equal expected result
    ~printer:(fun orders -> string_of_int (List.length orders))

(* Test for order_items_of_csv *)
let test_order_items_of_csv _ =
  let csv = [
    ["order_id"; "product_id"; "quantity"; "price"; "tax"];  (* header row *)
    ["1"; "200"; "2"; "15.5"; "0.1"];
    ["2"; "201"; "3"; "20.0"; "0.15"]
  ] in
  let expected : Etl.Records.order_item list = [
    { order_id = 1; product_id = 200; quantity = 2; price = 15.5; tax = 0.1 };
    { order_id = 2; product_id = 201; quantity = 3; price = 20.0; tax = 0.15 }
  ] in
  let result = order_items_of_csv csv in
  assert_equal expected result
    ~printer:(fun items -> string_of_int (List.length items))

let suite =
  "Parser Tests" >::: [
    "parse_order_row valid" >:: test_parse_order_row_valid;
    "parse_order_item_row valid" >:: test_parse_order_item_row_valid;
    "csv_skip_header_map" >:: test_csv_skip_header_map;
    "orders_of_csv" >:: test_orders_of_csv;
    "order_items_of_csv" >:: test_order_items_of_csv;
  ]

let () =
  run_test_tt_main suite
