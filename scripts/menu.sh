#!/usr/bin/env bash
# menu.sh - Painel interativo do projeto de escrita.
#
#   ./scripts/menu.sh            menu completo (com animacao de abertura)
#   ./scripts/menu.sh --no-anim  pula a animacao
#
# Toda a configuracao vem de book.config (extensao padrao, editor, metas).

set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "${SCRIPT_DIR}/lib/common.sh"
. "${SCRIPT_DIR}/lib/anim.sh"

cd "$PROJECT_ROOT"

[ "${1:-}" = "--no-anim" ] && BOOK_NO_ANIM=1

PANEL_WIDTH=62

# --------------------------------------------------------------------------
# Helpers de layout
# --------------------------------------------------------------------------
pad_left() {
    local width total
    width=$(term_width)
    total=$(( (width - PANEL_WIDTH) / 2 ))
    [ "$total" -lt 2 ] && total=2
    printf "%*s" "$total" ""
}

PAD=""
refresh_pad() { PAD=$(pad_left); }

line() { printf "%s%b\n" "$PAD" "$*"; }

rule() {
    local ch="${1:-─}" i=0 out=""
    while [ "$i" -lt "$PANEL_WIDTH" ]; do out="${out}${ch}"; i=$(( i + 1 )); done
    line "${GRAY}${out}${RESET}"
}

section() {
    printf "%s  %b%s%b%b%s%b\n" "$PAD" "${BOLD}${CYAN}" "$(pad_to "$1" 28)" "${RESET}" "${BOLD}${CYAN}" "$2" "${RESET}"
}

# item <tecla> <rotulo> <tecla2> <rotulo2>
item() {
    local k1="$1" l1="$2" k2="${3:-}" l2="${4:-}"
    if [ -n "$k2" ]; then
        printf "%s   %b%-2s%b %s  %b%-2s%b %s\n" \
            "$PAD" "${YELLOW}" "$k1" "${RESET}" "$(pad_to "$l1" 23)" "${YELLOW}" "$k2" "${RESET}" "$l2"
    else
        printf "%s   %b%-2s%b %s\n" "$PAD" "${YELLOW}" "$k1" "${RESET}" "$l1"
    fi
}

# Barra de progresso: progress_bar <atual> <meta>
progress_bar() {
    local cur="$1" goal="$2" filled i bar="" pct=0
    [ "${goal:-0}" -gt 0 ] 2>/dev/null || goal=1
    pct=$(( cur * 100 / goal ))
    [ "$pct" -gt 100 ] && pct=100
    filled=$(( pct * 20 / 100 ))
    i=0
    while [ "$i" -lt 20 ]; do
        if [ "$i" -lt "$filled" ]; then bar="${bar}▰"; else bar="${bar}▱"; fi
        i=$(( i + 1 ))
    done
    echo "${bar}|${pct}"
}

format_number() {
    printf "%s" "$1" | sed -e :a -e 's/\(.*[0-9]\)\([0-9]\{3\}\)/\1.\2/;ta'
}

# --------------------------------------------------------------------------
# Cabecalho e status
# --------------------------------------------------------------------------
draw_header() {
    refresh_pad
    printf "\033[H\033[2J"
    echo ""
    line "${BOLD}${CYAN}╭──────────────────────────────────────────────────────────────╮${RESET}"
    printf "%s%b│%b  %b%s%b  %b│%b\n" "$PAD" "${BOLD}${CYAN}" "${RESET}" "${BOLD}" "$(fit_to "ATELIÊ DE ESCRITA" 58)" "${RESET}" "${BOLD}${CYAN}" "${RESET}"
    draw_active_book_line
    line "${BOLD}${CYAN}╰──────────────────────────────────────────────────────────────╯${RESET}"
    echo ""
}

