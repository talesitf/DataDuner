(** {1 Records Module}
    This module defines the core data structures used throughout the application. *)

(** Represents the origin of an order, either Physical or Online *)
type origin = Physical | Online

(** Represents an order record from the source data *)
type order = {
  id : int;        (** Unique identifier for the order *)
  client_id : int; (** Client identifier *)
  order_date : string; (** Date of the order in ISO format *)
  status : string; (** Status of the order (e.g., "Pending", "Complete", "Cancelled") *)
  origin : origin; (** Origin of the order (Physical or Online) *)
}

(** Represents an order item from the source data *)
type item = {
  order_id : int;    (** Order identifier this item belongs to *)
  product_id : int;  (** Product identifier *)
  toi_price : float; (** Total price for this item *)
  toi_tax : float;   (** Total tax for this item *)
}

(** Represents a joined record of order and item *)
type joined = {
  id : int;           (** Order identifier *)
  client_id : int;    (** Client identifier *)
  order_date : string; (** Date of the order in ISO format *)
  status : string;    (** Status of the order *)
  origin : origin;    (** Origin of the order *)
  product_id : int;   (** Product identifier *)
  toi_price : float;  (** Total price for this item *)
  toi_tax : float;    (** Total tax for this item *)
}

(** Represents an output record with aggregated values *)
type output = { 
  id : int;            (** Order identifier *)
  total_amount : float; (** Total amount *)
  total_tax : float;   (** Total tax *)
}

(** Database record type for order totals *)
type order_total = {
  order_id : int;       (** Order identifier *)
  total_amount : float;  (** Total amount for the order *)
  total_tax : float;    (** Total tax for the order *)
}

(** Database record type for monthly means *)
type monthly_mean = {
  year_month : int;  (** Year and month combined as an integer (YYYYMM) *)
  year : int;       (** Year component *)
  month : int;      (** Month component *)
  avg_amount : float; (** Average amount for the period *)
  avg_tax : float;   (** Average tax for the period *)
}
