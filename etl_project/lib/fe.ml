(** {1 Frontend Module}
    This module handles data fetching and external API interactions. *)

let ( let* ) = Lwt.bind

(** Fetch data from a URL using HTTP GET
    @param url URL to fetch from
    @return Result containing the response body or error message *)
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

(** Parse CSV string to list of rows
    @param csv_str CSV string to parse
    @return List of CSV rows *)
let parse_csv csv_str =
  csv_str
  |> Csv.of_string ~has_header:true
  |> Csv.Rows.input_all

(** Fetch and parse CSV data from a URL
    @param url URL to fetch from
    @return Result containing parsed CSV data or error message *)
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

(** Fetch and parse orders from a URL
    @param path URL to fetch from
    @return Result containing list of orders or error message *)
let fetch_orders path =
  let* fetched_data = fetch_csv_data path in
  match fetched_data with
  | Error str ->
      Logger.log_error (Printf.sprintf "Failed to process orders from %s" path);
      Lwt.return (Error str)
  | Ok fetched_data ->
      let result = Ok (fetched_data |> List.map Ex.parse_row_order) in
      Lwt.return result

(** Fetch and parse items from a URL
    @param path URL to fetch from
    @return Result containing list of items or error message *)
let fetch_items path =
  let* fetched_data = fetch_csv_data path in
  match fetched_data with
  | Error str ->
      Logger.log_error (Printf.sprintf "Failed to process items from %s" path);
      Lwt.return (Error str)
  | Ok fetched_data ->
      let result = Ok (fetched_data |> List.map Ex.parse_row_item) in
      Lwt.return result

