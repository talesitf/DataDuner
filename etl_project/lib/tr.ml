open Records

let filter_by_status (orders : order list) (status : string) (origin : origin) :
    order list =
  orders
  |> List.filter (fun (order : Records.order) -> order.status = status)
  |> List.filter (fun (order : Records.order) -> order.origin = origin)

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

let group_by_to_list (key_fn : joined -> int) (records : joined list) :
    (int * joined list) list =
  group_by key_fn records |> IntMap.bindings

let calculate_totals (records : joined list) : order_total =
  List.fold_left
    (fun acc (record:joined) ->
      {
        order_id = record.id;
        total_amount = acc.total_amount +. record.toi_price;
        total_tax = acc.total_tax +. record.toi_tax;
      })
    { order_id = 0; total_amount = 0.0; total_tax = 0.0 } records

let calculate_means (records : joined list) : order_total =
  let totals = calculate_totals records in
  let count = List.length records in
  {
    order_id = totals.order_id;
    total_amount = totals.total_amount /. float_of_int count;
    total_tax = totals.total_tax /. float_of_int count;
  }

let month_year_key (record : joined) : int =
  let date_str = record.order_date in
  (* Date format: YYYY-MM-DDThh:mm:ss *)
  let year = int_of_string (String.sub date_str 0 4) in
  let month = int_of_string (String.sub date_str 5 2) in
  (year * 100) + month  (* Creates YYYYMM as integer *)

let group_by_to_order_totals (key_fn : joined -> int) (records : joined list) :
    (int * order_total) list =
  group_by_to_list key_fn records
  |> List.map (fun (key, records) -> (key, calculate_totals records))

let group_by_to_means (key_fn : joined -> int) (records : joined list) :
    (int * order_total) list =
  group_by_to_list key_fn records
  |> List.map (fun (key, records) -> (key, calculate_means records))

