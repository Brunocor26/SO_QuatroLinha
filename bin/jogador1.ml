open Connect_lib.Board
open Connect_lib.Help
open Connect_lib.Ipc

let () =
  Sys.set_signal Sys.sigint (Sys.Signal_handle (fun _ -> limpar (); exit 0)); (* para quando o jogo é interrompido (crtl+c) ele limpar tudo*)
  criar_fifo "pipe_jogador1";
  (* Aguarda até o jogador2 criar o pipe dele (entrar no jogo) *)
  espera_pipe "pipe_jogador2";
  print (tabuleiro_vazio ());

  let rec loop tabuleiro jogador jogada_atual =
    Printf.printf "Jogada número %d - Jogador %c\n" jogada_atual jogador;
    print tabuleiro;
    flush stdout;
    if(jogada_atual!=1) then(
      Printf.printf "%s\n" (frase_narrador ()));
    let tabuleiro_copia = copia_tabuleiro tabuleiro in
    let tabuleiro_novo = pedir_jogada tabuleiro jogador in
    let jogada_str = string_of_int (obter_ultima_jogada tabuleiro_novo tabuleiro_copia) in
    let registar_jogada ficheiro jogada_num jogador coluna =
      let json = Printf.sprintf {|{"jogada":%d,"jogador":"%c","coluna":%d}|} jogada_num jogador coluna in
      escrever_append ficheiro json
    in
        (* Envia a jogada para o jogador 2 *)
        escrever_pipe "pipe_jogador1" jogada_str;
        (* escreve num log para podermos visualizar graças a um python *)
        registar_jogada "jogadas_log.json" jogada_atual jogador (int_of_string jogada_str);

      if fim_de_jogo tabuleiro_novo jogador then (
        registar_jogada "jogadas_log.json" jogada_atual jogador (int_of_string jogada_str);
        let json_fim = Printf.sprintf {|{"jogada":-1,"jogador":"%c","coluna":-1}|} jogador in
        escrever_append "jogadas_log.json" json_fim;
        Printf.printf "Jogador %c venceu!\n" jogador;
        Sys.remove "pipe_jogador1";
        Sys.remove "pipe_jogador2";
      ) else (
        (* Espera jogada do jogador 2 ou mensagem do árbitro *)
        let coluna = espera_jogada_valida "pipe_jogador2" in
        let tabuleiro_atualizado = aplicar_jogada tabuleiro_novo coluna 'O' in
        print tabuleiro_atualizado;
        flush stdout;
        Printf.printf "%s\n"(frase_narrador ());
        if fim_de_jogo tabuleiro_atualizado 'O' then (
          registar_jogada "jogadas_log.json" (jogada_atual + 1) 'O' coluna;
          let json_fim = {|{"jogada":-1,"jogador":"O","coluna":-1}|} in
          escrever_append "jogadas_log.json" json_fim;
          Printf.printf "Jogador O venceu!\n";
          limpar ();
        ) else
          loop tabuleiro_atualizado jogador (jogada_atual + 1)
      )
    in

    loop (tabuleiro_vazio ()) 'X' 1