# Linha do livro ativo com marca-texto, alinhada dentro da caixa (58 colunas)
draw_active_book_line() {
    local rotulo="livro ativo:" sufixo titulo max resto
    sufixo=" · ${BOOK_AUTHOR}"
    max=$(( 58 - $(str_len "$rotulo") - 1 - 2 - $(str_len "$sufixo") ))
    [ "$max" -lt 10 ] && { max=$(( 58 - $(str_len "$rotulo") - 3 )); sufixo=""; }
    titulo=$(trunc_to "$BOOK_TITLE" "$max")
    resto=$(( 58 - $(str_len "$rotulo") - 1 - 2 - $(str_len "$titulo") - $(str_len "$sufixo") ))
    [ "$resto" -lt 0 ] && resto=0
    printf "%s%b│%b  %b%s%b %b %s %b%b%s%b%*s  %b│%b\n" \
        "$PAD" "${BOLD}${CYAN}" "${RESET}" \
        "${DIM}" "$rotulo" "${RESET}" \
        "${HL}" "$titulo" "${HL_END}" \
        "${DIM}" "$sufixo" "${RESET}" "$resto" "" \
        "${BOLD}${CYAN}" "${RESET}"
}

draw_status() {
    local caps cenas pers notas palavras bar pct livros

    caps=$(count_text_files "$DIR_CAPITULOS")
    cenas=$(count_text_files "$DIR_CENAS")
    pers=$(count_text_files "$DIR_PERSONAGENS")
    notas=$(count_text_files "$DIR_NOTAS")
    palavras=$(count_words_project)
    livros=$(books_count)

    bar=$(progress_bar "$palavras" "$BOOK_WORD_GOAL")
    pct="${bar#*|}"
    bar="${bar%%|*}"

    printf "%s  %b%s%b  %b%3s%%%b   %s / %s palavras\n" \
        "$PAD" "${GREEN}" "$bar" "${RESET}" "${BOLD}" "$pct" "${RESET}" \
        "$(format_number "$palavras")" "$(format_number "$BOOK_WORD_GOAL")"
    printf "%s  %b%s capítulos · %s cenas · %s personagens · %s notas · .%s · %s livro(s) no workspace%b\n" \
        "$PAD" "${DIM}" "$caps" "$cenas" "$pers" "$notas" "$BOOK_EXT" "$livros" "${RESET}"
    echo ""
}

draw_menu() {
    draw_header
    draw_status
    rule
    echo ""
    section "CRIAR" "BIBLIOTECA DESTE LIVRO"
    item "1" "Novo capítulo"     "5" "Abrir capítulo"
    item "2" "Nova cena"         "6" "Abrir cena"
    item "3" "Novo personagem"   "7" "Abrir personagem"
    item "4" "Nova nota"         "8" "Abrir livro no editor"
    echo ""
    section "PRODUÇÃO" "ASSISTENTE IA (deste livro)"
    item "m" "Montar livro"       "a" "Dashboard de métricas"
    item "x" "Exportar PDF/DOCX"  "r" "Consistência narrativa"
    item "w" "Contar palavras"    "t" "Análise temática"
    item "u" "Índice de personagens" "p" "Ritmo narrativo"
    echo ""
    section "LIVROS" ""
    item "b" "Trocar de livro"    "L" "Novo livro"
    echo ""
    rule
    printf "%s  %b c %b Configurações   %b i %b Informações   %b h %b Ajuda   %b q %b Sair\n" \
        "$PAD" "${YELLOW}" "${RESET}" "${YELLOW}" "${RESET}" "${YELLOW}" "${RESET}" "${YELLOW}" "${RESET}"
    echo ""
}

# --------------------------------------------------------------------------
# Gestao de livros
# --------------------------------------------------------------------------
recarregar_contexto() {
    # Recarrega common.sh para que todos os DIR_* apontem ao novo livro ativo
    . "${SCRIPT_DIR}/lib/common.sh"
}

