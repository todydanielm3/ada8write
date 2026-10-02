#!/usr/bin/env bash
# new_character.sh - Cria uma nova ficha de personagem.
# Por padrao cria um arquivo VAZIO com a extensao definida em book.config (.txt).
# Use --template para partir da ficha estruturada.

set -euo pipefail
. "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

require_book

USE_TEMPLATE=0
FORCE=0
OPEN_AFTER=0
NAME=""

usage() {
    cat <<EOF
Uso: new_character.sh [opcoes] <nome-do-personagem>

Cria uma ficha vazia em 01_personagens/ com a extensao .${BOOK_EXT}

Opcoes:
  -t, --template   Usa templates/personagem.* (ficha completa)
  -e, --ext EXT    Forca outra extensao (ex: -e md)
  -f, --force      Sobrescreve o arquivo existente (faz backup antes)
  -o, --open       Abre no editor apos criar
  -h, --help       Mostra esta ajuda

Exemplo:
  new_character.sh maria-silva --template --open
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
create_doc "$DIR_PERSONAGENS" "$BASE" "personagem" "$TITLE"

msg_ok "Personagem criado: ${CREATED_PATH#$PROJECT_ROOT/}"
[ "$USE_TEMPLATE" = "1" ] || msg_info "Arquivo vazio — comece a escrever direto."

if [ "$OPEN_AFTER" = "1" ]; then
    open_in_editor "$CREATED_PATH"
else
    printf "${DIM}Abrir com: ./scripts/nvimw.sh \"%s\"${RESET}\n" "${CREATED_PATH#$PROJECT_ROOT/}"
fi
