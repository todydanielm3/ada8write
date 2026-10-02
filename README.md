```
        ╔══════════════════════════════════════════════════════════════╗
        ║                                                              ║
        ║          █████╗ ████████╗███████╗██╗     ██╗███████╗         ║
        ║         ██╔══██╗╚══██╔══╝██╔════╝██║     ██║██╔════╝         ║
        ║         ███████║   ██║   █████╗  ██║     ██║█████╗           ║
        ║         ██╔══██║   ██║   ██╔══╝  ██║     ██║██╔══╝           ║
        ║         ██║  ██║   ██║   ███████╗███████╗██║███████╗         ║
        ║         ╚═╝  ╚═╝   ╚═╝   ╚══════╝╚══════╝╚═╝╚══════╝         ║
        ║                                                              ║
        ║                     D E   E S C R I T A                      ║
        ║                                                              ║
        ║         ┌──────────────────────────────────────────┐         ║
        ║         │  txt → nvim → pandoc → livro             │         ║
        ║         │  sem nuvem · sem distração · sem lock-in │         ║
        ║         └──────────────────────────────────────────┘         ║
        ║                                                              ║
        ║        v2.0 « multi-livro »    macOS · bash · python3        ║
        ║                                                              ║
        ╚══════════════════════════════════════════════════════════════╝
```

> *"O melhor prólogo é o que contém menos cousas."*
> — Machado de Assis, **Memórias Póstumas de Brás Cubas**, 1881

![abertura](assets/intro.gif)

```console
$ ./scripts/menu.sh
```

---

## ❧ I · O que é isto

Uma oficina de escrita que mora no terminal. Nada de editor na nuvem, nada de
assinatura mensal, nada de `.docx` corrompido às 3h da manhã. Apenas **arquivos
de texto puro**, alguns scripts bem-comportados e um assistente de IA que só
enxerga o livro em que você está trabalhando agora.

```
   seus .txt  ──▶  build.sh  ──▶  book.md  ──▶  pandoc  ──▶  PDF · DOCX · EPUB
                                     │
                                     └──▶  ai.sh  ──▶  métricas · consistência
```

**Três princípios:**

```
  I.   O arquivo nasce vazio.     Nenhum template entre você e a frase.
  II.  Um livro por vez.          Nada vaza de um projeto para outro.
  III. Tudo é texto.              Daqui a 30 anos ainda vai abrir.
```

---

## ❧ II · Ficha catalográfica

```
  ┌─────────────────────────────────────────────────────────────────┐
  │  Formato nativo ......... .txt (UTF-8, LF)                      │
  │  Editor ................. NeoVim  (VS Code como alternativa)    │
  │  Composição ............. pandoc → Markdown → PDF/DOCX/EPUB     │
  │  Automação .............. bash 3.2, compatível com o macOS      │
  │  Assistente ............. Python 3 + OpenAI (opcional)          │
  │  Dependências mínimas ... nenhuma. Tudo o mais é luxo.          │
  └─────────────────────────────────────────────────────────────────┘
```

---

## ❧ III · A planta do prédio

A **plataforma** (scripts, templates, editores, docs) é compartilhada.
Cada **livro** é uma república independente dentro de `livros/`.

```
book/
│
├── livros/
│   ├── uma-odisseia-do-saber/        ▚ (slug = nome da pasta)
│   │   ├── 00_notas/        ▚ pesquisa, ideias, restos de madrugada
│   │   ├── 01_personagens/  ▚ fichas de quem habita a história
│   │   ├── 02_cenas/        ▚ fragmentos ainda sem endereço
│   │   ├── 03_capitulos/    ▚ o que de fato entra no livro
│   │   ├── 90_arquivo/      ▚ o cemitério dos cortes
│   │   ├── 99_build/        ▚ book.md · .pdf · .docx · .epub
│   │   ├── .ai/cache/       ▚ memória da IA — SÓ deste livro
│   │   ├── book.config      ▚ título, autor, meta de palavras
│   │   └── index.md         ▚ índice narrativo
│   │
│   └── o-escondido/         ▚ mesma estrutura, universo paralelo
│
├── scripts/                 ▚ a sala de máquinas (lib/ = peças comuns)
├── templates/               ▚ modelos, para quem gosta de andaimes
├── assets/                  ▚ o GIF de abertura e arte ASCII
├── docs/                    ▚ manuais (legado/ = a versão 1.0)
├── .nvim/  .vscode/         ▚ configuração dos editores
├── book.config              ▚ padrões da plataforma
└── .livro-ativo             ▚ o ponteiro: qual livro está na bancada
```

