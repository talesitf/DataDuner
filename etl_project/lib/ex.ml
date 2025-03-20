let ( let* ) = Result.bind

open Records

let parse_origin = function
  | "O" -> Ok Online
  | "P" -> Ok Physical
  | _ -> Error `Unknown_origin

let parse_int raw_id =
  raw_id |> int_of_string_opt |> Option.to_result ~none:`Invalid_id

let parse_str = function "" -> Error `Missing_status | s -> Ok s

let parse_float raw_float =
  raw_float |> float_of_string_opt |> Option.to_result ~none:`Invalid_number

let extract_field row field_name parser = Csv.Row.find row field_name |> parser

let extract_float row field_name = extract_field row field_name parse_float
let extract_int row field_name = extract_field row field_name parse_int
let extract_str row field_name = extract_field row field_name parse_str

let parse_row_order row =
  let* id = extract_int row "id" in
  let* client_id = extract_int row "client_id" in
  let* order_date = extract_str row "order_date" in
  let* status = extract_str row "status" in
  let* origin = extract_field row "origin" parse_origin in
  Ok { id; client_id; order_date; status; origin }

let parse_row_item row =
  let* order_id = extract_int row "order_id" in
  let* product_id = extract_int row "product_id" in
  let* quantity = extract_int row "quantity" in
  let* price = extract_float row "price" in
  let* tax = extract_float row "tax" in
  let toi_price = float_of_int quantity *. price in
  let toi_tax = toi_price *. tax in
  Ok { order_id; product_id; toi_price; toi_tax }
