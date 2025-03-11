open Records

let inner_join (orders : order list) (items : item list) : joined list =
  List.concat_map (fun (order : Records.order) ->
    List.filter_map (fun (item : Records.item) ->
      if order.id = item.order_id then Some {
          id = order.id;
          client_id = order.client_id;
          order_date = order.order_date;
          status = order.status;
          origin = order.origin;
          product_id = item.product_id;
          toi_price = item.toi_price;
          toi_tax = item.toi_tax;
        }
      else
        None
    ) items
  ) orders