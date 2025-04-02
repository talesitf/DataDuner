open Records

let ( let* ) = Lwt.bind
let ( let*? ) = Lwt_result.bind

(* The helper function `iter_queries` sequentially schedules a list of queries.
   Each query is a function that takes the
   connection handle of the database as an argument. *)
let iter_queries queries connection =
  List.fold_left
    (fun a f ->
      Lwt_result.bind a (fun () -> f connection))
    (Lwt.return (Ok ()))
    queries

(* Table creation for order totals *)
let create_order_totals_table =
  [%rapper
    execute {sql| CREATE TABLE IF NOT EXISTS order_totals (
              order_id INTEGER PRIMARY KEY,
              total_amount REAL,
              total_tax REAL)
            |sql}
  ]

(* Table creation for monthly means *)
let create_monthly_means_table =
  [%rapper
    execute {sql| CREATE TABLE IF NOT EXISTS monthly_means (
              year_month INTEGER PRIMARY KEY,
              year INTEGER,
              month INTEGER,
              avg_amount REAL,
              avg_tax REAL)
            |sql}
  ]

(* Insert order total record *)
let insert_order_total =
  [%rapper
    execute
    {sql| INSERT INTO order_totals VALUES (
        %int{order_id},
        %float{total_amount},
        %float{total_tax}
    ) |sql}
    record_in
  ]

(* Insert monthly mean record *)
let insert_monthly_mean =
  [%rapper
    execute
    {sql| INSERT INTO monthly_means VALUES (
        %int{year_month},
        %int{year},
        %int{month},
        %float{avg_amount},
        %float{avg_tax}
    ) |sql}
    record_in
  ]

(* Read all order totals from database *)
let get_all_order_totals =
  [%rapper
    get_many
    {sql|SELECT
        @int{order_id},
        @float{total_amount},
        @float{total_tax}
      FROM order_totals
      ORDER BY order_id
    |sql}
    record_out
  ]

(* Read all monthly means from database *)
let get_all_monthly_means =
  [%rapper
    get_many
    {sql|SELECT
        @int{year_month},
        @int{year},
        @int{month},
        @float{avg_amount},
        @float{avg_tax}
      FROM monthly_means
      ORDER BY year_month
    |sql}
    record_out
  ]

(* Initialize database and save data *)
let save_data order_totals monthly_means connection =
  (* Create tables if they don't exist *)
  let*? () = create_order_totals_table () connection in
  let*? () = create_monthly_means_table () connection in
  
  (* Insert order totals *)
  let*? () =
    iter_queries
      (List.map insert_order_total order_totals)
      connection
  in
  
  (* Insert monthly means *)
  let*? () =
    iter_queries
      (List.map insert_monthly_mean monthly_means)
      connection
  in
  
  Lwt_result.return ()

(* Function to read and display all stored data *)
let read_data connection =
  (* Read order totals *)
  let*? order_totals = get_all_order_totals () connection in
  Logger.log_info "\n===== Stored Order Totals =====";
  List.iter (fun record ->
    Logger.log_info (Printf.sprintf "Order ID: %d" record.order_id);
    Logger.log_info (Printf.sprintf "  Total Amount: %.2f, Total Tax: %.2f" 
      record.total_amount record.total_tax)
  ) order_totals;
  
  (* Read monthly means *)
  let*? monthly_means = get_all_monthly_means () connection in
  Logger.log_info "\n===== Stored Monthly Means =====";
  List.iter (fun record ->
    Logger.log_info (Printf.sprintf "Period: %04d-%02d" record.year record.month);
    Logger.log_info (Printf.sprintf "  Avg Amount: %.2f, Avg Tax: %.2f" 
      record.avg_amount record.avg_tax)
  ) monthly_means;
  
  Lwt_result.return ()

let with_db uri f =
  let* result = Caqti_lwt.with_connection uri f in
  match result with
  | Error err -> 
      Logger.log_db_error err;
      Lwt.return (Error err)
  | Ok v -> 
      Logger.log_db_success ();
      Lwt.return (Ok v)