tela_trocar_livro() {
    local slugs=() s i=1 escolha
    while IFS= read -r s; do
        [ -n "$s" ] && slugs+=("$s")
    done <<EOF
$(books_list)
EOF

    draw_header
    line "${BOLD}LIVROS DO WORKSPACE${RESET}"
    line "${DIM}Cada livro tem textos, configuração e memória de IA próprios.${RESET}"
    echo ""
    for s in "${slugs[@]}"; do
        if [ "$s" = "$BOOK_SLUG" ]; then
            printf "%s  %b%3s%b %b●%b %b %s %b ${DIM}%s · %s palavras${RESET}\n" \
                "$PAD" "${YELLOW}" "$i" "${RESET}" "${GREEN}" "${RESET}" \
                "${HL}" "$(pad_to "$(trunc_to "$(book_title_of "$s")" 30)" 30)" "${HL_END}" \
                "$s" "$(count_words_dir "${BOOKS_DIR}/${s}/03_capitulos")"
        else
            printf "%s  %b%3s%b   %s ${DIM}%s · %s palavras${RESET}\n" \
                "$PAD" "${YELLOW}" "$i" "${RESET}" \
                "$(fit_to "$(book_title_of "$s")" 32)" \
                "$s" "$(count_words_dir "${BOOKS_DIR}/${s}/03_capitulos")"
        fi
        i=$(( i + 1 ))
    done
    echo ""
    printf "%s  Número do livro (Enter cancela): " "$PAD"
    read -r escolha
    [ -z "$escolha" ] && return 0
    case "$escolha" in
        ''|*[!0-9]*) return 0 ;;
    esac
    if [ "$escolha" -ge 1 ] && [ "$escolha" -le "${#slugs[@]}" ]; then
        set_active_book "${slugs[$(( escolha - 1 ))]}"
        recarregar_contexto
        printf "%s" "$PAD"; msg_ok "Livro ativo: $(highlight "$BOOK_TITLE")"
        sleep 0.8
    fi
}

tela_novo_livro() {
    local titulo autor meta
    draw_header
    line "${BOLD}NOVO LIVRO${RESET}"
    line "${DIM}Cria uma pasta isolada em livros/ — nenhuma informação é${RESET}"
    line "${DIM}compartilhada com os outros livros, nem a memória da IA.${RESET}"
    echo ""
    printf "%s  Título (Enter cancela): " "$PAD"
    read -r titulo
    [ -z "$titulo" ] && return 0
    printf "%s  Autor [%s]: " "$PAD" "$BOOK_AUTHOR"
    read -r autor
    [ -z "$autor" ] && autor="$BOOK_AUTHOR"
    printf "%s  Meta de palavras [%s]: " "$PAD" "$BOOK_WORD_GOAL"
    read -r meta
    case "$meta" in ''|*[!0-9]*) meta="$BOOK_WORD_GOAL" ;; esac
    echo ""
    bash "${SCRIPT_DIR}/new_book.sh" --autor "$autor" --meta "$meta" "$titulo"
    recarregar_contexto
    pause
}

# --------------------------------------------------------------------------
# Seletor de arquivos
# --------------------------------------------------------------------------
pick_file() {
    local dir="$1" titulo="$2"
    local files=() f i=1 escolha

    while IFS= read -r f; do
        [ -n "$f" ] && files+=("$f")
    done <<EOF
$(list_text_files "$dir")
EOF

    if [ "${#files[@]}" -eq 0 ]; then
        msg_warn "Nenhum arquivo em ${dir#$PROJECT_ROOT/} ainda."
        pause
        return 1
    fi

    draw_header
    line "${BOLD}${titulo}${RESET}"
    echo ""
    for f in "${files[@]}"; do
        printf "%s  %b%3s%b %-42s %b%6s pal.%b\n" \
            "$PAD" "${YELLOW}" "$i" "${RESET}" \
            "$(basename "$f")" "${DIM}" "$(wc -w < "$f" | tr -d ' ')" "${RESET}"
        i=$(( i + 1 ))
    done
    echo ""
    printf "%s  Número do arquivo (Enter cancela): " "$PAD"
    read -r escolha
    [ -z "$escolha" ] && return 1
    case "$escolha" in
        ''|*[!0-9]*) msg_warn "Escolha inválida."; sleep 1; return 1 ;;
    esac
    if [ "$escolha" -lt 1 ] || [ "$escolha" -gt "${#files[@]}" ]; then
        msg_warn "Fora do intervalo."; sleep 1; return 1
    fi
    open_in_editor "${files[$(( escolha - 1 ))]}"
    return 0
}

