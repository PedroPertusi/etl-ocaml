(* transformer.ml *)
open Records
open Helper

let rec inner_join_orders (orders : order list) (order_items : order_item list) : order_join_items list =
  match order_items with
  | [] -> []
  | order_item :: t ->
      match List.find_opt (fun (order : order) -> order.id = order_item.order_id) orders with
      | Some order ->
          {
            order_id   = order.id;
            quantity   = order_item.quantity;
            price      = order_item.price;
            tax        = order_item.tax;
            order_date = order.order_date;
            status     = order.status;
            origin     = order.origin;
          }
          :: inner_join_orders orders t
      | None -> inner_join_orders orders t


let aggregate_order_items (items : order_join_items list) : order_summary list =
  let grouped =
    List.fold_left (fun acc item ->
      let amt = float_of_int item.quantity *. item.price in
      let tax = item.tax *. amt in
      let key = item.order_id in
      (* assoc_opt *)
      match List.assoc_opt key acc with
      | Some (sum_amt, sum_tax) ->
          (key, (sum_amt +. amt, sum_tax +. tax)) :: List.remove_assoc key acc
      | None ->
          (key, (amt, tax)) :: acc
    ) [] items
  in
  List.map (fun (order_id, (total_amount, total_taxes)) ->
    { order_id; total_amount; total_taxes }
  ) grouped


let mean_order_items (items : order_join_items list) : order_mean_summary list =
  let group_orders_by_month_year orders = 
    list_group_by (fun order -> extract_month_year order.order_date) orders
  in
  let grouped = group_orders_by_month_year items in
  List.map (fun (month_year, orders) ->
    let total_amount, total_taxes, total_orders =
      List.fold_left (fun (acc_amt, acc_tax, count) order ->
        let current_amt = float_of_int order.quantity *. order.price in
        let current_tax = order.tax *. current_amt in
        (acc_amt +. current_amt, acc_tax +. current_tax, count + 1)
      ) (0., 0., 0) orders
    in
    let mean_amount = total_amount /. float_of_int total_orders in
    let mean_taxes = total_taxes /. float_of_int total_orders in
    let year, month = split_date month_year in
    {mean_amount; mean_taxes; month; year }
  ) grouped