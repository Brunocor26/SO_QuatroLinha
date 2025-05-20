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
    let tabuleiro_copia = copia_tabuleiro tabuleiro in
    let tabuleiro_novo = pedir_jogada tabuleiro jogador in
    let jogada_str = string_of_int (obter_ultima_jogada tabuleiro_novo tabuleiro_copia) in

    (* Envia a jogada para o jogador 2 com uma frase aleatoria do narrador *)
    escrever_pipe "pipe_jogador1" jogada_str;

    if fim_de_jogo tabuleiro_novo jogador then (
      Printf.printf "Jogador %c venceu!\n" jogador;
      Sys.remove "pipe_jogador1";
      Sys.remove "pipe_jogador2";
    ) else (
      (* Espera jogada do jogador 2 *)
      let jogada_adversario = ler_pipe "pipe_jogador2" in
      let coluna = int_of_string jogada_adversario in
      let tabuleiro_atualizado = aplicar_jogada tabuleiro_novo coluna 'O' in
      print tabuleiro_atualizado;
      if fim_de_jogo tabuleiro_atualizado 'O' then (
        Printf.printf "Jogador O venceu!\n";
        Sys.remove "pipe_jogador1";
        Sys.remove "pipe_jogador2";
      ) else
        loop tabuleiro_atualizado jogador (jogada_atual + 1)
    )
  in

  loop (tabuleiro_vazio ()) 'X' 1