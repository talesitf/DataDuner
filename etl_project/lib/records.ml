type origin = Physical | Online

type order = { id : int; client_id: int; order_date: string; status: string; origin: origin;}

type item = {order_id : int; product_id: int; toi_price: float; toi_tax: float;}

type joined = {id : int; client_id: int; order_date: string; status: string; origin: origin; product_id: int; toi_price: float; toi_tax: float;}