#!/usr/bin/env bash
# books.sh - Lista, troca e inspeciona os livros do workspace.
#
#   ./scripts/books.sh              lista os livros
#   ./scripts/books.sh <slug>       torna o livro ativo
#   ./scripts/books.sh --atual      mostra apenas o livro ativo

set -uo pipefail
. "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

mostrar_lista() {
    local slug titulo caps palavras
    printf "\n${BOLD}LIVROS DO WORKSPACE${RESET}\n\n"

    if [ "$(books_count)" -eq 0 ]; then
        msg_warn "Nenhum livro ainda."
        msg_info "Crie o primeiro com: ./scripts/new_book.sh \"Título\""
        echo ""
        return 0
    fi

    local IFS=$'\n'
    for slug in $(books_list); do
        titulo=$(book_title_of "$slug")
        caps=$(count_text_files "${BOOKS_DIR}/${slug}/03_capitulos")
        palavras=$(count_words_dir "${BOOKS_DIR}/${slug}/03_capitulos")
        if [ "$slug" = "$BOOK_SLUG" ]; then
            printf "  %b●%b %b %s %b ${DIM}%s %3s cap · %6s pal.${RESET}\n" \
                "$GREEN" "$RESET" \
                "$HL" "$(pad_to "$(trunc_to "$titulo" 30)" 30)" "$HL_END" \
                "$(fit_to "$slug" 24)" "$caps" "$palavras"
        else
            printf "     %s ${DIM}%s %3s cap · %6s pal.${RESET}\n" \
                "$(fit_to "$titulo" 32)" "$(fit_to "$slug" 24)" "$caps" "$palavras"
        fi
    done
    unset IFS

    printf "\n  ${DIM}● = livro ativo · troque com: ./scripts/books.sh <slug>${RESET}\n\n"
}

case "${1:-}" in
    "")
        mostrar_lista
        ;;
    --atual|-c)
        [ -n "$BOOK_SLUG" ] || die "Nenhum livro ativo."
        printf "%s\n" "$BOOK_SLUG"
        ;;
    -h|--help)
        sed -n '2,8p' "$0"
        ;;
    *)
        if set_active_book "$1"; then
            msg_ok "Livro ativo: $(highlight "$(book_title_of "$1")")  $(printf "${DIM}(livros/%s)${RESET}" "$1")"
        else
            msg_error "Livro não encontrado: $1"
            mostrar_lista
            exit 1
        fi
        ;;
esac
