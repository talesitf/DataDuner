open Etl_project

let order_path = "data/order.csv"

let item_path = "data/order_item.csv"

let parse_orders path =
  path
  |> Csv.Rows.load ~has_header:true
  |> List.map Ex.parse_row_order

let parse_items path =
  path
  |> Csv.Rows.load ~has_header:true
  |> List.map Ex.parse_row_item

(* Helper function to extract Ok values from a list of Results *)
let extract_ok_values results =
  List.fold_left (fun acc result ->
    match result with
    | Ok value -> value :: acc
    | Error _ -> acc
  ) [] results
  |> List.rev

let () =
  let orders = parse_orders order_path |> extract_ok_values in
  let items = parse_items item_path |> extract_ok_values in

  let joined = Tr.inner_join orders items in

  (* Print the results *)
  List.iter (fun (j : Records.joined) ->
    Printf.printf "Order ID: %d, Client ID: %d, Product ID: %d, Price: %.2f, Tax: %.2f\n"
      j.id j.client_id j.product_id j.toi_price j.toi_tax
  ) joined

(* let () = 

  let orders = parse_orders order_path in
  let items = parse_items item_path in



  let joined = Tr.inner_join orders items in

  match parse_items item_path with
  | results ->
      List.iter (function
        | Ok (item : Ex.item) -> 
            Printf.printf "Parsed item:\n";
            Printf.printf "  Item ID: %d\n" item.order_id;
            Printf.printf "  Prouct ID: %d\n" item.product_id;

            Printf.printf "  Status: %f\n" item.price;
            Printf.printf "  Origin: %f\n" item.tax;
            Printf.printf "\n" (* Add a newline for separation *)
        | Error e -> 
            let error_msg = match e with
              | `Invalid_id -> "Invalid ID"
              | `Missing_status -> "Missing status"
              | `Unknown_origin -> "Unknown origin"
              | `Invalid_number -> "Invalid number"
            in
            Printf.eprintf "Error parsing item: %s\n" error_msg
      ) results

 *)
