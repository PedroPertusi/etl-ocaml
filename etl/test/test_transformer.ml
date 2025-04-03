(* test/test_transformer.ml *)
open OUnit2
open Etl.Records
open Etl.Transformer

(* Sample orders *)
let order1 : order = { id = 1; client_id = 100; order_date = "2025-03-20"; status = "Complete"; origin = "O" }
let order2 : order = { id = 2; client_id = 101; order_date = "2025-03-21"; status = "Pending"; origin = "P" }
let order3 : order = { id = 3; client_id = 102; order_date = "2025-04-01"; status = "Complete"; origin = "O" }

(* Sample order items *)
let order_item1 : order_item = { order_id = 1; product_id = 200; quantity = 2; price = 10.0; tax = 0.1 }   (* revenue = 20, tax = 2 *)
let order_item2 : order_item = { order_id = 1; product_id = 201; quantity = 3; price = 5.0; tax = 0.2 }    (* revenue = 15, tax = 3 *)
let order_item3 : order_item = { order_id = 2; product_id = 202; quantity = 1; price = 30.0; tax = 0.15 }  (* revenue = 30, tax = 4.5 *)
let order_item4 : order_item = { order_id = 3; product_id = 203; quantity = 2; price = 25.0; tax = 0.1 }   (* revenue = 50, tax = 5 *)

(* --- Test inner_join_orders --- *)
let test_inner_join_orders _ =
  let orders = [order1; order2; order3] in
  let order_items = [order_item1; order_item2; order_item3; order_item4] in
  let result = inner_join_orders orders order_items in
  let expected = [
    { order_id = 1; quantity = 2; price = 10.0; tax = 0.1; order_date = "2025-03-20"; status = "Complete"; origin = "O" };
    { order_id = 1; quantity = 3; price = 5.0; tax = 0.2; order_date = "2025-03-20"; status = "Complete"; origin = "O" };
    { order_id = 2; quantity = 1; price = 30.0; tax = 0.15; order_date = "2025-03-21"; status = "Pending"; origin = "P" };
    { order_id = 3; quantity = 2; price = 25.0; tax = 0.1; order_date = "2025-04-01"; status = "Complete"; origin = "O" }
  ] in
  (* We assume the order of the joined records is the same as order_items *)
  assert_equal expected result
    ~printer:(fun lst -> string_of_int (List.length lst))

(* --- Test aggregate_order_items --- *)
let test_aggregate_order_items _ =
  (* Using the same joined records as above *)
  let joined = [
    { order_id = 1; quantity = 2; price = 10.0; tax = 0.1; order_date = "2025-03-20"; status = "Complete"; origin = "O" };
    { order_id = 1; quantity = 3; price = 5.0; tax = 0.2; order_date = "2025-03-20"; status = "Complete"; origin = "O" };
    { order_id = 2; quantity = 1; price = 30.0; tax = 0.15; order_date = "2025-03-21"; status = "Pending"; origin = "P" };
    { order_id = 3; quantity = 2; price = 25.0; tax = 0.1; order_date = "2025-04-01"; status = "Complete"; origin = "O" }
  ] in
  (* Expected calculations:
     For order 1:
       revenue1 = 2 * 10.0 = 20, tax1 = 0.1 * 20 = 2.
       revenue2 = 3 * 5.0 = 15, tax2 = 0.2 * 15 = 3.
       Total: amount = 20 + 15 = 35, taxes = 2 + 3 = 5.
     For order 2:
       revenue = 1 * 30.0 = 30, tax = 0.15 * 30 = 4.5.
     For order 3:
       revenue = 2 * 25.0 = 50, tax = 0.1 * 50 = 5.
  *)
  let expected = [
    { order_id = 1; total_amount = 35.0; total_taxes = 5.0 };
    { order_id = 2; total_amount = 30.0; total_taxes = 4.5 };
    { order_id = 3; total_amount = 50.0; total_taxes = 5.0 }
  ] in
  (* Sort the summaries by order_id to compare in a deterministic order *)
  let sort_summary summaries =
    List.sort (fun a b -> compare a.order_id b.order_id) summaries
  in
  let cmp_summary a b =
    a.order_id = b.order_id &&
    abs_float (a.total_amount -. b.total_amount) < 0.0001 &&
    abs_float (a.total_taxes -. b.total_taxes) < 0.0001
  in
  let expected_sorted = sort_summary expected in
  let result_sorted = sort_summary (aggregate_order_items joined) in
  assert_equal ~cmp:(fun a b -> List.for_all2 cmp_summary a b)
    ~printer:(fun summaries ->
      String.concat ", " (List.map (fun s ->
        Printf.sprintf "{ order_id = %d; total_amount = %.2f; total_taxes = %.2f }"
          s.order_id s.total_amount s.total_taxes
      ) summaries))
    expected_sorted result_sorted

(* --- Test mean_order_items --- *)
let test_mean_order_items _ =
  let joined = [
    { order_id = 1; quantity = 2; price = 10.0; tax = 0.1; order_date = "2025-03-20"; status = "Complete"; origin = "O" };
    { order_id = 1; quantity = 3; price = 5.0; tax = 0.2; order_date = "2025-03-20"; status = "Complete"; origin = "O" };
    { order_id = 2; quantity = 1; price = 30.0; tax = 0.15; order_date = "2025-03-21"; status = "Pending"; origin = "P" };
    { order_id = 3; quantity = 2; price = 25.0; tax = 0.1; order_date = "2025-04-01"; status = "Complete"; origin = "O" }
  ] in
  let results = mean_order_items joined in
  (* For March 2025: records with order_date "2025-03-20" and "2025-03-21" (both extract to "2025-03")
     Record 1: revenue = 2*10.0 = 20, tax = 0.1*20 = 2.
     Record 2: revenue = 3*5.0 = 15, tax = 0.2*15 = 3.
     Record 3: revenue = 1*30.0 = 30, tax = 0.15*30 = 4.5.
     Total revenue = 20+15+30 = 65, total tax = 2+3+4.5 = 9.5, count = 3.
     Mean for March = (65/3, 9.5/3)
     
     For April 2025: record with order_date "2025-04-01"
     Revenue = 2*25.0 = 50, tax = 0.1*50 = 5.
  *)
  let expected_march = { mean_amount = 65.0 /. 3.0; mean_taxes = 9.5 /. 3.0; month = "03"; year = "2025" } in
  let expected_april = { mean_amount = 50.0; mean_taxes = 5.0; month = "04"; year = "2025" } in
  let find_summary summaries year month =
    List.find (fun s -> s.year = year && s.month = month) summaries
  in
  let summary_march = find_summary results "2025" "03" in
  let summary_april = find_summary results "2025" "04" in
  let cmp_float a b = abs_float (a -. b) < 0.0001 in
  assert_bool "March mean_amount" (cmp_float summary_march.mean_amount expected_march.mean_amount);
  assert_bool "March mean_taxes" (cmp_float summary_march.mean_taxes expected_march.mean_taxes);
  assert_bool "April mean_amount" (cmp_float summary_april.mean_amount expected_april.mean_amount);
  assert_bool "April mean_taxes" (cmp_float summary_april.mean_taxes expected_april.mean_taxes)

let suite =
  "Transformer Tests" >::: [
    "inner_join_orders" >:: test_inner_join_orders;
    "aggregate_order_items" >:: test_aggregate_order_items;
    "mean_order_items" >:: test_mean_order_items;
  ]

let () =
  run_test_tt_main suite
