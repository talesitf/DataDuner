(* Escreva uma função que calcula o n-ésimo número de Tribonacci *)
(* Tribonacci é Fibonacci com 3 termos *)

(* Apenas um treino de recursão *)
let rec tribonacci n =
  if n = 0 then 0
  else if n = 1 then 1
  else if n = 2 then 1
  else tribonacci (n - 1) + tribonacci (n - 2) + tribonacci (n - 3)

(* Desafio: consegue refazer com memoização? *)
