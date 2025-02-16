(* Faça uma função que entra um record no formato do exemplo e retorna se a pessoa é maior de idade ou não *)

type person = { name : string; age : int; country : string; }

let is_adult person = 
  match person with
  | { age = age; _ } when age >= 18 -> true
  | _ -> false