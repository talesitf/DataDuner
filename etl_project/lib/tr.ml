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
    |> List.filter_map (fun item ->
           if order.id = item.order_id then
             Some (create_joined_record order item)
           else None)
  in
  List.concat_map match_and_join orders

module IntMap = Map.Make (Int)

let group_by (key_fn : joined -> int) (records : joined list) : output IntMap.t
    =
  List.fold_left
    (fun map record ->
      let key = key_fn record in
      IntMap.update key
        (function
          | None ->
              Some
                {
                  id = record.id;
                  total_amount = record.toi_price;
                  total_tax = record.toi_tax;
                }
          | Some outer ->
              Some
                {
                  id = record.id;
                  total_amount = record.toi_price +. outer.total_amount;
                  total_tax = record.toi_tax +. outer.total_tax;
                })
        map)
    IntMap.empty records

let group_by_to_list (key_fn : joined -> int) (records : joined list) :
    (int * output) list =
  group_by key_fn records |> IntMap.bindings
