let criar_fifo nome =
  if not (Sys.file_exists nome) then
    Unix.mkfifo nome 0o600

let escrever_pipe nome_pipe mensagem =
  let oc = open_out nome_pipe in
  output_string oc (mensagem ^ "\n");
  flush oc;
  close_out oc

let ler_pipe nome_pipe =
  let ic = open_in nome_pipe in
  let linha = input_line ic in
  close_in ic;
  linha
