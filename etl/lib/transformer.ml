(* transformer.ml *)
open Records
open Helper

(** [inner_join_orders orders order_items] performs an inner join between two lists:
    the [orders] and their associated [order_items].

    @param orders A list of order records.
    @param order_items A list of order item records.
    @return A list of combined [order_join_items] where each item is linked to its parent order.
    Orders without matching items are ignored. *)
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

(** [aggregate_order_items items] aggregates a list of joined order-item records
    to compute the total amount and total taxes per order.

    @param items A list of [order_join_items] to aggregate.
    @return A list of [order_summary] records, each containing the total amount and taxes for one order. *)
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

(** [mean_order_items items] calculates the mean amount and mean taxes
    for orders grouped by year and month.

    @param items A list of [order_join_items].
    @return A list of [order_mean_summary], each containing average values for a month/year group. *)
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