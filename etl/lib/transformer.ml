open Records

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
