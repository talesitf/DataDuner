(* Escreva uma função que calcula a soma dos dígitos de um número *)

(* Ideia: usa o resto de divisão por 10 para separar o último dígito *)
(* e a divisão por 10 para separar o restante dos dígitos *)
(* Exemplo: 1234 -> (1234//10) + (1234 mod 10) *)

(* Como precisa de um loop no número de digitos, é usada uma recursão *)
(* Caso base: quando for o último dígito, retornar o dígito *)
(* Passo indutivo: somar o dígito separado com o próximo dígito *)

(* Atenção: não esquecer dos parênteses para as expressions *)
let rec soma_digitos n =
    if n < 10 then n (* Caso base *)
    else (n mod 10) + soma_digitos (n / 10) ;;

Printf.printf "%d\n" (soma_digitos 1234) ;;