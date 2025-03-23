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