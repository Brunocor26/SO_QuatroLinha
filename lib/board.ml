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
        let s =
          match c with
          | 'X' -> Printf.sprintf "|\027[1;31m%c\027[0m" c  (* vermelho *)
          | 'O' -> Printf.sprintf "|\027[1;32m%c\027[0m" c  (* verde *)
          | _   -> Printf.sprintf "|%c" c
        in
        Buffer.add_string buffer s
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

let frase_narrador () =
  let narrador = [|
    "\027[1;31mEste é o Quatro em Linha!\027[0m";      (* vermelho *)
    "\027[1;33mQue jogada perspicaz!\027[0m";          (* amarelo *)
    "\027[1;36mNo que estará a pensar?\027[0m";         (* ciano *)
    "\027[1;35mPode ter ganho aqui o jogo...\027[0m";   (* magenta *)
    "\027[1;32mSerá que se enganou?\027[0m";            (* verde *)
    "\027[1;34mNada previa esta jogada!\027[0m";        (* azul *)
  |] in
  Random.self_init ();
  let idx = Random.int (Array.length narrador) in
  narrador.(idx)

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

let verificar_vertical () =
     let rec aux col linha count =
      if linha >= linhas then false
      else if t.(linha).(col) = peca then
        if count + 1 = 4 then true
        else aux col (linha + 1) (count + 1)
      else aux col (linha + 1) 0
    in
    let rec loop col =
      if col >= colunas then false
      else if aux col 0 0 then true
      else loop (col + 1)
    in
    loop 0
in

let verificar_diagonal_principal () =
    let rec aux l c count =
      if l >= linhas || c >= colunas then false
      else if t.(l).(c) = peca then
        if count + 1 = 4 then true
        else aux (l + 1) (c + 1) (count + 1)
      else aux (l + 1) (c + 1) 0
    in
    let rec loop_linhas l =
      if l > linhas - 4 then false
      else
        let rec loop_colunas c =
          if c > colunas - 4 then loop_linhas (l + 1)
          else if aux l c 0 then true
          else loop_colunas (c + 1)
        in
        loop_colunas 0
    in
    loop_linhas 0
  in

let verificar_diagonal_secundaria () =
    let rec aux l c count =
      if l >= linhas || c < 0 then false
      else if t.(l).(c) = peca then
        if count + 1 = 4 then true
        else aux (l + 1) (c - 1) (count + 1)
      else aux (l + 1) (c - 1) 0
    in
    let rec loop_linhas l =
      if l > linhas - 4 then false
      else
        let rec loop_colunas c =
          if c < 3 then loop_linhas (l + 1)
          else if aux l c 0 then true
          else loop_colunas (c - 1)
        in
        loop_colunas (colunas - 1)
    in
    loop_linhas 0
  in

  let ganhou =
  verificar_horiz ()
  || verificar_vertical ()
  || verificar_diagonal_principal ()
  || verificar_diagonal_secundaria ()
  in

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