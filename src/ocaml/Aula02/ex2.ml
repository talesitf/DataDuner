(* Escreva uma função que recebe 3 números e retorna o maior *)

let max3 a b c =
    if a > b then
        if a > c then a
        else c
    else
        if b > c then b
        else c ;;

(* Alternativa usando AND *)

Printf.printf "%d\n" (max3 1 2 3) ;;
Printf.printf "%d\n" (max3 1 4 3) ;;
Printf.printf "%d\n" (max3 5 2 3) ;;

let max3 a b c =
    if a > b && a > c then a
    else if b > c then b
    else c ;;

Printf.printf "%d\n" (max3 1 2 3) ;;
Printf.printf "%d\n" (max3 1 4 3) ;;
Printf.printf "%d\n" (max3 5 2 3) ;;