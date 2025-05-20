open Connect_lib.Board
open Connect_lib.Help
open Connect_lib.Ipc

let () =
  criar_fifo "pipe_jogador1";
  criar_fifo "pipe_jogador2";

  let rec loop tabuleiro jogador jogada_atual =
    Printf.printf "Jogada número %d - Jogador %c\n" jogada_atual jogador;
    let tabuleiro_copia = copia_tabuleiro tabuleiro in
    let tabuleiro_novo = pedir_jogada tabuleiro jogador in
    let jogada_str = string_of_int (obter_ultima_jogada tabuleiro_novo tabuleiro_copia) in

    (* Envia a jogada para o jogador 2 *)
    escrever_pipe "pipe_jogador1" jogada_str;

    if fim_de_jogo tabuleiro_novo jogador then
      Printf.printf "Jogador %c venceu!\n" jogador
    else (
      (* Espera jogada do jogador 2 *)
      let jogada_adversario = ler_pipe "pipe_jogador2" in
      let coluna = int_of_string jogada_adversario in
      let tabuleiro_atualizado = aplicar_jogada tabuleiro_novo coluna 'O' in
      print tabuleiro_atualizado;
      if fim_de_jogo tabuleiro_atualizado 'O' then
        Printf.printf "Jogador O venceu!\n"
      else
        loop tabuleiro_atualizado jogador (jogada_atual + 1)
    )
  in

  loop (tabuleiro_vazio ()) 'X' 1