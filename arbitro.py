import json
import tkinter as tk
from tkinter import messagebox

LINHAS = 6
COLUNAS = 7
CELULA_SIZE = 60  # tamanho quadrado de cada célula

def criar_tabuleiro_vazio():
    return [[' ' for _ in range(COLUNAS)] for _ in range(LINHAS)]

def aplicar_jogada(tabuleiro, coluna, jogador):
    for i in reversed(range(LINHAS)):
        if tabuleiro[i][coluna] == ' ':
            tabuleiro[i][coluna] = jogador
            break

def desenhar_tabuleiro(canvas, tabuleiro):
    canvas.delete("all")
    for i in range(LINHAS):
        for j in range(COLUNAS):
            x0, y0 = CELULA_SIZE * j, CELULA_SIZE * i
            x1, y1 = x0 + CELULA_SIZE, y0 + CELULA_SIZE
            canvas.create_rectangle(x0, y0, x1, y1, fill="#1e90ff", outline="white", width=2)  # azul + contorno branco
            cor_peca = "white"
            if tabuleiro[i][j] == 'X':
                cor_peca = "red"
            elif tabuleiro[i][j] == 'O':
                cor_peca = "yellow"
            canvas.create_oval(x0+8, y0+8, x1-8, y1-8, fill=cor_peca, outline="black", width=2)

def ler_jogadas(f, pos):
    f.seek(pos)
    linhas = f.readlines()
    return linhas, f.tell()

def atualizar():
    global pos
    linhas, pos_novo = ler_jogadas(f, pos)
    for linha in linhas:
        linha = linha.strip()
        if not linha:
            continue
        try:
            jogada = json.loads(linha)
        except json.JSONDecodeError:
            continue
        if jogada.get("jogada") == -1:
            vencedor = jogada.get("jogador", "?")
            desenhar_tabuleiro(canvas, tabuleiro)
            messagebox.showinfo("Fim do Jogo", f"Jogo terminado! Vencedor: {vencedor}")
            root.destroy()
            return
        aplicar_jogada(tabuleiro, jogada["coluna"], jogada["jogador"])
    if pos_novo != pos:
        desenhar_tabuleiro(canvas, tabuleiro)
        pos = pos_novo
    root.after(500, atualizar)

def enviar_mensagem():
    mensagem = "Não quero batotas! \n"
    try:
        with open("pipe_jogador1", "w") as p1, open("pipe_jogador2", "w") as p2:
            p1.write(mensagem)
            p2.write(mensagem)
        messagebox.showinfo("Mensagem enviada", "Mensagem enviada com sucesso aos jogadores.")
    except Exception as e:
        messagebox.showerror("Erro", f"Erro ao escrever nos pipes:\n{e}")

def enviar_mensagem_jogador1():
    mensagem = entry_jogador1.get() + "\n"
    try:
        with open("pipe_jogador2", "w") as p1:
            p1.write(mensagem)
        messagebox.showinfo("Mensagem enviada", "Mensagem enviada ao Jogador 1.")
    except Exception as e:
        messagebox.showerror("Erro", f"Erro ao escrever no pipe_jogador1:\n{e}")

def enviar_mensagem_jogador2():
    mensagem = entry_jogador2.get() + "\n"
    try:
        with open("pipe_jogador1", "w") as p2:
            p2.write(mensagem)
        messagebox.showinfo("Mensagem enviada", "Mensagem enviada ao Jogador 2.")
    except Exception as e:
        messagebox.showerror("Erro", f"Erro ao escrever no pipe_jogador2:\n{e}")

tabuleiro = criar_tabuleiro_vazio()

root = tk.Tk()
root.title("Quatro em Linha - Árbitro")

# Frame para canvas e botão
frame = tk.Frame(root, padx=10, pady=10)
frame.pack()

canvas = tk.Canvas(frame, width=COLUNAS*CELULA_SIZE, height=LINHAS*CELULA_SIZE, bg="#003366", bd=0, highlightthickness=0)
canvas.pack(pady=(0,10))

botao = tk.Button(frame, text="Enviar mensagem aos jogadores", command=enviar_mensagem, bg="#4CAF50", fg="white", font=("Arial", 12, "bold"), padx=10, pady=5)
botao.pack()

# Campo e botão para Jogador 1
frame_j1 = tk.Frame(frame)
frame_j1.pack(pady=2)
tk.Label(frame_j1, text="Mensagem Jogador 1:").pack(side=tk.LEFT)
entry_jogador1 = tk.Entry(frame_j1, width=30)
entry_jogador1.pack(side=tk.LEFT, padx=5)
btn_j1 = tk.Button(frame_j1, text="Enviar", command=enviar_mensagem_jogador1, bg="#2196F3", fg="white")
btn_j1.pack(side=tk.LEFT)

# Campo e botão para Jogador 2
frame_j2 = tk.Frame(frame)
frame_j2.pack(pady=2)
tk.Label(frame_j2, text="Mensagem Jogador 2:").pack(side=tk.LEFT)
entry_jogador2 = tk.Entry(frame_j2, width=30)
entry_jogador2.pack(side=tk.LEFT, padx=5)
btn_j2 = tk.Button(frame_j2, text="Enviar", command=enviar_mensagem_jogador2, bg="#FF9800", fg="white")
btn_j2.pack(side=tk.LEFT)

# Abre o ficheiro para leitura contínua
try:
    f = open("jogadas_log.json", "r")
except FileNotFoundError:
    messagebox.showerror("Erro", "Ficheiro 'jogadas_log.json' não encontrado.")
    root.destroy()
    exit()

pos = 0

atualizar()

root.mainloop()