# --------------------------------------------------------------------------
# Acoes de criacao
# --------------------------------------------------------------------------
criar() {
    local script="$1" rotulo="$2" nome
    draw_header
    line "${BOLD}${rotulo}${RESET}"
    line "${DIM}O arquivo será criado vazio, no formato .${BOOK_EXT}${RESET}"
    echo ""
    printf "%s  Nome (Enter cancela): " "$PAD"
    read -r nome
    [ -z "$nome" ] && return 0
    echo ""
    bash "${SCRIPT_DIR}/${script}" --open "$nome"
}

# --------------------------------------------------------------------------
# Ferramentas do assistente
# --------------------------------------------------------------------------
run_ai() {
    local cmd="$1"
    clear
    bash "${SCRIPT_DIR}/ai.sh" "$cmd"
    pause
}

# --------------------------------------------------------------------------
# Configuracoes
# --------------------------------------------------------------------------
set_config() {
    config_set "$1" "$2" "${3:-livro}"
    recarregar_contexto
}

tela_config() {
    local escolha valor
    while true; do
        draw_header
        line "${BOLD}CONFIGURAÇÕES${RESET}"
        line "${DIM}1-3 valem só para este livro · 4-6 valem para todos${RESET}"
        echo ""
        item "1" "Título do livro ........... ${BOOK_TITLE}"
        item "2" "Autor ..................... ${BOOK_AUTHOR}"
        item "3" "Meta de palavras .......... $(format_number "$BOOK_WORD_GOAL")"
        echo ""
        item "4" "Formato dos arquivos ...... .${BOOK_EXT}"
        item "5" "Editor .................... ${BOOK_EDITOR}"
        item "6" "Animação de abertura ...... $([ "${BOOK_ANIMATION}" = "1" ] && echo ligada || echo desligada)"
        echo ""
        item "v" "Voltar"
        echo ""
        printf "%s  Opção: " "$PAD"
        read -r escolha
        case "$escolha" in
            1) printf "%s  Título: " "$PAD"; read -r valor
               [ -n "$valor" ] && set_config BOOK_TITLE "$valor" ;;
            2) printf "%s  Autor: " "$PAD"; read -r valor
               [ -n "$valor" ] && set_config BOOK_AUTHOR "$valor" ;;
            3) printf "%s  Meta de palavras: " "$PAD"; read -r valor
               case "$valor" in ''|*[!0-9]*) : ;; *) set_config BOOK_WORD_GOAL "$valor" ;; esac ;;
            4) printf "%s  Extensão (txt/md): " "$PAD"; read -r valor
               [ -n "$valor" ] && set_config BOOK_EXT "${valor#.}" global ;;
            5) printf "%s  Editor (nvim/code): " "$PAD"; read -r valor
               [ -n "$valor" ] && set_config BOOK_EDITOR "$valor" global ;;
            6) if [ "$BOOK_ANIMATION" = "1" ]; then set_config BOOK_ANIMATION 0 global; else set_config BOOK_ANIMATION 1 global; fi ;;
            v|V|"") return 0 ;;
            *) ;;
        esac
    done
}

tela_info() {
    draw_header
    line "${BOLD}COMO O WORKSPACE É ORGANIZADO${RESET}"
    echo ""
    line "  ${CYAN}livros/${RESET}        um diretório por livro, totalmente isolado"
    line "    ${DIM}└─ <slug>/00_notas · 01_personagens · 02_cenas${RESET}"
    line "    ${DIM}            03_capitulos · 90_arquivo · 99_build${RESET}"
    line "    ${DIM}            book.config (título, autor, meta)${RESET}"
    line "    ${DIM}            .ai/cache  (memória da IA só deste livro)${RESET}"
    echo ""
    line "  ${CYAN}scripts/${RESET}       automação compartilhada (lib/ = funções comuns)"
    line "  ${CYAN}templates/${RESET}     modelos opcionais (flag --template)"
    line "  ${CYAN}docs/${RESET}          guias do ambiente"
    line "  ${CYAN}assets/${RESET}        GIF de abertura e arte ASCII"
    line "  ${CYAN}.livro-ativo${RESET}   aponta qual livro está em uso"
    echo ""
    line "${BOLD}LIVRO ATIVO${RESET}"
    echo ""
    line "  Título .................. $(highlight "$BOOK_TITLE")"
    line "  Pasta ................... livros/${BOOK_SLUG}/"
    line "  Formato padrão .......... ${GREEN}.${BOOK_EXT}${RESET} (arquivos criados vazios)"
    line "  Memória da IA ........... livros/${BOOK_SLUG}/.ai/cache/"
    echo ""
    pause
}

