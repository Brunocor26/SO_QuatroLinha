open Board

let pedir_jogada (t : tabuleiro) (peca : celula) =
  Printf.printf "Escolha a coluna onde quer jogar (0-6):";
  let entrada = read_line () in
  let coluna = int_of_string entrada in
  if jogada_valida t coluna then
    let t = aplicar_jogada t coluna peca in
    print t;

  else
    Printf.printf "Coluna inválida!"
