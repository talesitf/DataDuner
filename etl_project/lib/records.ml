type origin = Physical | Online

type order = {
  id : int;
  client_id : int;
  order_date : string;
  status : string;
  origin : origin;
}

type item = {
  order_id : int;
  product_id : int;
  toi_price : float;
  toi_tax : float;
}

type joined = {
  id : int;
  client_id : int;
  order_date : string;
  status : string;
  origin : origin;
  product_id : int;
  toi_price : float;
  toi_tax : float;
}

type output = { id : int; total_amount : float; total_tax : float }

(* Database record types *)
type order_total = {
  order_id : int;
  total_amount : float;
  total_tax : float;
}

type monthly_mean = {
  year_month : int;
  year : int;
  month : int;
  avg_amount : float;
  avg_tax : float;
}
