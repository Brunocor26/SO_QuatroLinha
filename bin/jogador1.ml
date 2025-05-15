open Connect_lib.Board
open Connect_lib.Help

let () =
  (* Inicializa o tabuleiro *)
  let rec loop tabuleiro jogada_atual =
    Printf.printf "Jogada número %d\n" jogada_atual;
    let tabuleiro_novo = pedir_jogada tabuleiro 'X' in
    print tabuleiro_novo;

    (* Verifica se o jogo terminou *)
    if fim_de_jogo tabuleiro_novo 'X' then
      Printf.printf "Jogador X venceu!\n"
    else (
      loop tabuleiro_novo (jogada_atual + 1)
    )
  in

  loop (tabuleiro_vazio ()) 1