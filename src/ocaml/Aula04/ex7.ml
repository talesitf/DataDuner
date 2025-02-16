(* Altere o type Person para incluir o e-mail. Faça uma função para verificar se um e-mail existe ou não no record *)

type person = { name : string; age : int; country : string; }

(* Solução imediata - vai dar problema com os dados*)
type person = { name : string; age : int; country : string; email : string; }

(* Solução legada - herança estrutural *)
type person = { name : string; age : int; country : string; }
type person_email = { p : person; email : string; }
let raul = { p = { age = 40 ; name = "Raul"; country = "Brazil"}; email = "a@a.com" }

(* Solução legada - optional extension *)
type person = { name : string; age : int; country : string; email : string option }
let raul = { age = 40 ; name = "Raul"; country = "Brazil"; email = None }
let raul = { age = 40 ; name = "Raul"; country = "Brazil"; email = Some "a@a.com" }

(* Solução: union type composition *)
type person = { name : string; age : int; country : string; };;
type person_email = { name : string; age : int; country : string; email : string; }

type person_complete =
  | Basic of person
  | Email of person_email

let raul1 = Basic { age = 40 ; name = "Raul"; country = "Brazil" } 
let raul2 = Email { age = 40 ; name = "Raul"; country = "Brazil"; email = "a@a.com" }

let check_email person input = 
  match person with
  | Basic _ -> false
  | Email { email = email; _ } when email = input -> true
  | _ -> false

