open Board

let pedir_jogada (t : tabuleiro) (peca : celula) : tabuleiro =
  Printf.printf "Escolha a coluna onde quer jogar (0-6): ";
  let entrada = read_line () in
  try
    let coluna = int_of_string entrada in
    if jogada_valida t coluna then
      let t = aplicar_jogada t coluna peca in
      print t;
      t (* devolve o tabuleiro atualizado *)
    else (
      Printf.printf "Coluna inválida!\n";
      t (* devolve o tabuleiro original *)
    )
  with
  | Failure _ ->
      Printf.printf "Entrada inválida! Por favor, insira um número.\n";
      t (* devolve tabuleiro original *)