> **Isolamento por desenho.** Nenhum comando enxerga dois livros ao mesmo tempo.
> Textos, build, configuração e memória da IA pertencem ao livro ativo.
> Livro novo = página em branco, inclusive para a máquina.

---

## ❧ IV · Primeira sessão

```bash
# 0. os atalhos (opcional, mas a vida é curta)
source scripts/aliases.sh

# 1. quem está na bancada?
livros                         # ● marca o livro ativo
livros o-escondido             # troca de universo

# 2. abrir um projeto novo do zero
novo-livro "A Casa Vazia"

# 3. escrever
escrever                       # o painel
novo-capitulo "1.3.O retorno"  # cria um .txt vazio e nada mais
nova-cena confronto-final -o   # -o abre direto no editor

# 4. compor
montar                         # 99_build/book.md
exportar                       # PDF · DOCX · EPUB
palavras                       # o veredito numérico
```

Para tornar os atalhos permanentes:

```bash
echo "source $PWD/scripts/aliases.sh" >> ~/.zshrc
```

---

## ❧ V · O painel

```
         ╭──────────────────────────────────────────────────────────────╮
         │  ATELIÊ DE ESCRITA                                           │
         │  livro ativo: ▓ Uma Odisseia do saber ▓ · Daniel Moraes      │
         ╰──────────────────────────────────────────────────────────────╯

           ▰▰▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱   10%   8.533 / 80.000 palavras
           3 capítulos · 1 cena · 0 personagens · 2 livros no workspace
```

O livro ativo aparece sempre em **marca-texto**, no cabeçalho, na lista de
livros, na contagem de palavras e na abertura. Impossível escrever no projeto
errado por distração.

| Tecla   | Ação                                  | Tecla       | Ação                      |
|---------|---------------------------------------|-------------|---------------------------|
| `1`–`4` | Criar capítulo · cena · personagem · nota | `5`–`8` | Abrir o que já existe     |
| `m`     | Montar o livro                        | `a`         | Dashboard de métricas     |
| `x`     | Exportar PDF/DOCX/EPUB                | `r`         | Consistência narrativa    |
| `w`     | Contar palavras                       | `t`         | Análise temática          |
| `u`     | Índice de personagens                 | `p`         | Ritmo narrativo           |
| `b`     | **Trocar de livro**                   | `L`         | **Novo livro**            |
| `c`     | Configurações                         | `i` `h` `q` | Info · ajuda · sair       |

---

## ❧ VI · A vinheta de abertura

Toda sessão começa com uma animação — porque ferramenta boa também tem
cerimônia. O GIF `assets/intro.gif` é renderizado **dentro do terminal**:

```
  imgcat (iTerm2)  →  chafa  →  kitty icat  →  viu  →  ASCII animado
```

```bash
brew install chafa                   # renderização em qualquer terminal
python3 scripts/make_intro_gif.py    # regera o GIF (Pillow)
./scripts/menu.sh --no-anim          # para os dias apressados
```

Ajuste fino em `book.config`:

```bash
BOOK_ANIMATION=1            # 0 desliga de vez
BOOK_ANIM_PLAYER="auto"     # auto | imgcat | chafa | kitty | viu | ascii
```

---

## ❧ VII · Por que `.txt`

Porque o Markdown pede formatação antes da frase existir, e isso é uma forma
educada de procrastinação. Aqui, **todo arquivo novo nasce vazio**:

```bash
./scripts/new_chapter.sh "1.3.O retorno"       # 03_capitulos/1.3.O retorno.txt — vazio
./scripts/new_chapter.sh "1.3.O retorno" -t    # -t = com template, se quiser andaimes
./scripts/new_chapter.sh "apêndice" -e md      # -e = outra extensão, desta vez só
```

