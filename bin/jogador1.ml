open Connect_lib.Board
open Connect_lib.Help

let () =
  
  let rec loop tabuleiro jogador jogada_atual =
    Printf.printf "Jogada número %d - Jogador %c\n" jogada_atual jogador;
    let tabuleiro_novo = pedir_jogada tabuleiro jogador in
    print tabuleiro_novo;

    if fim_de_jogo tabuleiro_novo jogador then
      Printf.printf "Jogador %c venceu!\n" jogador
    else (
      let proximo_jogador = if jogador = 'X' then 'O' else 'X' in
      loop tabuleiro_novo proximo_jogador (jogada_atual + 1)
    )
  in

  loop (tabuleiro_vazio ()) 'X' 1