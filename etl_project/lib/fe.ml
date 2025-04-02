let ( let* ) = Lwt.bind

let http_get url =
  let* (resp, body) =
    Cohttp_lwt_unix.Client.get (Uri.of_string url)
  in
  let code = resp
             |> Cohttp.Response.status
             |> Cohttp.Code.code_of_status in
  if Cohttp.Code.is_success code
  then
    let* b = Cohttp_lwt.Body.to_string body in
    Lwt.return (Ok b)
  else
    Lwt.return (Error (
      Cohttp.Code.reason_phrase_of_code code
    ))

(* Function to parse CSV data using the Csv library *)
let parse_csv csv_str =
  csv_str
  |> Csv.of_string ~has_header:true
  |> Csv.Rows.input_all

(* Function to fetch and parse CSV data *)
let fetch_csv_data url =
  let* result = http_get url in
  match result with
  | Error str as err ->
     Logger.log_fetch_result url err;
     Lwt.return (Error str)
  | Ok csv_data as ok ->
     Logger.log_fetch_result url ok;
     let parsed_data = parse_csv csv_data in
     Lwt.return (Ok parsed_data)


let fetch_orders path =
  let* fetched_data = fetch_csv_data path in
  match fetched_data with
  | Error str ->
      Logger.log_error (Printf.sprintf "Failed to process orders from %s" path);
      Lwt.return (Error str)
  | Ok fetched_data ->
      let result = Ok (fetched_data |> List.map Ex.parse_row_order) in
      Lwt.return result


let fetch_items path =
  let* fetched_data = fetch_csv_data path in
  match fetched_data with
  | Error str ->
      Logger.log_error (Printf.sprintf "Failed to process items from %s" path);
      Lwt.return (Error str)
  | Ok fetched_data ->
      let result = Ok (fetched_data |> List.map Ex.parse_row_item) in
      Lwt.return result

