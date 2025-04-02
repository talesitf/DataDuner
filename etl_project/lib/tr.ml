(** {1 Data Transformation Module}
    This module contains pure functions for transforming and aggregating data. *)

open Records

(** Filter orders by status and origin
    @param orders List of orders to filter
    @param status Status to filter by
    @param origin Origin to filter by
    @return Filtered list of orders *)
let filter_by_status (orders : order list) (status : string) (origin : origin) :
    order list =
  orders
  |> List.filter (fun (order : Records.order) -> order.status = status)
  |> List.filter (fun (order : Records.order) -> order.origin = origin)

(** Create a joined record from an order and an item
    @param order Order record
    @param item Item record
    @return Joined record *)
let create_joined_record (order : Records.order) (item : Records.item) =
  {
    id = order.id;
    client_id = order.client_id;
    order_date = order.order_date;
    status = order.status;
    origin = order.origin;
    product_id = item.product_id;
    toi_price = item.toi_price;
    toi_tax = item.toi_tax;
  }

(** Perform inner join on orders and items
    @param orders List of orders
    @param items List of items
    @return List of joined records *)
let inner_join (orders : Records.order list) (items : Records.item list) :
    joined list =
    let match_and_join (order : Records.order) =
      items
      |> List.filter_map (fun (item: Records.item) ->
            if order.id = item.order_id then
              Some (create_joined_record order item)
            else None)
    in
    List.concat_map match_and_join orders

module IntMap = Map.Make (Int)

(** Group records by a key function
    @param key_fn Function to extract key from record
    @param records List of records to group
    @return Map from keys to lists of records *)
let group_by (key_fn : joined -> int) (records : joined list) : joined list IntMap.t =
  List.fold_left
    (fun map record ->
      let key = key_fn record in
      IntMap.update key
        (function
          | None ->
              Some [record]
          | Some existing ->
              Some (record :: existing))
        map)
    IntMap.empty records

(** Convert grouped records to list of pairs
    @param key_fn Function to extract key from record
    @param records List of records to group
    @return List of (key, records) pairs *)
let group_by_to_list (key_fn : joined -> int) (records : joined list) :
    (int * joined list) list =
  group_by key_fn records |> IntMap.bindings

(** Calculate totals from a list of records
    @param records List of records
    @return Order total record *)
let calculate_totals (records : joined list) : order_total =
  List.fold_left
    (fun acc (record:joined) ->
      {
        order_id = record.id;
        total_amount = acc.total_amount +. record.toi_price;
        total_tax = acc.total_tax +. record.toi_tax;
      })
    { order_id = 0; total_amount = 0.0; total_tax = 0.0 } records

(** Calculate means from a list of records
    @param records List of records
    @return Order total record with mean values *)
let calculate_means (records : joined list) : order_total =
  let totals = calculate_totals records in
  let count = List.length records in
  {
    order_id = totals.order_id;
    total_amount = totals.total_amount /. float_of_int count;
    total_tax = totals.total_tax /. float_of_int count;
  }

(** Extract year-month key from record
    @param record Joined record
    @return Integer in format YYYYMM *)
let month_year_key (record : joined) : int =
  let date_str = record.order_date in
  (* Date format: YYYY-MM-DDThh:mm:ss *)
  let year = int_of_string (String.sub date_str 0 4) in
  let month = int_of_string (String.sub date_str 5 2) in
  (year * 100) + month  (* Creates YYYYMM as integer *)

(** Group records by key function and calculate totals for each group
    @param key_fn Function to extract key from record
    @param records List of records
    @return List of (key, totals) pairs *)
let group_by_to_order_totals (key_fn : joined -> int) (records : joined list) :
    (int * order_total) list =
  group_by_to_list key_fn records
  |> List.map (fun (key, records) -> (key, calculate_totals records))

(** Group records by key function and calculate means for each group
    @param key_fn Function to extract key from record
    @param records List of records
    @return List of (key, means) pairs *)
let group_by_to_means (key_fn : joined -> int) (records : joined list) :
    (int * order_total) list =
  group_by_to_list key_fn records
  |> List.map (fun (key, records) -> (key, calculate_means records))

