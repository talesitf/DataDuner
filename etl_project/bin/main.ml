(** {1 Main Module}
    The main entry point for the ETL application. *)

open Etl_project
open Records

let ( let* ) = Lwt.bind
let ( let*? ) = Lwt_result.bind

(* Group by function using Map *)
module IntMap = Map.Make (Int)

(** URL for order data *)
let order_path = "https://raw.githubusercontent.com/talesitf/DataDuner/refs/heads/main/etl_project/data/order.csv"

(** URL for item data *)
let item_path = "https://raw.githubusercontent.com/talesitf/DataDuner/refs/heads/main/etl_project/data/order_item.csv"

(** Extract Ok values from a list of Results, discarding Error values
    @param results List of Result values
    @return List of unwrapped Ok values *)
let extract_ok_values results =
  List.fold_left
    (fun acc result ->
      match result with Ok value -> value :: acc | Error _ -> acc)
    [] results
  |> List.rev

(** Prepare order totals records from grouped data
    @param grouped_by_order_id List of (order_id, output) pairs
    @return List of order_total records *)
let prepare_order_totals grouped_by_order_id =
  List.map (fun (key, output) -> 
    {Records.order_id = key; 
     total_amount = output.total_amount; 
     total_tax = output.total_tax}) 
  grouped_by_order_id

(** Prepare monthly means records from grouped data
    @param monthly_means List of (year_month, output) pairs
    @return List of monthly_mean records *)
let prepare_monthly_means monthly_means =
  List.map (fun (key, mean) -> 
    let year = key / 100 in
    let month = key mod 100 in
    {Records.year_month = key;
     year = year;
     month = month;
     avg_amount = mean.total_amount;
     avg_tax = mean.total_tax}) 
  monthly_means

(** Process data through the ETL pipeline
    @param orders List of orders
    @param items List of items
    @param status Status to filter by
    @param origin Origin to filter by
    @return Tuple of (grouped_by_order_id, monthly_means) *)
let process_data orders items status origin =
  let filtered_orders = Tr.filter_by_status orders status origin in
  let joined = Tr.inner_join filtered_orders items in
  let grouped_by_order_id = Tr.group_by_to_order_totals (fun j -> j.id) joined in
  let monthly_means = Tr.group_by_to_means Tr.month_year_key joined in
  (grouped_by_order_id, monthly_means)

(** Main entry point *)
let () =
  Lwt_main.run (
    let* orders_result = Fe.fetch_orders order_path in
    let* items_result = Fe.fetch_items item_path in
    
    let orders = extract_ok_values orders_result in
    let items = extract_ok_values items_result in

    let status = Sys.argv.(1) in
    let origin =
      match Sys.argv.(2) with
      | "Physical" -> Physical
      | "Online" -> Online
      | _ -> failwith "Invalid origin"
    in

    (* Pure data transformation *)
    let (grouped_by_order_id, monthly_means) = process_data orders items status origin in


    (* Logging - impure but isolated in Logger module *)
    Logger.log_order_totals grouped_by_order_id;
    Logger.log_monthly_means monthly_means;
    
    (* Database operations - impure but isolated in Sq module *)
    let order_totals = prepare_order_totals grouped_by_order_id in
    let monthly_means_records = prepare_monthly_means monthly_means in

    let* _ = Sq.with_db (Uri.of_string "sqlite3:etl_results.sqlite") 
      (fun connection ->
        let*? () = Sq.save_data order_totals monthly_means_records connection in
        let*? () = Sq.read_data connection in
        Lwt_result.return ()
      ) in
    Lwt.return ()
  )