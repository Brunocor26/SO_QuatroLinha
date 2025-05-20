# SO_QuatroLinha

Como executar com os pipes?
Para jogar com jogador 1 e o 2, basta abrirem dois terminais, num deles fazem:
- dune clean
- dune build
- dune exec bin/jogador1.exe

e no outro terminal antes de fazerem a jogada com o jogador1, correm no terminal isto:
- dune exec bin/jogador2.exe

Para assim que jogeum com o jogador1, o jogador2 ja esteja a espera da jogada, depois basta irem trocando de terminal e jogarem