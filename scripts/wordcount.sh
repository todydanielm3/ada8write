#!/usr/bin/env bash
# wordcount.sh - Relatorio de palavras do projeto (txt e md).

set -uo pipefail
. "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

require_book

printf "\n${BOLD}CONTAGEM DE PALAVRAS${RESET}  %s\n\n" "$(highlight "$BOOK_TITLE")"

TOTAL=0

report_dir() {
    local dir="$1" rotulo="$2" subtotal=0 arquivos=0 n f
    printf "  ${BOLD}${CYAN}%s${RESET}\n" "$rotulo"

    local IFS=$'\n'
    for f in $(list_text_files "$dir"); do
        n=$(wc -w < "$f" | tr -d ' ')
        subtotal=$(( subtotal + n ))
        arquivos=$(( arquivos + 1 ))
        printf "    %-48s %7s\n" "$(basename "$f" | cut -c1-48)" "$n"
    done
    unset IFS

    if [ "$arquivos" -eq 0 ]; then
        printf "    ${DIM}(vazio)${RESET}\n\n"
    else
        printf "    ${GRAY}%s${RESET}\n" "--------------------------------------------------------"
        printf "    %-48s ${GREEN}%7s${RESET}\n\n" "subtotal ($arquivos arquivos)" "$subtotal"
    fi
    TOTAL=$(( TOTAL + subtotal ))
}

report_dir "$DIR_CAPITULOS"   "Capítulos"
report_dir "$DIR_CENAS"       "Cenas"
report_dir "$DIR_PERSONAGENS" "Personagens"
report_dir "$DIR_NOTAS"       "Notas"

PCT=0
[ "${BOOK_WORD_GOAL:-0}" -gt 0 ] 2>/dev/null && PCT=$(( TOTAL * 100 / BOOK_WORD_GOAL ))

printf "  ${BOLD}TOTAL: %s palavras${RESET}  ${DIM}(meta %s · %s%%)${RESET}\n" \
    "$TOTAL" "$BOOK_WORD_GOAL" "$PCT"
printf "  ${DIM}~%s páginas impressas · ~%s min de leitura${RESET}\n\n" \
    "$(( TOTAL / 250 ))" "$(( TOTAL / 250 ))"
