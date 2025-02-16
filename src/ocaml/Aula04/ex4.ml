(* Faça uma função que retorna o maior elemento de uma lista. *)

let rec max_element list = 
  match list with
  | [] -> failwith "empty list"
  | [x] -> x
  | h :: t -> if h > (max_element t) then h else (max_element t) ;;

(* Evitando a redundância da chamada de função: *)

let rec max_element list = 
  match list with
  | [] -> failwith "empty list"
  | [x] -> x
  | h :: t -> 
    let max_tail = max_element t in
    if h > max_tail then h else max_tail