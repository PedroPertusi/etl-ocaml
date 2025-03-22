(* Define the order_item type *)

type order = {
  id : int;
  client_id : int;
  order_date : string;
  status : string;
  origin : string;
}

type order_item = {
  order_id : int;
  product_id : int;
  quantity : int;
  price : float;
  tax : float;
}

(* type order_join_order_item = {
  order_id : int;
  (* product_id : int; *)
  quantity : int;
  price : float;
  tax : float;
  (* client_id : int; *)
  order_date : Ptime.t;
  status : string;
  origin : string;
} *)