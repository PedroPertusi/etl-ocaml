(* filter.ml *)
open Records


(** [filter_joined_records records filter_status filter_origin] filters a list of joined order-item records
    based on optional status and origin parameters.

    @param records A list of joined order and item records to be filtered.
    @param filter_status An optional status (e.g., "Complete", "Pending", "Cancelled") used to filter records. If [None], no filtering by status is applied.
    @param filter_origin An optional origin (e.g., "P", "O") used to filter records. If [None], no filtering by origin is applied.
    @return A list of records that match the provided status and origin filters. *)
let filter_joined_records (records : order_join_items list) (filter_status : string option) (filter_origin : string option) : order_join_items list =
  List.filter (fun r ->
    (match filter_status with
     | Some s -> r.status = s
     | None -> true)
    &&
    (match filter_origin with
     | Some o -> r.origin = o
     | None -> true)
  ) records