tela_ajuda() {
    draw_header
    line "${BOLD}COMO USAR${RESET}"
    echo ""
    line "  ${BOLD}No menu${RESET}"
    line "   • 1-4 criam arquivos ${GREEN}vazios .${BOOK_EXT}${RESET} e abrem o editor"
    line "   • 5-8 listam o que já existe e abrem o arquivo escolhido"
    line "   • b troca de livro · L cria um livro novo (do zero, inclusive a IA)"
    line "   • m monta 99_build/book.md a partir de 03_capitulos/"
    line "   • x exporta PDF, DOCX e EPUB (precisa de pandoc)"
    echo ""
    line "  ${BOLD}No terminal${RESET}"
    line "   ${YELLOW}./scripts/new_book.sh \"A Casa Vazia\"${RESET}"
    line "   ${YELLOW}./scripts/books.sh${RESET}              lista os livros"
    line "   ${YELLOW}./scripts/books.sh o-escondido${RESET}  troca o livro ativo"
    line "   ${YELLOW}./scripts/new_chapter.sh \"1.3.O retorno\"${RESET}"
    line "   ${YELLOW}./scripts/new_scene.sh confronto-final --open${RESET}"
    line "   ${YELLOW}./scripts/build.sh --yes${RESET}"
    echo ""
    line "  ${BOLD}Isolamento entre livros${RESET}"
    line "   Textos, configuração, build e memória da IA ficam dentro de"
    line "   livros/<slug>/. Nenhum comando enxerga dois livros ao mesmo"
    line "   tempo — só o livro ativo."
    echo ""
    line "  ${BOLD}Templates${RESET}"
    line "   Arquivos nascem vazios. Para usar o modelo estruturado,"
    line "   acrescente ${YELLOW}--template${RESET} ao comando de criação."
    echo ""
    pause
}

# --------------------------------------------------------------------------
# Loop principal
# --------------------------------------------------------------------------
anim_intro

# Sem nenhum livro no workspace, o primeiro passo e criar um
if [ "$(books_count)" -eq 0 ]; then
    draw_header
    msg_warn "Nenhum livro neste workspace ainda."
    echo ""
    tela_novo_livro
fi

while true; do
    draw_menu
    printf "%s  ${BOLD}Escolha:${RESET} " "$PAD"
    read -r opcao || break

    case "$opcao" in
        1) criar new_chapter.sh   "NOVO CAPÍTULO" ;;
        2) criar new_scene.sh     "NOVA CENA" ;;
        3) criar new_character.sh "NOVO PERSONAGEM" ;;
        4) criar new_note.sh      "NOVA NOTA" ;;

        5) pick_file "$DIR_CAPITULOS"   "CAPÍTULOS" ;;
        6) pick_file "$DIR_CENAS"       "CENAS" ;;
        7) pick_file "$DIR_PERSONAGENS" "PERSONAGENS" ;;
        8) open_in_editor "$BOOK_ROOT" ;;

        m|M) clear; bash "${SCRIPT_DIR}/build.sh"; pause ;;
        x|X) clear; bash "${SCRIPT_DIR}/export.sh"; pause ;;
        w|W) clear; bash "${SCRIPT_DIR}/wordcount.sh"; pause ;;
        u|U) clear; bash "${SCRIPT_DIR}/update_personagens.sh"; pause ;;

        a|A) run_ai "metrics" ;;
        r|R) run_ai "consistency" ;;
        t|T) run_ai "themes" ;;
        p|P) run_ai "pacing" ;;

        b|B) tela_trocar_livro ;;
        L)   tela_novo_livro ;;

        c|C) tela_config ;;
        i|I) tela_info ;;
        h|H) tela_ajuda ;;
        q|Q) clear; msg_ok "Boa escrita!"; exit 0 ;;
        "")  ;;
        *)   msg_warn "Opção inválida: $opcao"; sleep 0.7 ;;
    esac
done
