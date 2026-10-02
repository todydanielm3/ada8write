#!/usr/bin/env bash
# export.sh - Exporta 99_build/book.md para DOCX, PDF e EPUB via pandoc.
#
#   ./scripts/export.sh              tudo que for possivel
#   ./scripts/export.sh --docx       apenas DOCX
#   ./scripts/export.sh --pdf        apenas PDF
#   ./scripts/export.sh --epub       apenas EPUB

set -uo pipefail
. "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

require_book

SOURCE="${DIR_BUILD}/book.md"
WANT_DOCX=0; WANT_PDF=0; WANT_EPUB=0

while [ $# -gt 0 ]; do
    case "$1" in
        --docx) WANT_DOCX=1; shift ;;
        --pdf)  WANT_PDF=1; shift ;;
        --epub) WANT_EPUB=1; shift ;;
        -h|--help) sed -n '2,8p' "$0"; exit 0 ;;
        *) die "Opção desconhecida: $1" ;;
    esac
done

if [ $(( WANT_DOCX + WANT_PDF + WANT_EPUB )) -eq 0 ]; then
    WANT_DOCX=1; WANT_PDF=1; WANT_EPUB=1
fi

msg_step "Exportando o livro..."

command -v pandoc >/dev/null 2>&1 || {
    msg_error "Pandoc não encontrado."
    msg_info "Instale com: brew install pandoc"
    msg_info "Para PDF também: brew install --cask basictex"
    exit 1
}

# Monta automaticamente se o book.md nao existir ou estiver desatualizado
if [ ! -f "$SOURCE" ]; then
    msg_info "book.md ainda não existe — montando primeiro."
    bash "${DIR_SCRIPTS}/build.sh" --yes || die "Falha ao montar o livro."
fi

mkdir -p "$DIR_BUILD"

COMMON_OPTS="--standalone --toc --toc-depth=2 --metadata=lang:${BOOK_LANG}"

if [ "$WANT_DOCX" = "1" ]; then
    msg_info "Gerando DOCX..."
    if pandoc "$SOURCE" -o "${DIR_BUILD}/book.docx" --from markdown --to docx $COMMON_OPTS; then
        msg_ok "99_build/book.docx"
    else
        msg_error "Falha ao gerar DOCX"
    fi
fi

if [ "$WANT_EPUB" = "1" ]; then
    msg_info "Gerando EPUB..."
    if pandoc "$SOURCE" -o "${DIR_BUILD}/book.epub" --from markdown --to epub $COMMON_OPTS; then
        msg_ok "99_build/book.epub"
    else
        msg_error "Falha ao gerar EPUB"
    fi
fi

if [ "$WANT_PDF" = "1" ]; then
    ENGINE=""
    for e in xelatex pdflatex lualatex; do
        command -v "$e" >/dev/null 2>&1 && { ENGINE="$e"; break; }
    done
    if [ -n "$ENGINE" ]; then
        msg_info "Gerando PDF (${ENGINE})..."
        if pandoc "$SOURCE" -o "${DIR_BUILD}/book.pdf" \
            --from markdown --to pdf --pdf-engine="$ENGINE" $COMMON_OPTS \
            -V geometry:margin=2.5cm \
            -V documentclass=book \
            -V fontsize=12pt \
            -V linestretch=1.3 \
            -V lang="${BOOK_LANG}"; then
            msg_ok "99_build/book.pdf"
        else
            msg_error "Falha ao gerar PDF (verifique a instalação do LaTeX)"
        fi
    else
        msg_warn "LaTeX não encontrado — PDF não gerado"
        msg_info "Instale com: brew install --cask basictex"
    fi
fi

echo ""
msg_ok "Exportação concluída — arquivos em 99_build/"
