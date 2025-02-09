(* Escreva uma função que verifica se um número é primo *)

(* Define uma função que retorna se é primo*)
let is_prime n = 
  (* Define uma função que verifica se ele não é divisível por outro menor que ele a partir do 2 *)
  (* true se for primo; false se não for *)
  let rec check_divisor d =
    if d >= n then true (* Ok, poderia ser raiz de n *)
    else ((n mod d <> 0) && check_divisor (d + 1))
  in (n > 1 && check_divisor 2) ;;
  
(* Verifica se é o arquivo principal executado *)
(* Equivalente a if __name__ == "__main__" em Python *)
let () = if Sys.argv.(0) = "ex5.ml" then
  (* Lê o argumento da chamada de execução, convertendo de string para int *)
  (* A posição 0 é o nome do arquivo executado *)
  let input = int_of_string Sys.argv.(1) in
  Printf.printf "%b\n" (is_prime input) ;;

(* Desafio: Implementar o Crivo de Eratóstenes (Sieve of Eratosthene)! *)