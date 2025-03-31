(* records.ml *)

(** Represents a customer order with client ID, date, status, and origin. *)
type order = {
  id : int;              (** Unique identifier for the order. *)
  client_id : int;       (** Identifier of the client who placed the order. *)
  order_date : string;   (** Date the order was placed, in "YYYY-MM-DDTHH:MM:SS" format. *)
  status : string;       (** Status of the order (e.g., "Complete", "Pending", "Cancelled"). *)
  origin : string;       (** Origin of the order ("P" for physical, "O" for online). *)
}

(** Represents an item within an order. *)
type order_item = {
  order_id : int;        (** Identifier of the order to which the item belongs. *)
  product_id : int;      (** Identifier of the product. *)
  quantity : int;        (** Quantity of the product ordered. *)
  price : float;         (** Unit price at the time of purchase. *)
  tax : float;           (** Tax percentage applied to the item. *)
}

(** A combination of an order and its items, used after joining the two tables. *)
type order_join_items = {
  (* order *)
  order_date : string;   (** Date of the order. *)
  status : string;       (** Status of the order. *)
  origin : string;       (** Origin of the order. *)

  (* order_item *)
  order_id : int;        (** ID of the order. *)
  quantity : int;        (** Quantity of the item. *)
  price : float;         (** Price of the item. *)
  tax : float;           (** Tax percentage of the item. *)
}

(** Summarized information about an order, including total revenue and total tax. (Output 1) *)
type order_summary = {
  order_id : int;        (** ID of the order. *)
  total_amount : float;  (** Total amount (revenue) for the order. *)
  total_taxes : float;   (** Total taxes for the order. *)
}

(** Represents the mean revenue and tax values for a given month and year. (Output 2) *)
type order_mean_summary = {
  mean_amount : float;   (** Mean order amount (revenue) for the month. *)
  mean_taxes : float;    (** Mean taxes for the month. *)
  month : string;        (** Month of the summary (e.g., "03"). *)
  year : string;         (** Year of the summary (e.g., "2025"). *)
}