open Etl_project
open Records

let ( let* ) = Lwt.bind

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

  let grouped_by_order_id = Tr.group_by_to_list (fun j -> j.id) joined in

  List.iter(fun (key, j) ->
        Printf.printf "Order ID: %d\n" key;
        Printf.printf "  Price: %.2f, Tax: %.2f\n" j.total_amount j.total_tax;)
    grouped_by_order_id;

  Lwt.return ()

  )

(* let () =
  let url = "https://raw.githubusercontent.com/talesitf/DataDuner/refs/heads/main/etl_project/data/order.csv" in (* Replace with your CSV URL *)
  Lwt_main.run (
    let* parsed_data = Fe.fetch_csv_data url in
    match parsed_data with
    | Ok parsed_data ->
       (* Print the parsed CSV data *)
       List.iter (
          fun row ->
            let id = Ex.extract_int row "id" in
            match id with
            | Ok id ->
                Printf.printf "ID: %d\n" id;
            | _ -> Printf.printf "ID not found\n"
       ) parsed_data;
       Lwt.return ()
    | Error err ->
       (* Print the error message *)
       Printf.eprintf "Failed to fetch or parse CSV data: %s\n" err;
       Lwt.return ()
  ) *)