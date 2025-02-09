(* Escreva uma função que retorna o próximo primo *)

(* Importa o contexto do exercício 5 *)
#use "ex5.ml";;

let rec next_prime n = 
  if is_prime (n + 1) then (n + 1)
  else next_prime (n + 1) ;;

Printf.printf "Next: %d\n" (next_prime (int_of_string Sys.argv.(1))) ;;

(* Bonus: imprimir o m próximos primos *)
let rec print_primes counter last =
  let m = (int_of_string Sys.argv.(2)) in 
    if counter > m then ()
    else let next = next_prime (last + 1) in
      Printf.printf "+%d: %d\n" counter next;
      print_primes (counter + 1) next


let () = if Array.length Sys.argv > 2 then
  print_primes 1 (int_of_string Sys.argv.(1) + 1)
  
(* Discussão sobre () e ; na Aula 3 *)


