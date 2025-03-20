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
  | Error str ->
     Printf.printf "%s: fail\n" url;
     Printf.printf "Error: %s\n" str;
     Lwt.return (Error str)
  | Ok csv_data ->
     Printf.printf "%s: succeed\n" url;
     let parsed_data = parse_csv csv_data in
     Lwt.return (Ok parsed_data)