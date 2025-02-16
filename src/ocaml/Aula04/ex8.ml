(* Fazer uma função que altera todas as ocorrências de uma lista. *)

let rec replace_all list old new_element = 
  match list with
  | [] -> []
  | h :: t -> 
    if h = old then new_element :: (replace_all t old new_element)
    else h :: (replace_all t old new_element)