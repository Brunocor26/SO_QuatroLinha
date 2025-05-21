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

let espera_pipe nome =
  Printf.printf "À espera de um jogador...\n";
  flush stdout;
  while not (Sys.file_exists nome) do
    Unix.sleepf 0.1;
  done

let limpar () =
  (* Remove os pipes criados e esvazia o log de jogadas *)
  (try Sys.remove "pipe_jogador1" with _ -> ());
  (try Sys.remove "pipe_jogador2" with _ -> ());
  (try let oc = open_out_gen [Open_trunc; Open_wronly; Open_creat] 0o600 "jogadas_log.json" in close_out oc with _ -> ());
  Printf.printf "\nJogo interrompido. Pipes removidos. Log esvaziado.\n";
  flush stdout

let escrever_append ficheiro mensagem =
  let oc = open_out_gen [Open_creat; Open_text; Open_append] 0o600 ficheiro in
  output_string oc (mensagem ^ "\n");
  flush oc;
  close_out oc