Na montagem, o `build.sh` é educado com texto cru: deriva o título do nome do
arquivo (quando ele ainda não tem um `#`) e remove a indentação decorativa,
para o pandoc não confundir parágrafo recuado com bloco de código.

Padrão global em `book.config` → `BOOK_EXT="txt"` (ou tecla `c` no menu).

---

## ❧ VIII · A sala de máquinas

| Script | Ofício |
|--------|--------|
| `menu.sh` | O painel. Ponto de entrada de tudo. |
| `new_book.sh` | Funda um livro novo, isolado, com estrutura completa |
| `books.sh` | Lista os livros e troca o ativo |
| `new_chapter.sh` · `new_scene.sh` · `new_character.sh` · `new_note.sh` | Criam `.txt` vazios |
| `build.sh` | Costura `03_capitulos/` em `99_build/book.md` (`--list`, `--yes`) |
| `export.sh` | Chama o pandoc (`--pdf`, `--docx`, `--epub`) |
| `wordcount.sh` | O veredito numérico, arquivo por arquivo |
| `update_personagens.sh` | Gera `PERSONAGENS.md` a partir das fichas |
| `ai.sh` | O assistente, sempre no contexto do livro ativo |
| `nvimw.sh` | NeoVim já apontado para o livro certo |
| `aliases.sh` | Os atalhos de terminal |
| `make_intro_gif.py` | Regera a vinheta de abertura |

Todos bebem da mesma fonte: `scripts/lib/common.sh` (livro ativo, configuração
em cascata, cores, helpers de largura com acento) e `scripts/lib/anim.sh`.

**Precedência de configuração:**

```
  variável de ambiente  >  livros/<slug>/book.config  >  book.config (global)
```

```bash
BOOK_EDITOR=code escrever        # só desta vez, abra no VS Code
BOOK_SLUG=o-escondido montar     # monta outro livro sem trocar o ativo
```

---

## ❧ IX · A máquina que lê junto

```bash
./scripts/ai.sh metrics        # dashboard local, offline, sem gastar token
./scripts/ai.sh status
./scripts/ai.sh consistency    # contradições e furos de continuidade
./scripts/ai.sh themes | pacing | memory | repetitions | question
```

A chave da API vive em `.ai_assistant/.env` — compartilhada e **jamais**
versionada. A memória narrativa vive em `livros/<slug>/.ai/cache/`: uma por
livro, nunca reaproveitada. Apagar esse diretório zera a memória da máquina;
seus textos permanecem intactos.

```
  ┌────────────────────────────────────────────────────────────┐
  │  livro A  →  .ai/cache/  ──╳──  .ai/cache/  ←  livro B     │
  │              nenhuma ponte, nenhum vazamento               │
  └────────────────────────────────────────────────────────────┘
```

---

## ❧ X · Suprimentos

```bash
brew install neovim pandoc chafa      # editor, composição, animação
brew install --cask basictex          # necessário só para PDF
pip3 install -r .ai_assistant/requirements.txt
```

Nada disso é obrigatório para escrever. Um `.txt` e um editor bastam — o resto
é para o dia em que o livro precisar virar objeto.

---

## ❧ XI · Biblioteca de consulta

```
  docs/START_HERE.md .............. os primeiros dois minutos
  docs/REFERENCIA_RAPIDA.md ....... correção ortográfica no NeoVim
  docs/SPELL_GUIDE.md ............. o guia longo do corretor
  docs/GUIA_PERSONAGENS.md ........ fichas e índice automático
  docs/AI_ASSISTANT_SETUP.md ...... configuração do assistente
  docs/legado/ .................... escavações da versão 1.0
```

---

```
        ╔══════════════════════════════════════════════════════════════╗
        ║  COLOFÃO                                                     ║
        ║                                                              ║
        ║  Composto em terminal, em fonte monoespaçada, sob a luz      ║
        ║  de um cursor piscando. Nenhum parágrafo foi formatado       ║
        ║  antes de ser escrito.                                       ║
        ║                                                              ║
        ║  Daniel Moraes · pt-BR · escrito à mão, montado por script   ║
        ║                                                              ║
        ║                      :wq                                     ║
        ╚══════════════════════════════════════════════════════════════╝
```
