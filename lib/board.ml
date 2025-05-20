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
  let rec animar l =
    if l = linhas then ()
    else if t.(l).(col) = ' ' then (
      if l > 0 then (
        t.(l-1).(col) <- ' ';
        print t;
        Unix.sleepf 0.2
      );
      t.(l).(col) <- peca;
      print t;
      Unix.sleepf 0.2;
      if l < linhas - 1 && t.(l+1).(col) = ' ' then (
        t.(l).(col) <- ' ';
        animar (l+1)
      )
    )
  in
  animar 0;
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
  let ganhou = verificar_horiz () in
  if ganhou then (
    let cores = [|
      "\027[1;31m"; (* vermelho vivo *)
      "\027[1;33m"; (* amarelo vivo *)
      "\027[1;36m"; (* ciano vivo *)
      "\027[1;35m"; (* magenta vivo *)
      "\027[1;32m"; (* verde vivo *)
    |] in
    let emoji = "🎉" in
    for i = 0 to 5 do
      ignore (Sys.command "clear");
      let cor = cores.(i mod Array.length cores) in
      Printf.printf "%s\n\n\n\t\t%s %s JOGADOR %c VENCEU! %s %s\n\n\n\027[0m"
        cor emoji emoji peca emoji emoji;
      flush stdout;
      Unix.sleepf 0.3;
    done;
    ignore (Sys.command "clear");
    Printf.printf "\027[1;32m\n\n\n\t\t🏆🏆🏆 JOGADOR %c VENCEU! 🏆🏆🏆\n\n\n\027[0m" peca;
    flush stdout;
  );
  ganhou


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
