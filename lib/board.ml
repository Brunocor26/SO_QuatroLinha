let linhas = 7
let colunas = 6

type celula = char (* ' ', 'X' ou 'O' *)
type tabuleiro = celula array array (* matriz 6x7 *)

let tabuleiro_vazio () : tabuleiro =
  Array.init linhas (fun _ -> Array.make colunas ' ')

let tabuleiro_to_string (t: tabuleiro) : string =
  let buffer = Buffer.create 128 in
  Buffer.add_string buffer " 1 2 3 4 5 6 7\n";
  Array.iter (fun linha ->
      Array.iter (fun c ->
          Buffer.add_string buffer (Printf.sprintf "|%c" c)
        ) linha;
      Buffer.add_string buffer "|\n"
    ) t;
    ignore (Sys.command "clear");  (* clear na consola *)
  Buffer.add_string buffer "---------------\n";
  Buffer.contents buffer

let print (t: tabuleiro) =
  print_endline (tabuleiro_to_string t)

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

let fim_de_jogo (t : tabuleiro) (peca : celula) : bool =
  let verificar_horiz () =
    Array.exists (fun linha ->
      let rec aux count col =
        if col >= colunas then false
        else if linha.(col) = peca then
          if count + 1 = 4 then true
          else aux (count+1) (col+1)
        else aux 0 (col + 1)
      in 
      aux 0 0
      ) t
    in
    verificar_horiz()

let obter_ultima_jogada t_novo t_antigo =
  let coluna = ref (-1) in
  for c = 0 to colunas - 1 do
    for l = 0 to linhas - 1 do
      if t_antigo.(l).(c) <> t_novo.(l).(c) then coluna := c
    done
  done;
  !coluna

let copia_tabuleiro (t : tabuleiro) : tabuleiro =
  Array.init linhas (fun l -> Array.copy t.(l))