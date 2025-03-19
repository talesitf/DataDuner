open Etl_project
open Records

(* Group by function using Map *)
module IntMap = Map.Make (Int)

let order_path = "data/order.csv"
let item_path = "data/order_item.csv"

let parse_orders path =
  path |> Csv.Rows.load ~has_header:true |> List.map Ex.parse_row_order

let parse_items path =
  path |> Csv.Rows.load ~has_header:true |> List.map Ex.parse_row_item

(* Helper function to extract Ok values from a list of Results *)
let extract_ok_values results =
  List.fold_left
    (fun acc result ->
      match result with Ok value -> value :: acc | Error _ -> acc)
    [] results
  |> List.rev

let () =
  let orders = order_path |> parse_orders |> extract_ok_values in

  let items = item_path |> parse_items |> extract_ok_values in

  let status = Sys.argv.(1) in

  let origin =
    match Sys.argv.(2) with
    | "Physical" -> Physical
    | "Online" -> Online
    | _ -> failwith "Invalid origin"
  in

  let filtered_orders = Tr.filter_by_status orders status origin in

  let joined = Tr.inner_join filtered_orders items in

  let grouped_by_order_id = Tr.group_by_to_list (fun j -> j.id) joined in

  List.iter
    (fun (key, j) ->
      Printf.printf "Order ID: %d\n" key;
      Printf.printf "  Price: %.2f, Tax: %.2f\n" j.total_amount j.total_tax)
    grouped_by_order_id