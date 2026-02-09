SO_QuatroLinha

O SO_QuatroLinha é uma implementação do clássico jogo "Quatro em Linha" (Connect Four), desenvolvida no âmbito da disciplina de Sistemas Operativos. O projeto foca-se na comunicação entre processos (IPC) utilizando Pipes (Ficheiros FIFO) e é desenvolvido na linguagem OCaml, utilizando o sistema de construção Dune.
📋 Funcionalidades

    Comunicação IPC: Utilização de pipes para a troca de mensagens entre instâncias de jogadores.

    Gestão de Tabuleiro: Lógica de jogo modular para verificar vitórias e jogadas válidas.

    Interface por Terminal: Jogo totalmente baseado em linha de comandos.

    Sistema Multi-Processo: Suporte para dois jogadores a correr em processos independentes.

🛠️ Tecnologias Utilizadas

    OCaml: Linguagem de programação funcional principal.

    Dune: Gestor de projetos e sistema de build.

    Python: Script de auxílio (árbitro) para gestão de partidas.

📂 Estrutura do Projeto

    bin/: Contém o código fonte dos executáveis dos jogadores (jogador1.ml e jogador2.ml).

    lib/: Bibliotecas de suporte para a lógica do tabuleiro (board.ml), comunicação (ipc.ml) e funções auxiliares (help.ml).

    arbitro.py: Script Python para coordenação adicional do jogo.

🚀 Como Executar

Para realizar uma partida entre dois jogadores utilizando Pipes, siga estes passos em dois terminais distintos:
Preparação (Qualquer Terminal)

Antes de iniciar, limpe e compile o projeto:
Bash

dune clean
dune build

Terminal 1 (Jogador 1)

Inicie o primeiro jogador:
Bash

dune exec bin/jogador1.exe

Terminal 2 (Jogador 2)

Importante: Inicie o segundo jogador antes de realizar a primeira jogada no Terminal 1, para garantir que os Pipes de comunicação estão prontos:
Bash

dune exec bin/jogador2.exe

Fluxo de Jogo

Após ambos os executáveis estarem a correr, alterne entre os terminais para realizar as jogadas conforme as instruções no ecrã.
