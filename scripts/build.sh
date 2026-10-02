#!/usr/bin/env bash
# build.sh - Monta o livro concatenando tudo que esta em 03_capitulos/
#
# Reconhece .txt e .md, na ordem alfabetica/numerica dos nomes
# (1.1..., 1.2..., 2.1...). A saida e sempre Markdown, para alimentar o pandoc.
#
#   ./scripts/build.sh            interativo
#   ./scripts/build.sh --yes      sem perguntas, copia para a raiz
#   ./scripts/build.sh --list     so mostra a ordem de montagem

set -uo pipefail
. "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

require_book

OUTPUT="${DIR_BUILD}/book.md"
ASSUME_YES=0
LIST_ONLY=0

while [ $# -gt 0 ]; do
    case "$1" in
        -y|--yes)  ASSUME_YES=1; shift ;;
        -l|--list) LIST_ONLY=1; shift ;;
        -h|--help) sed -n '2,10p' "$0"; exit 0 ;;
        *)         die "Opção desconhecida: $1" ;;
    esac
done

# Ordenacao natural: "2.10" vem depois de "2.9"
list_chapters() {
    list_text_files "$DIR_CAPITULOS" | LC_ALL=C sort -t/ -k9 -V 2>/dev/null \
        || list_text_files "$DIR_CAPITULOS"
}

CHAPTERS=$(list_chapters)

if [ -z "$CHAPTERS" ]; then
    msg_warn "Nenhum capítulo em ${DIR_CAPITULOS#$PROJECT_ROOT/}"
    msg_info "Crie um com: ./scripts/new_chapter.sh \"1.1.Começo\""
    exit 0
fi

if [ "$LIST_ONLY" = "1" ]; then
    printf "\n${BOLD}Ordem de montagem${RESET}\n\n"
    i=1
    IFS=$'\n'
    for c in $CHAPTERS; do
        printf "  %2s. %s\n" "$i" "$(basename "$c")"
        i=$(( i + 1 ))
    done
    unset IFS
    echo ""
    exit 0
fi

msg_step "Montando o livro..."
mkdir -p "$DIR_BUILD"

if [ -f "$OUTPUT" ]; then
    mv "$OUTPUT" "${OUTPUT}.bak-$(date +%Y%m%d-%H%M%S)"
    msg_info "Build anterior guardado como backup"
fi

{
    echo "---"
    echo "title: \"${BOOK_TITLE}\""
    echo "author: \"${BOOK_AUTHOR}\""
    echo "lang: ${BOOK_LANG}"
    echo "date: \"$(date +%Y-%m-%d)\""
    echo "---"
    echo ""
} > "$OUTPUT"

COUNT=0
IFS=$'\n'
for chapter in $CHAPTERS; do
    name=$(basename "$chapter")
    base="${name%.*}"
    ext="${name##*.}"

    printf "  %s\n" "$name"
    {
        echo ""
        echo "<!-- fonte: ${name} -->"
        echo ""
    } >> "$OUTPUT"

    if [ "$ext" = "md" ] || [ "$ext" = "markdown" ]; then
        # Markdown entra como esta (ja tem seus proprios titulos)
        cat "$chapter" >> "$OUTPUT"
    else
        # Texto puro: so cria titulo se o arquivo ja nao comecar com um
        first=$(grep -m1 -v '^[[:space:]]*$' "$chapter" 2>/dev/null)
        case "$first" in
            \#*) : ;;
            *)   printf '# %s\n\n' "$base" >> "$OUTPUT" ;;
        esac
        # Remove a indentacao decorativa: 4+ espacos viram bloco de codigo no pandoc
        LC_ALL=C sed 's/^[[:space:]]\{1,\}//' "$chapter" >> "$OUTPUT"
    fi

    {
        echo ""
        echo ""
        echo '\newpage'
        echo ""
    } >> "$OUTPUT"

    COUNT=$(( COUNT + 1 ))
done
unset IFS

WORDS=$(wc -w < "$OUTPUT" | tr -d ' ')

echo ""
msg_ok "Livro montado: ${OUTPUT#$PROJECT_ROOT/}"
printf "  ${DIM}%s capítulos · ~%s palavras${RESET}\n\n" "$COUNT" "$WORDS"

if [ "$ASSUME_YES" = "1" ]; then
    cp "$OUTPUT" "${PROJECT_ROOT}/book.md"
    msg_ok "Cópia em livros/${BOOK_SLUG}/book.md"
else
    printf "Copiar para a raiz do projeto como book.md? [s/N] "
    read -r resposta
    case "$resposta" in
        s|S|sim|Sim)
            cp "$OUTPUT" "${PROJECT_ROOT}/book.md"
            msg_ok "Cópia em livros/${BOOK_SLUG}/book.md" ;;
    esac
fi
