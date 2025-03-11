let ( let* ) = Result.bind

open Records

let parse_origin = function
| "O" -> Ok Online
| "P" -> Ok Physical
| _ -> Error `Unknown_origin

let parse_int raw_id =
  raw_id
  |> int_of_string_opt
  |> Option.to_result ~none:`Invalid_id

let parse_str = function
  | "" -> Error `Missing_status
  | s -> Ok s

let parse_float raw_float =
  raw_float
  |> float_of_string_opt
  |> Option.to_result ~none:`Invalid_number

let parse_row_order row =
  let* id =
    Csv.Row.find row "id" |> parse_int
  in
  let* client_id =
    Csv.Row.find row "client_id" |> parse_int
  in
  let* order_date =
    Csv.Row.find row "order_date" |> parse_str
  in
  let* status = 
    Csv.Row.find row "status" |> parse_str
  in
  let* origin = 
    Csv.Row.find row "origin" |> parse_origin
  in
  Ok { id; client_id; order_date; status; origin}

let parse_row_item row =
  let* order_id =
    Csv.Row.find row "order_id" |> parse_int
  in
  let* product_id =
    Csv.Row.find row "product_id" |> parse_int
  in
  let* quantity =
    Csv.Row.find row "quantity" |> parse_int
  in
  let* price = 
    Csv.Row.find row "price" |> parse_float
  in
  let* tax = 
    Csv.Row.find row "tax" |> parse_float
  in
  let toi_price = 
    float_of_int quantity *. price
  in
  let toi_tax =
    toi_price *. tax
  in
  Ok { order_id; product_id; toi_price; toi_tax}