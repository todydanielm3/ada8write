#!/usr/bin/env bash
# new_book.sh - Cria um novo livro isolado dentro de livros/
#
# Cada livro tem suas proprias pastas de escrita, sua configuracao e sua
# memoria de IA. Nada e compartilhado entre livros.
#
#   ./scripts/new_book.sh "A Casa Vazia"
#   ./scripts/new_book.sh "A Casa Vazia" --autor "Daniel Moraes" --meta 90000

set -uo pipefail
. "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

TITULO=""
AUTOR="${BOOK_AUTHOR}"
META="${BOOK_WORD_GOAL}"
SLUG=""
ATIVAR=1

usage() {
    cat <<EOF
Uso: new_book.sh [opcoes] "Titulo do livro"

Opcoes:
  -a, --autor NOME    Autor (padrao: ${BOOK_AUTHOR})
  -m, --meta N        Meta de palavras (padrao: ${BOOK_WORD_GOAL})
  -s, --slug SLUG     Nome da pasta (padrao: derivado do titulo)
      --nao-ativar    Cria sem tornar o livro ativo
  -h, --help          Mostra esta ajuda
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
        -a|--autor) AUTOR="$2"; shift 2 ;;
        -m|--meta)  META="$2"; shift 2 ;;
        -s|--slug)  SLUG="$2"; shift 2 ;;
        --nao-ativar) ATIVAR=0; shift ;;
        -h|--help)  usage; exit 0 ;;
        -*)         die "Opção desconhecida: $1" ;;
        *)          TITULO="${TITULO:+$TITULO }$1"; shift ;;
    esac
done

[ -n "$TITULO" ] || { usage; exit 1; }

[ -n "$SLUG" ] || SLUG=$(slugify "$TITULO")
[ -n "$SLUG" ] || die "Não consegui derivar um nome de pasta do título."

DEST="${BOOKS_DIR}/${SLUG}"
[ -d "$DEST" ] && die "Já existe um livro em livros/${SLUG}"

msg_step "Criando livro: ${TITULO}"

mkdir -p "$DEST"/{00_notas,01_personagens,02_cenas,03_capitulos,90_arquivo,99_build}
mkdir -p "$DEST/.ai/cache"

cat > "${DEST}/book.config" <<EOF
# book.config - Configuracao do livro "${TITULO}"
# Vale apenas para este livro. Padroes da plataforma ficam em ../../book.config

BOOK_TITLE="${TITULO}"
BOOK_AUTHOR="${AUTOR}"
BOOK_LANG="pt-BR"
BOOK_WORD_GOAL=${META}

# Formato dos arquivos criados (txt por padrao)
BOOK_EXT="${BOOK_EXT}"
EOF

# Indice inicial do livro
if [ -f "${DIR_TEMPLATES}/index.md" ]; then
    LC_ALL=C sed -e "s/{{TITULO}}/${TITULO}/g" \
                 -e "s/{{AUTOR}}/${AUTOR}/g" \
                 -e "s/{{META}}/${META}/g" \
                 -e "s/{{DATA}}/$(date +%Y-%m-%d)/g" \
                 "${DIR_TEMPLATES}/index.md" > "${DEST}/index.md"
else
    printf '# %s\n\n_Índice do livro._\n' "$TITULO" > "${DEST}/index.md"
fi

# A memoria da IA nasce vazia: nenhum resquicio de outro livro
cat > "${DEST}/.ai/README.txt" <<'EOF'
Memória da IA deste livro.

cache/narrative_memory.json  resumo narrativo acumulado
cache/word_snapshots.json    histórico de contagem de palavras

Este diretório pertence a um único livro e nunca é compartilhado.
Apagá-lo apenas zera a memória: os textos não são afetados.
EOF

msg_ok "Livro criado em livros/${SLUG}/"
printf "  ${DIM}pastas de escrita · book.config próprio · memória de IA isolada${RESET}\n"

if [ "$ATIVAR" = "1" ]; then
    set_active_book "$SLUG" && msg_ok "Livro ativo agora: ${TITULO}"
fi
