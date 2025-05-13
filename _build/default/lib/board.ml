let linhas = 7
let colunas = 6

type celula = char (* ' ', 'X' ou 'O' *)
type tabuleiro = celula array array (* matriz 6x7 *)

let tabuleiro_vazio () : tabuleiro =
  Array.init linhas (fun _ -> Array.make colunas ' ')

let print (t: tabuleiro) =
  print_endline "\n 0 1 2 3 4 5 6";
  Array.iter (fun linha ->
      Array.iter (fun c ->
          Printf.printf "|%c" c
        ) linha;
      print_endline "|"
    ) t;
  print_endline "---------------"

let jogada_valida t col =
  col >= 0 && col < colunas && t.(0).(col) = ' '

let aplicar_jogada t col peca =
  let rec procurar_linha l =
    if l = linhas then -1
    else if t.(l).(col) = ' ' then l
    else procurar_linha (l - 1)
  in
  let l = procurar_linha (linhas - 1) in
  if l >= 0 then t.(l).(col) <- peca;
  t

(*let fim_de_jogo t =
  (* Aqui podes implementar verificação de vitória *)
  false  (* placeholder *)*)