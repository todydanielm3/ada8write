#!/usr/bin/env bash
# new_chapter.sh - Cria um novo capitulo.
# Por padrao cria um arquivo VAZIO com a extensao definida em book.config (.txt).

set -euo pipefail
. "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

require_book

USE_TEMPLATE=0
FORCE=0
OPEN_AFTER=0
NAME=""

usage() {
    cat <<EOF
Uso: new_chapter.sh [opcoes] <nome-do-capitulo>

Cria um capitulo vazio em 03_capitulos/ com a extensao .${BOOK_EXT}

Opcoes:
  -t, --template   Usa templates/capitulo.* em vez de arquivo vazio
  -e, --ext EXT    Forca outra extensao (ex: -e md)
  -f, --force      Sobrescreve o arquivo existente (faz backup antes)
  -o, --open       Abre no editor apos criar
  -h, --help       Mostra esta ajuda

Exemplos:
  new_chapter.sh "1.3.O retorno"
  new_chapter.sh cap-04-confronto --open
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
        -t|--template) USE_TEMPLATE=1; shift ;;
        -e|--ext)      BOOK_EXT="${2#.}"; shift 2 ;;
        -f|--force)    FORCE=1; shift ;;
        -o|--open)     OPEN_AFTER=1; shift ;;
        -h|--help)     usage; exit 0 ;;
        -*)            die "Opção desconhecida: $1" ;;
        *)             NAME="${NAME:+$NAME }$1"; shift ;;
    esac
done

[ -n "$NAME" ] || { usage; exit 1; }

BASE=$(sanitize_name "$NAME")
[ -n "$BASE" ] || die "Nome inválido."

TITLE=$(titleize "$BASE")
create_doc "$DIR_CAPITULOS" "$BASE" "capitulo" "$TITLE"

msg_ok "Capítulo criado: ${CREATED_PATH#$PROJECT_ROOT/}"
[ "$USE_TEMPLATE" = "1" ] || msg_info "Arquivo vazio — comece a escrever direto."

if [ "$OPEN_AFTER" = "1" ]; then
    open_in_editor "$CREATED_PATH"
else
    printf "${DIM}Abrir com: ./scripts/nvimw.sh \"%s\"${RESET}\n" "${CREATED_PATH#$PROJECT_ROOT/}"
fi
