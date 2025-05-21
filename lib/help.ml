open Board
open Ipc

let rec pedir_jogada (t : tabuleiro) (peca : celula) : tabuleiro =
  Printf.printf "Escolha a coluna onde quer jogar (1-7): ";
  let entrada = read_line () in
  try
    let coluna = int_of_string entrada - 1 in
    if jogada_valida t coluna then
      let t = aplicar_jogada t coluna peca in
      print t;
      t
    else (
      Printf.printf "Coluna inválida ou cheia!\n";
      pedir_jogada t peca
    )
  with
  | Failure _ ->
    Printf.printf "Entrada inválida! Por favor, insira um número.\n";
    pedir_jogada t peca

let espera_jogada_valida pipe_nome =
  let rec ler_e_validar () =
    let jogada_str = ler_pipe pipe_nome in
    try
      int_of_string jogada_str
    with Failure _ ->
      Printf.printf "Mensagem do árbitro: '%s'\n" jogada_str;
      flush stdout;
      ler_e_validar ()
  in
  ler_e_validar ()

let esvaziar_log () =
  let oc = open_out_gen [Open_trunc; Open_wronly; Open_creat] 0o600 "jogadas_log.json" in
  close_out oc
