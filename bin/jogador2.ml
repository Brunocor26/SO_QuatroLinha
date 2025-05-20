open Connect_lib.Board
open Connect_lib.Help
open Connect_lib.Ipc

let () =
  criar_fifo "pipe_jogador1";
  criar_fifo "pipe_jogador2";

  let rec loop tabuleiro jogador jogada_atual =
    (* Espera jogada do jogador 1 *)
    let jogada_adversario = ler_pipe "pipe_jogador1" in
    let coluna = int_of_string jogada_adversario in
    if coluna < 0 || coluna >= colunas then (
      Printf.printf "Coluna inválida recebida: %d\n" coluna;
      exit 1
    );
    let tabuleiro_novo = aplicar_jogada tabuleiro coluna 'X' in
    print tabuleiro_novo;

    if fim_de_jogo tabuleiro_novo 'X' then
      Printf.printf "Jogador X venceu!\n"
    else (
      Printf.printf "Jogada número %d - Jogador %c\n" jogada_atual jogador;
      let tabuleiro_copia = copia_tabuleiro tabuleiro in
      let tabuleiro_novo = pedir_jogada tabuleiro jogador in
      let jogada_str = string_of_int (obter_ultima_jogada tabuleiro_novo tabuleiro_copia) in
      escrever_pipe "pipe_jogador2" jogada_str;

      if fim_de_jogo tabuleiro_novo jogador then
        Printf.printf "Jogador %c venceu!\n" jogador
      else
        loop tabuleiro_novo jogador (jogada_atual + 1)
    )
  in

  loop (tabuleiro_vazio ()) 'O' 1