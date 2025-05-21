open Connect_lib.Board
open Connect_lib.Help
open Connect_lib.Ipc

let () =
  Sys.set_signal Sys.sigint (Sys.Signal_handle (fun _ -> limpar (); exit 0)); (* para quando o jogo é interrompido (crtl+c) ele limpar tudo*)
  ignore (Sys.command "clear");
  Printf.printf "Bem vindo ao quatro em linha! À espera de uma jogada do jogador 1.\n";
  flush stdout;
  criar_fifo "pipe_jogador1";
  criar_fifo "pipe_jogador2";

  let rec loop tabuleiro jogador jogada_atual =
    let coluna = espera_jogada_valida "pipe_jogador1" in
    if coluna < 0 || coluna >= colunas then (
      Printf.printf "Coluna inválida recebida: %d\n" coluna;
      exit 1
    );
    let tabuleiro_novo = aplicar_jogada tabuleiro coluna 'X' in
    print tabuleiro_novo;
    flush stdout;
    Printf.printf "%s\n" (frase_narrador ());
    if fim_de_jogo tabuleiro_novo 'X' then (
      Printf.printf "Jogador X venceu!\n";
    )
    else (
      Printf.printf "Jogada número %d - Jogador %c\n" jogada_atual jogador;
      let tabuleiro_copia = copia_tabuleiro tabuleiro in
      let tabuleiro_novo = pedir_jogada tabuleiro jogador in
      let jogada_str = string_of_int (obter_ultima_jogada tabuleiro_novo tabuleiro_copia) in
      let registar_jogada ficheiro jogada_num jogador coluna =
        let json = Printf.sprintf {|{"jogada":%d,"jogador":"%c","coluna":%d}|} jogada_num jogador coluna in
        escrever_append ficheiro json
      in
      escrever_pipe "pipe_jogador2" jogada_str;
      registar_jogada "jogadas_log.json" jogada_atual jogador (int_of_string jogada_str);

      if fim_de_jogo tabuleiro_novo jogador then (
        registar_jogada "jogadas_log.json" jogada_atual jogador (int_of_string jogada_str);
        let json_fim = Printf.sprintf {|{"jogada":-1,"jogador":"%c","coluna":-1}|} jogador in
        escrever_append "jogadas_log.json" json_fim;
        Printf.printf "Jogador %c venceu!\n" jogador;
      ) else
        loop tabuleiro_novo jogador (jogada_atual + 1)
    )
  in

  loop (tabuleiro_vazio ()) 'O' 1