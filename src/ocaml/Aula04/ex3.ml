(* Faça uma função que retorna a quantidade de elementos em uma lista. Não usar built-in function List.length. *)

let rec count_elements list = 
  match list with
  | [] -> 0
  | _ :: t -> 1 + count_elements t

(* com tail call optmization *)

let count_elements list = 
  let rec aux list acc = 
    match list with
    | [] -> acc
    | _ :: t -> aux t (acc + 1)
  in aux list 0