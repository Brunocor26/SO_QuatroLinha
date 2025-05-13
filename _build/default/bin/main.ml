open Connect_lib.Board
open Connect_lib.Help

let () =
  let t = tabuleiro_vazio () in (* Cria um tabuleiro vazio *)
  let _ = pedir_jogada t 'X' in 
  ()