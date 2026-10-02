#!/usr/bin/env bash
# new_scene.sh - Cria uma nova cena.
# Por padrao cria um arquivo VAZIO com a extensao definida em book.config (.txt),
# prefixado com timestamp para manter a ordem cronologica.

set -euo pipefail
. "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

require_book

USE_TEMPLATE=0
FORCE=0
OPEN_AFTER=0
NO_STAMP=0
NAME=""

usage() {
    cat <<EOF
Uso: new_scene.sh [opcoes] <nome-da-cena>

Cria uma cena vazia em 02_cenas/ com a extensao .${BOOK_EXT}
O nome recebe o prefixo AAAAMMDD-HHMMSS- por padrao.

Opcoes:
  -t, --template    Usa templates/cena.* em vez de arquivo vazio
  -e, --ext EXT     Forca outra extensao (ex: -e md)
  -n, --no-stamp    Nao adiciona o prefixo de data/hora
  -f, --force       Sobrescreve o arquivo existente (faz backup antes)
  -o, --open        Abre no editor apos criar
  -h, --help        Mostra esta ajuda

Exemplo:
  new_scene.sh confronto-na-biblioteca --open
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
        -t|--template) USE_TEMPLATE=1; shift ;;
        -e|--ext)      BOOK_EXT="${2#.}"; shift 2 ;;
        -n|--no-stamp) NO_STAMP=1; shift ;;
        -f|--force)    FORCE=1; shift ;;
        -o|--open)     OPEN_AFTER=1; shift ;;
        -h|--help)     usage; exit 0 ;;
        -*)            die "Opção desconhecida: $1" ;;
        *)             NAME="${NAME:+$NAME }$1"; shift ;;
    esac
done

[ -n "$NAME" ] || { usage; exit 1; }

CLEAN=$(sanitize_name "$NAME")
[ -n "$CLEAN" ] || die "Nome inválido."

if [ "$NO_STAMP" = "1" ]; then
    BASE="$CLEAN"
else
    BASE="$(date +%Y%m%d-%H%M%S)-${CLEAN}"
fi

TITLE=$(titleize "$CLEAN")
create_doc "$DIR_CENAS" "$BASE" "cena" "$TITLE"

msg_ok "Cena criada: ${CREATED_PATH#$PROJECT_ROOT/}"
[ "$USE_TEMPLATE" = "1" ] || msg_info "Arquivo vazio — comece a escrever direto."

if [ "$OPEN_AFTER" = "1" ]; then
    open_in_editor "$CREATED_PATH"
else
    printf "${DIM}Abrir com: ./scripts/nvimw.sh \"%s\"${RESET}\n" "${CREATED_PATH#$PROJECT_ROOT/}"
fi
