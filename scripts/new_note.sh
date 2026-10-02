#!/usr/bin/env bash
# new_note.sh - Cria uma nota de trabalho em 00_notas/ (vazia, .txt por padrao).

set -euo pipefail
. "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

require_book

USE_TEMPLATE=0
FORCE=0
OPEN_AFTER=0
NAME=""

usage() {
    cat <<EOF
Uso: new_note.sh [opcoes] <titulo-da-nota>

Cria uma nota vazia em 00_notas/ com a extensao .${BOOK_EXT}
O nome recebe o prefixo AAAAMMDD-.

Opcoes:
  -e, --ext EXT   Forca outra extensao
  -f, --force     Sobrescreve (com backup)
  -o, --open      Abre no editor apos criar
  -h, --help      Mostra esta ajuda
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
        -e|--ext)  BOOK_EXT="${2#.}"; shift 2 ;;
        -f|--force) FORCE=1; shift ;;
        -o|--open) OPEN_AFTER=1; shift ;;
        -h|--help) usage; exit 0 ;;
        -*)        die "Opção desconhecida: $1" ;;
        *)         NAME="${NAME:+$NAME }$1"; shift ;;
    esac
done

[ -n "$NAME" ] || { usage; exit 1; }

CLEAN=$(sanitize_name "$NAME")
[ -n "$CLEAN" ] || die "Nome inválido."

BASE="$(date +%Y%m%d)-${CLEAN}"
create_doc "$DIR_NOTAS" "$BASE" "" "$(titleize "$CLEAN")"

msg_ok "Nota criada: ${CREATED_PATH#$PROJECT_ROOT/}"
[ "$OPEN_AFTER" = "1" ] && open_in_editor "$CREATED_PATH"
exit 0
