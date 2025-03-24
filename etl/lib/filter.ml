(* filter.ml *)
open Records

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