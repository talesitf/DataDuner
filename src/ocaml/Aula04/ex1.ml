(* Faça uma função chamada *describe_number* que retorna o nome em string de um número até 5. Retorne "outro" para números maiores que 6. *)

let describe_number n = 
  match n with
  | 1 -> "um"
  | 2 -> "dois"
  | 3 -> "três"
  | 4 -> "quatro"
  | 5 -> "cinco"
  | _ -> "outro"