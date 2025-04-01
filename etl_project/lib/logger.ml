open Records

let log_info message = Printf.printf "%s\n" message
let log_error message = Printf.eprintf "%s\n" message

let log_fetch_result url = function
  | Ok _ -> log_info (Printf.sprintf "%s: succeed" url)
  | Error str -> 
      log_error (Printf.sprintf "%s: fail" url);
      log_error (Printf.sprintf "Error: %s" str)

let log_order_totals (totals: (int * output) list) =
  log_info "\n===== Order Totals =====";
  List.iter (fun (key, j) ->
    log_info (Printf.sprintf "Order ID: %d" key);
    log_info (Printf.sprintf "  Price: %.2f, Tax: %.2f" j.total_amount j.total_tax)
  ) totals

let log_monthly_means (means: (int * output) list) =
  log_info "\n===== Monthly Means =====";
  List.iter (fun (key, mean) ->
    let year = key / 100 in
    let month = key mod 100 in
    log_info (Printf.sprintf "Period: %04d-%02d" year month);
    log_info (Printf.sprintf "  Avg Price: %.2f, Avg Tax: %.2f" 
      mean.total_amount mean.total_tax)
  ) means

let log_db_success () = log_info "\nData successfully saved to etl_results.sqlite"
let log_db_error err = log_error (Printf.sprintf "Database error: %s" (Caqti_error.show err))