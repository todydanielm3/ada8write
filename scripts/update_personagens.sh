#!/usr/bin/env bash
# update_personagens.sh - Gera docs/PERSONAGENS_INDICE.md a partir de 01_personagens/
# Reconhece .txt e .md.

set -uo pipefail
. "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

INDICE="${BOOK_ROOT}/PERSONAGENS.md"
mkdir -p "$(dirname "$INDICE")"

require_book
msg_step "Gerando índice de personagens de: $(highlight "$BOOK_TITLE")"

count=0
{
    echo "# Índice de Personagens — ${BOOK_TITLE}"
    echo ""
    echo "> Gerado automaticamente por \`scripts/update_personagens.sh\`."
    echo ""

    IFS=$'\n'
    for file in $(list_text_files "$DIR_PERSONAGENS"); do
        count=$(( count + 1 ))
        filename=$(basename "$file")
        name=$(titleize "${filename%.*}")
        words=$(wc -w < "$file" | tr -d ' ')

        echo "## ${count}. ${name}"
        echo ""
        echo "- **Arquivo:** \`01_personagens/${filename}\`"
        echo "- **Palavras:** ${words}"

        # Primeira linha com conteudo real como resumo
        resumo=$(grep -m1 -v -e '^[[:space:]]*$' -e '^#' "$file" 2>/dev/null | cut -c1-160)
        [ -n "$resumo" ] && echo "- **Resumo:** ${resumo}"
        echo ""
    done
    unset IFS

    if [ "$count" -eq 0 ]; then
        echo "_Nenhum personagem criado ainda._"
        echo ""
        echo "Crie o primeiro com: \`./scripts/new_character.sh nome-do-personagem\`"
    else
        echo "---"
        echo ""
        echo "**Total:** ${count} personagem(ns) · **Atualizado em:** $(date '+%d/%m/%Y %H:%M')"
    fi
} > "$INDICE"

msg_ok "Índice gerado: livros/${BOOK_SLUG}/PERSONAGENS.md (${count} personagens)"
