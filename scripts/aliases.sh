#!/usr/bin/env bash
# aliases.sh - Atalhos de terminal do ateliê de escrita.
#
# Ative na sessao atual:
#     source /Users/danielmoraes/LIVRO/book/scripts/aliases.sh
#
# Ative para sempre (zsh):
#     echo 'source /Users/danielmoraes/LIVRO/book/scripts/aliases.sh' >> ~/.zshrc
#
# Todos os comandos agem sobre o LIVRO ATIVO (veja: livros).

BOOK_HOME="$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}")/.." && pwd)"
export BOOK_HOME

# Navegacao e menu
alias livro="cd '$BOOK_HOME'"
alias escrever="cd '$BOOK_HOME' && bash '$BOOK_HOME/scripts/menu.sh'"

# Gestao de livros
alias livros="bash '$BOOK_HOME/scripts/books.sh'"
alias novo-livro="bash '$BOOK_HOME/scripts/new_book.sh'"
alias trocar-livro="bash '$BOOK_HOME/scripts/books.sh'"

# Criacao de conteudo (sempre .txt vazio, conforme book.config)
alias novo-capitulo="bash '$BOOK_HOME/scripts/new_chapter.sh'"
alias nova-cena="bash '$BOOK_HOME/scripts/new_scene.sh'"
alias novo-personagem="bash '$BOOK_HOME/scripts/new_character.sh'"
alias nova-nota="bash '$BOOK_HOME/scripts/new_note.sh'"

# Producao
alias montar="bash '$BOOK_HOME/scripts/build.sh'"
alias exportar="bash '$BOOK_HOME/scripts/export.sh'"
alias palavras="bash '$BOOK_HOME/scripts/wordcount.sh'"
alias atualizar-personagens="bash '$BOOK_HOME/scripts/update_personagens.sh'"
alias editor="bash '$BOOK_HOME/scripts/nvimw.sh'"

# Assistente IA (sempre no contexto do livro ativo)
alias ai-metricas="bash '$BOOK_HOME/scripts/ai.sh' metrics"
alias ai-status="bash '$BOOK_HOME/scripts/ai.sh' status"
alias ai-consistencia="bash '$BOOK_HOME/scripts/ai.sh' consistency"
alias ai-ritmo="bash '$BOOK_HOME/scripts/ai.sh' pacing"
alias ai-temas="bash '$BOOK_HOME/scripts/ai.sh' themes"
alias ai-memoria="bash '$BOOK_HOME/scripts/ai.sh' memory"
alias ai-repeticoes="bash '$BOOK_HOME/scripts/ai.sh' repetitions"
alias ai-pergunta="bash '$BOOK_HOME/scripts/ai.sh' question"

# Vai direto para a pasta do livro ativo
cdlivro() {
    local slug
    slug=$(bash "$BOOK_HOME/scripts/books.sh" --atual 2>/dev/null) || return 1
    cd "$BOOK_HOME/livros/$slug" || return 1
    pwd
}

if [ -t 1 ] && [ "${BOOK_ALIASES_QUIET:-0}" != "1" ]; then
    printf '\033[32m✓\033[0m Ateliê carregado — \033[33mescrever\033[0m abre o menu, \033[33mlivros\033[0m lista seus livros.\n'
fi
