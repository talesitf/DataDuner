(** {1 Logger Module}
    This module provides logging functionality. *)

open Records

(** Log informational message to stdout 
    @param message Message to log *)
let log_info message = Printf.printf "%s\n" message

(** Log error message to stderr
    @param message Message to log *)
let log_error message = Printf.eprintf "%s\n" message

(** Log fetch result
    @param url URL that was fetched
    @param result Result of fetch operation *)
let log_fetch_result url = function
  | Ok _ -> log_info (Printf.sprintf "%s: succeed" url)
  | Error str -> 
      log_error (Printf.sprintf "%s: fail" url);
      log_error (Printf.sprintf "Error: %s" str)

(** Log order totals
    @param totals List of order totals *)
let log_order_totals (totals: (int * order_total) list) =
  log_info "\n===== Order Totals =====";
  List.iter (fun (key, j) ->
    log_info (Printf.sprintf "Order ID: %d" key);
    log_info (Printf.sprintf "  Price: %.2f, Tax: %.2f" j.total_amount j.total_tax)
  ) totals

(** Log monthly means
    @param means List of monthly means *)
let log_monthly_means (means: (int * order_total) list) =
  log_info "\n===== Monthly Means =====";
  List.iter (fun (key, mean) ->
    let year = key / 100 in
    let month = key mod 100 in
    log_info (Printf.sprintf "Period: %04d-%02d" year month);
    log_info (Printf.sprintf "  Avg Price: %.2f, Avg Tax: %.2f" 
      mean.total_amount mean.total_tax)
  ) means

(** Log database success message *)
let log_db_success () = log_info "\nData successfully saved to etl_results.sqlite"

(** Log database error message
    @param err Database error *)
let log_db_error err = log_error (Printf.sprintf "Database error: %s" (Caqti_error.show err))