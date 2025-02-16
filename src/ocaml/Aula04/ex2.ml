(* Faça uma função que recebe uma tupla ponto (x,y) e retorna um texto indicando se x e y são iguais, x é maior ou y é maior. *)

let compare_points (x, y) = 
  match x, y with
  | x, y when x = y -> "x e y são iguais"
  | x, y when x > y -> "x é maior que y"
  | _ -> "y é maior que x"