import json
import tkinter as tk
from tkinter import messagebox
import os
import platform

LINHAS = 6
COLUNAS = 7
CELULA_SIZE = 60

# Escolha automática da fonte de emoji conforme o SO
so = platform.system()
if so == "Windows":
    font_emoji = ("Segoe UI Emoji", 12)
elif so == "Darwin":
    font_emoji = ("Apple Color Emoji", 12)
else:
    font_emoji = ("Noto Color Emoji", 12)

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
            canvas.create_rectangle(x0, y0, x1, y1, fill="#1565C0", outline="#BBDEFB", width=3)
            cor_peca = "#F5F5F5"
            if tabuleiro[i][j] == 'X':
                cor_peca = "#D32F2F"
            elif tabuleiro[i][j] == 'O':
                cor_peca = "#FBC02D"
            canvas.create_oval(x0+10, y0+10, x1-10, y1-10, fill=cor_peca, outline="#333333", width=2)

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


def enviar_mensagem_jogador1():
    mensagem = entry_jogador1.get().strip()
    if not mensagem:
        messagebox.showwarning("Aviso", "Por favor, escreva uma mensagem para o Jogador 1.")
        return
    try:
        with open("pipe_jogador2", "w") as p2:
            p2.write(mensagem + "\n")
        messagebox.showinfo("Mensagem enviada", "Mensagem enviada ao Jogador 1.")
        entry_jogador1.delete(0, tk.END)
    except Exception as e:
        messagebox.showerror("Erro", f"Erro ao escrever no pipe_jogador2:\n{e}")

def enviar_mensagem_jogador2():
    mensagem = entry_jogador2.get().strip()
    if not mensagem:
        messagebox.showwarning("Aviso", "Por favor, escreva uma mensagem para o Jogador 2.")
        return
    try:
        with open("pipe_jogador1", "w") as p1:
            p1.write(mensagem + "\n")
        messagebox.showinfo("Mensagem enviada", "Mensagem enviada ao Jogador 2.")
        entry_jogador2.delete(0, tk.END)
    except Exception as e:
        messagebox.showerror("Erro", f"Erro ao escrever no pipe_jogador1:\n{e}")

def verificar_pipes():
    pipes_ok = os.path.exists("pipe_jogador1") and os.path.exists("pipe_jogador2")
    if pipes_ok:
        aviso_label.config(text="Jogadores prontos!", fg="#388E3C", bg="#C8E6C9")
        btn_j1.config(state="normal")
        btn_j2.config(state="normal")
    else:
        aviso_label.config(
            text="À espera dos jogadores...\n(Pipes não encontrados)", 
            fg="#fff", bg="#D32F2F"
        )
        btn_j1.config(state="disabled")
        btn_j2.config(state="disabled")
    root.after(1000, verificar_pipes)

tabuleiro = criar_tabuleiro_vazio()

root = tk.Tk()
root.title("Quatro em Linha - Árbitro")
root.geometry(f"{COLUNAS*CELULA_SIZE + 60}x{LINHAS*CELULA_SIZE + 260}")
root.resizable(False, False)
root.configure(bg="#ECEFF1")

# Frame principal centralizado
frame = tk.Frame(root, bg="#ECEFF1", padx=20, pady=20)
frame.pack(expand=True)

# Canvas com borda arredondada simulada usando frame
canvas_frame = tk.Frame(frame, bg="#0D47A1", bd=6, relief="ridge")
canvas_frame.pack(pady=(0, 20))
canvas = tk.Canvas(canvas_frame, width=COLUNAS*CELULA_SIZE, height=LINHAS*CELULA_SIZE,
                   bg="#1976D2", bd=0, highlightthickness=0)
canvas.pack()

# Frame para mensagens individuais
mensagens_frame = tk.Frame(frame, bg="#ECEFF1")
mensagens_frame.pack(fill="x")

# Jogador 1
frame_j1 = tk.Frame(mensagens_frame, bg="#BBDEFB", bd=2, relief="groove", padx=10, pady=8)
frame_j1.pack(side="left", expand=True, fill="both", padx=(0,10))
tk.Label(frame_j1, text="Mensagem Jogador 1:", bg="#BBDEFB",
         font=("Segoe UI", 10, "bold")).pack(anchor="w")
entry_jogador1 = tk.Entry(frame_j1, font=("Segoe UI", 11))
entry_jogador1.pack(fill="x", pady=(6, 10))
btn_j1 = tk.Button(frame_j1, text="Enviar", command=enviar_mensagem_jogador1,
                   bg="#1976D2", fg="white", font=("Segoe UI", 10, "bold"),
                   relief="flat", padx=8, pady=6, activebackground="#42A5F5")
btn_j1.pack(fill="x")

# Jogador 2
frame_j2 = tk.Frame(mensagens_frame, bg="#FFE082", bd=2, relief="groove", padx=10, pady=8)
frame_j2.pack(side="left", expand=True, fill="both", padx=(10,0))
tk.Label(frame_j2, text="Mensagem Jogador 2:", bg="#FFE082",
         font=("Segoe UI", 10, "bold")).pack(anchor="w")
entry_jogador2 = tk.Entry(frame_j2, font=("Segoe UI", 11))
entry_jogador2.pack(fill="x", pady=(6, 10))
btn_j2 = tk.Button(frame_j2, text="Enviar", command=enviar_mensagem_jogador2,
                   bg="#FBC02D", fg="black", font=("Segoe UI", 10, "bold"),
                   relief="flat", padx=8, pady=6, activebackground="#FFEB3B")
btn_j2.pack(fill="x")

# Aviso sobre o estado da conexão dos jogadores
aviso_label = tk.Label(frame, text="À espera dos jogadores...", font=("Segoe UI", 12, "bold"),
                       bg="#D32F2F", fg="#fff", pady=10)
aviso_label.pack(fill="x", pady=(0, 15))

# Abre o ficheiro para leitura contínua
try:
    f = open("jogadas_log.json", "r")
except FileNotFoundError:
    messagebox.showerror("Erro", "Ficheiro 'jogadas_log.json' não encontrado.")
    root.destroy()
    exit()

pos = 0

atualizar()
verificar_pipes()

# Funções para inserir emoji nos campos
def inserir_emoji_j1(emoji):
    entry_jogador1.insert(tk.END, emoji)

def inserir_emoji_j2(emoji):
    entry_jogador2.insert(tk.END, emoji)

# Adiciona botões de emoji para Jogador 1
emoji_frame_j1 = tk.Frame(frame_j1, bg="#BBDEFB")
emoji_frame_j1.pack(fill="x", pady=(0, 5))
for emoji in ["😀", "😎", "⚽", "🎲", "🚩", "👏", "😡", "🔔"]:
    btn = tk.Button(emoji_frame_j1, text=emoji, font=font_emoji, width=2,
                    command=lambda e=emoji: inserir_emoji_j1(e), relief="flat", bg="#E3F2FD")
    btn.pack(side="left", padx=1)

# Adiciona botões de emoji para Jogador 2
emoji_frame_j2 = tk.Frame(frame_j2, bg="#FFE082")
emoji_frame_j2.pack(fill="x", pady=(0, 5))
for emoji in ["😀", "😎", "⚽", "🎲", "🚩", "👏", "😡", "🔔"]:
    btn = tk.Button(emoji_frame_j2, text=emoji, font=font_emoji, width=2,
                    command=lambda e=emoji: inserir_emoji_j2(e), relief="flat", bg="#FFF8E1")
    btn.pack(side="left", padx=1)

root.mainloop()
