(* Escreva uma função que recebe um prefixo e devolve uma função que adiciona o prefixo a qualquer string *)

(* Retorna uma função que recebe uma string e adiciona o prefixo*)
let add_prefix prefix =
  fun str -> prefix ^ str ;;

(* Cria uma função que põe o prefixo brasileiro +55 *)
let fix_phone = add_prefix "+55 " ;;

Printf.printf "%s\n" (fix_phone "11-99999-9999") ;;