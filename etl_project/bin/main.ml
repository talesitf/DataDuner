open Etl_project
open Records

let ( let* ) = Lwt.bind
let ( let*? ) = Lwt_result.bind

(* Group by function using Map *)
module IntMap = Map.Make (Int)

let order_path = "https://raw.githubusercontent.com/talesitf/DataDuner/refs/heads/main/etl_project/data/order.csv"
let item_path = "https://raw.githubusercontent.com/talesitf/DataDuner/refs/heads/main/etl_project/data/order_item.csv"

let parse_orders path =
  let* fetched_data = Fe.fetch_csv_data path in
  match fetched_data with
  | Error str ->
      Printf.printf "%s: fail\n" path;
      Printf.printf "Error: %s\n" str;
      Lwt.return []
  | Ok fetched_data ->
    Lwt.return (fetched_data |> List.map Ex.parse_row_order)

let parse_items path =
  let* fetched_data = Fe.fetch_csv_data path in
  match fetched_data with
  | Error str ->
      Printf.printf "%s: fail\n" path;
      Printf.printf "Error: %s\n" str;
      Lwt.return []
  | Ok fetched_data ->
    Lwt.return (fetched_data |> List.map Ex.parse_row_item)

(* Helper function to extract Ok values from a list of Results *)
let extract_ok_values results =
  List.fold_left
    (fun acc result ->
      match result with Ok value -> value :: acc | Error _ -> acc)
    [] results
  |> List.rev

let () =
  Lwt_main.run (
    let* orders_result = parse_orders order_path in
    let* items_result = parse_items item_path in
    
    let orders = extract_ok_values orders_result in
    let items = extract_ok_values items_result in

    let status = Sys.argv.(1) in

    let origin =
      match Sys.argv.(2) with
      | "Physical" -> Physical
      | "Online" -> Online
      | _ -> failwith "Invalid origin"
    in

    let filtered_orders = Tr.filter_by_status orders status origin in
    let joined = Tr.inner_join filtered_orders items in

    (* Group and calculate order totals *)
    Printf.printf "\n===== Order Totals =====\n";
    let grouped_by_order_id = Tr.group_by_to_outputs (fun j -> j.id) joined in
    let order_totals = List.map (fun (key, output) -> 
      {Sq.order_id = key; 
       total_amount = output.total_amount; 
       total_tax = output.total_tax}) grouped_by_order_id in
    
    List.iter(fun (key, j) ->
          Printf.printf "Order ID: %d\n" key;
          Printf.printf "  Price: %.2f, Tax: %.2f\n" j.total_amount j.total_tax;)
      grouped_by_order_id;

    (* Group and calculate monthly means *)
    Printf.printf "\n===== Monthly Means =====\n";
    let monthly_means = Tr.group_by_to_means Tr.month_year_key joined in
    let monthly_means_records = List.map (fun (key, mean) -> 
      let year = key / 100 in
      let month = key mod 100 in
      {Sq.year_month = key;
       year = year;
       month = month;
       avg_amount = mean.total_amount;
       avg_tax = mean.total_tax}) monthly_means in
    
    List.iter(fun (key, mean) ->
          let year = key / 100 in
          let month = key mod 100 in
          Printf.printf "Period: %04d-%02d\n" year month;
          Printf.printf "  Avg Price: %.2f, Avg Tax: %.2f\n" 
            mean.total_amount mean.total_tax;)
      monthly_means;

    (* Save data to database *)
    let* db_result = Caqti_lwt.with_connection 
      (Uri.of_string "sqlite3:etl_results.sqlite") 
      (fun connection ->
        let*? () = Sq.save_data order_totals monthly_means_records connection in
        Printf.printf "\nData successfully saved to etl_results.sqlite\n";
        
        (* Read and display the data we just saved *)
        let*? () = Sq.read_data connection in
        
        Lwt_result.return ()
      ) in
    
    match db_result with
    | Error err -> 
        Printf.eprintf "Database error: %s\n" (Caqti_error.show err);
        Lwt.return ()
    | Ok () ->
        Lwt.return ()
  )